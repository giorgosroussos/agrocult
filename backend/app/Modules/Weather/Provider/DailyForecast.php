<?php

namespace App\Modules\Weather\Provider;

use Carbon\CarbonImmutable;

/**
 * One forecast day of a weather cell (INT-002).
 */
final class DailyForecast
{
    public function __construct(
        public readonly CarbonImmutable $date,
        public readonly ?float $rainMm,
        public readonly ?float $tempMinC,
        public readonly ?float $tempMaxC,
    ) {}
}
