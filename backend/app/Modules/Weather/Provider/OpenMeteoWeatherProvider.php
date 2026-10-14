<?php

namespace App\Modules\Weather\Provider;

use App\Modules\Weather\Exceptions\WeatherUnavailable;
use Carbon\CarbonImmutable;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Support\Facades\Http;
use Throwable;

/**
 * WeatherProvider over the Open-Meteo HTTP API (EXT-002). Endpoints come from
 * config('weather.open_meteo'); every call has the configured timeout (10 s) and no retries
 * of its own: retries happen through the queue (INT-002). Only coordinates rounded to two
 * decimals are sent (SEC-002).
 */
class OpenMeteoWeatherProvider implements WeatherProvider
{
    private const DAILY = 'temperature_2m_min,temperature_2m_max,precipitation_sum';

    public function forecast(float $lat, float $lon, int $days): array
    {
        $daily = $this->daily('forecast', $this->url('base_url', '/v1/forecast'), $lat, $lon, ['forecast_days' => $days]);

        return array_map(
            fn (array $day): DailyForecast => new DailyForecast($day['date'], $day['rain'], $day['min'], $day['max']),
            $daily,
        );
    }

    public function history(float $lat, float $lon, CarbonImmutable $from, CarbonImmutable $to): array
    {
        $daily = $this->daily('history', $this->url('archive_url', '/v1/archive'), $lat, $lon, [
            'start_date' => $from->toDateString(),
            'end_date' => $to->toDateString(),
        ]);

        return array_map(
            fn (array $day): DailyWeather => new DailyWeather($day['date'], $day['rain'], $day['min'], $day['max']),
            $daily,
        );
    }

    public function elevation(float $lat, float $lon): int
    {
        $json = $this->get('elevation', $this->url('base_url', '/v1/elevation'), $this->coordinates($lat, $lon));
        $value = $json['elevation'][0] ?? null;

        if (! is_int($value) && ! is_float($value)) {
            throw WeatherUnavailable::because('elevation', 'unexpected response');
        }

        return (int) round($value);
    }

    /**
     * @param  array<string, scalar>  $query
     * @return list<array{date: CarbonImmutable, rain: ?float, min: ?float, max: ?float}>
     */
    private function daily(string $operation, string $url, float $lat, float $lon, array $query): array
    {
        $json = $this->get($operation, $url, $this->coordinates($lat, $lon) + $query + [
            'daily' => self::DAILY,
            'timezone' => (string) config('weather.open_meteo.timezone', 'Europe/Athens'),
        ]);

        $daily = $json['daily'] ?? null;
        $time = is_array($daily) ? ($daily['time'] ?? null) : null;

        if (! is_array($daily) || ! is_array($time)) {
            throw WeatherUnavailable::because($operation, 'unexpected response');
        }

        $days = [];

        foreach (array_values($time) as $i => $date) {
            if (! is_string($date)) {
                throw WeatherUnavailable::because($operation, 'unexpected response');
            }

            try {
                $day = CarbonImmutable::createFromFormat('!Y-m-d', $date);
            } catch (Throwable) {
                $day = null;
            }

            if (! $day instanceof CarbonImmutable) {
                throw WeatherUnavailable::because($operation, 'unexpected response');
            }

            $days[] = [
                'date' => $day,
                'rain' => $this->number($daily['precipitation_sum'][$i] ?? null),
                'min' => $this->number($daily['temperature_2m_min'][$i] ?? null),
                'max' => $this->number($daily['temperature_2m_max'][$i] ?? null),
            ];
        }

        return $days;
    }

    /**
     * @param  array<string, scalar>  $query
     * @return array<mixed>
     */
    private function get(string $operation, string $url, array $query): array
    {
        try {
            $response = $this->request()->get($url, $query);
        } catch (ConnectionException) {
            throw WeatherUnavailable::because($operation, 'connection failed or timed out');
        }

        if (! $response->successful()) {
            throw WeatherUnavailable::because($operation, 'HTTP '.$response->status());
        }

        $json = $response->json();

        if (! is_array($json)) {
            throw WeatherUnavailable::because($operation, 'unexpected response');
        }

        return $json;
    }

    private function request(): PendingRequest
    {
        return Http::acceptJson()
            ->timeout((int) config('weather.open_meteo.timeout', 10))
            ->connectTimeout((int) config('weather.open_meteo.timeout', 10));
    }

    /**
     * @return array{latitude: float, longitude: float}
     */
    private function coordinates(float $lat, float $lon): array
    {
        return ['latitude' => round($lat, 2), 'longitude' => round($lon, 2)];
    }

    private function url(string $key, string $path): string
    {
        $base = config("weather.open_meteo.{$key}");

        if (! is_string($base) || $base === '') {
            throw WeatherUnavailable::because($key, 'not configured');
        }

        return rtrim($base, '/').$path;
    }

    private function number(mixed $value): ?float
    {
        return is_int($value) || is_float($value) ? (float) $value : null;
    }
}
