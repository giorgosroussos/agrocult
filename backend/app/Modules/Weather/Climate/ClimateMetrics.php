<?php

namespace App\Modules\Weather\Climate;

use App\Modules\Weather\Provider\DailyWeather;

/**
 * Climate metrics of a weather cell (DATA-009), computed once from the last 10 full calendar
 * years of daily history:
 *
 * - winter_min_mean_c: mean over the years of the mean daily minimum of that year's coldest
 *   calendar month;
 * - last_frost_doy / first_frost_doy: mean day of year of the last frost before 1 July / the
 *   first frost from 1 July on, over the years that had such a frost; null when fewer than
 *   half of the years had one. Frost is a daily minimum <= 0 °C.
 */
final class ClimateMetrics
{
    public const FROST_C = 0.0;

    public function __construct(
        public readonly int $elevationM,
        public readonly float $winterMinMeanC,
        public readonly ?int $lastFrostDoy,
        public readonly ?int $firstFrostDoy,
    ) {}

    /**
     * Metric values by the rule keys of the climate zones.
     *
     * @return array{elevation_m: int, winter_min_mean_c: float, last_frost_doy: ?int, first_frost_doy: ?int}
     */
    public function toArray(): array
    {
        return [
            'elevation_m' => $this->elevationM,
            'winter_min_mean_c' => $this->winterMinMeanC,
            'last_frost_doy' => $this->lastFrostDoy,
            'first_frost_doy' => $this->firstFrostDoy,
        ];
    }

    /**
     * @param  list<DailyWeather>  $days  daily history of whole calendar years
     * @return self|null null when the history has no usable daily minimum
     */
    public static function fromHistory(int $elevationM, array $days): ?self
    {
        /** @var array<int, array<int, list<float>>> $minima year => month => daily minima */
        $minima = [];

        foreach ($days as $day) {
            $minima[$day->date->year] ??= [];

            if ($day->tempMinC !== null) {
                $minima[$day->date->year][$day->date->month][] = $day->tempMinC;
            }
        }

        $years = count($minima);
        $coldest = [];
        /** @var array<int, int> $lastFrost year => day of year */
        $lastFrost = [];
        /** @var array<int, int> $firstFrost year => day of year */
        $firstFrost = [];

        foreach ($minima as $year => $months) {
            if ($months !== []) {
                $coldest[] = min(array_map(fn (array $values): float => array_sum($values) / count($values), $months));
            }
        }

        if ($coldest === []) {
            return null;
        }

        foreach ($days as $day) {
            if ($day->tempMinC === null || $day->tempMinC > self::FROST_C) {
                continue;
            }

            $year = $day->date->year;
            $doy = $day->date->dayOfYear;

            if ($day->date->month < 7) {
                $lastFrost[$year] = max($lastFrost[$year] ?? $doy, $doy);
            } else {
                $firstFrost[$year] = min($firstFrost[$year] ?? $doy, $doy);
            }
        }

        return new self(
            $elevationM,
            round(array_sum($coldest) / count($coldest), 2),
            self::frostDoy($lastFrost, $years),
            self::frostDoy($firstFrost, $years),
        );
    }

    /**
     * @param  array<int, int>  $doys  day of year per year that had the frost
     */
    private static function frostDoy(array $doys, int $years): ?int
    {
        if ($doys === [] || count($doys) * 2 < $years) {
            return null;
        }

        return (int) round(array_sum($doys) / count($doys));
    }
}
