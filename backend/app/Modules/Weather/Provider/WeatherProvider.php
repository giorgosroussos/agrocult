<?php

namespace App\Modules\Weather\Provider;

use App\Modules\Weather\Exceptions\WeatherUnavailable;
use Carbon\CarbonImmutable;

/**
 * INT-002: the only way to reach the weather service (EXT-002). Called from queued jobs, one
 * per weather cell, with the cell's rounded coordinates only (SEC-002).
 */
interface WeatherProvider
{
    /**
     * Daily forecast for the next `$days` days, starting today.
     *
     * @return list<DailyForecast>
     *
     * @throws WeatherUnavailable when the service fails, times out or answers nonsense
     */
    public function forecast(float $lat, float $lon, int $days): array;

    /**
     * Observed daily weather from `$from` to `$to` (both inclusive).
     *
     * @return list<DailyWeather>
     *
     * @throws WeatherUnavailable
     */
    public function history(float $lat, float $lon, CarbonImmutable $from, CarbonImmutable $to): array;

    /**
     * Elevation in metres.
     *
     * @throws WeatherUnavailable
     */
    public function elevation(float $lat, float $lon): int;
}
