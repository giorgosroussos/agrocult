<?php

namespace App\Modules\Weather\Provider;

use App\Modules\Weather\Exceptions\WeatherUnavailable;
use Carbon\CarbonImmutable;

/**
 * WeatherProvider that never leaves the machine: always used in tests, and wherever
 * WEATHER_PROVIDER=fake. Without set-up it returns deterministic synthetic weather (a mild
 * Mediterranean year, colder with latitude and elevation). Tests can set fixed answers,
 * simulate failures (unavailable or timeout) per operation, and inspect the calls made.
 */
class FakeWeatherProvider implements WeatherProvider
{
    public const OPERATIONS = ['forecast', 'history', 'elevation'];

    /** @var list<array<string, string|float>> operation, lat, lon, and from / to for history */
    public array $calls = [];

    private ?int $elevation = null;

    /** @var list<DailyWeather>|null */
    private ?array $history = null;

    /** @var list<DailyForecast>|null */
    private ?array $forecast = null;

    /** @var array<string, string> operation => failure reason */
    private array $failures = [];

    public function withElevation(int $metres): self
    {
        $this->elevation = $metres;

        return $this;
    }

    /**
     * @param  list<DailyWeather>  $days
     */
    public function withHistory(array $days): self
    {
        $this->history = $days;

        return $this;
    }

    /**
     * @param  list<DailyForecast>  $days
     */
    public function withForecast(array $days): self
    {
        $this->forecast = $days;

        return $this;
    }

    /**
     * Makes the given operations (all when none given) fail until recover() is called.
     *
     * @param  'unavailable'|'timeout'  $reason
     * @param  list<string>  $operations
     */
    public function fail(string $reason = 'unavailable', array $operations = self::OPERATIONS): self
    {
        foreach ($operations as $operation) {
            $this->failures[$operation] = $reason === 'timeout' ? 'connection failed or timed out' : 'HTTP 503';
        }

        return $this;
    }

    public function recover(): self
    {
        $this->failures = [];

        return $this;
    }

    public function callCount(string $operation): int
    {
        return count(array_filter($this->calls, fn (array $call): bool => $call['operation'] === $operation));
    }

    public function forecast(float $lat, float $lon, int $days): array
    {
        $this->call('forecast', $lat, $lon);

        if ($this->forecast !== null) {
            return $this->forecast;
        }

        $today = CarbonImmutable::today();
        $result = [];

        for ($i = 0; $i < $days; $i++) {
            $date = $today->addDays($i);
            [$min, $max] = $this->temperatures($date, $lat, 0);
            $result[] = new DailyForecast($date, 0.0, $min, $max);
        }

        return $result;
    }

    public function history(float $lat, float $lon, CarbonImmutable $from, CarbonImmutable $to): array
    {
        $this->call('history', $lat, $lon, ['from' => $from->toDateString(), 'to' => $to->toDateString()]);

        if ($this->history !== null) {
            return $this->history;
        }

        $elevation = $this->elevation ?? 50;
        $result = [];

        for ($date = $from->startOfDay(); $date->lte($to); $date = $date->addDay()) {
            [$min, $max] = $this->temperatures($date, $lat, $elevation);
            $result[] = new DailyWeather($date, $date->day % 7 === 0 ? 4.0 : 0.0, $min, $max);
        }

        return $result;
    }

    public function elevation(float $lat, float $lon): int
    {
        $this->call('elevation', $lat, $lon);

        return $this->elevation ?? 50;
    }

    /**
     * @param  array<string, string>  $extra
     */
    private function call(string $operation, float $lat, float $lon, array $extra = []): void
    {
        $this->calls[] = ['operation' => $operation, 'lat' => $lat, 'lon' => $lon] + $extra;

        if (isset($this->failures[$operation])) {
            throw WeatherUnavailable::because($operation, $this->failures[$operation]);
        }
    }

    /**
     * @return array{0: float, 1: float} daily minimum and maximum in °C
     */
    private function temperatures(CarbonImmutable $date, float $lat, int $elevation): array
    {
        // Coldest around mid-January, warmest around mid-July.
        $season = -cos(2 * M_PI * ($date->dayOfYear - 15) / 365.25);
        $offset = ($lat - 35.0) * 1.2 + $elevation / 150;
        $min = round(12.0 + 8.0 * $season - $offset, 1);

        return [$min, round($min + 9.0, 1)];
    }
}
