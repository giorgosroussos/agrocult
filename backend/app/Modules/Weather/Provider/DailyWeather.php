<?php

namespace App\Modules\Weather\Provider;

use Carbon\CarbonImmutable;

/**
 * One observed day of a weather cell from the archive (INT-002). A value the archive does not
 * have is null.
 */
final class DailyWeather
{
    public function __construct(
        public readonly CarbonImmutable $date,
        public readonly ?float $rainMm,
        public readonly ?float $tempMinC,
        public readonly ?float $tempMaxC,
    ) {}
}
