<?php

namespace App\Modules\Weather\Climate;

/**
 * Nearest-zone assignment (DATA-009). Zone rules are {"<metric>": {"min": number|null,
 * "max": number|null}} over the metric keys below; min is inclusive, max exclusive, null
 * unbounded, and every other key is ignored.
 *
 * The distance of a cell to a zone is the sum over the zone's rule metrics of how far the cell
 * value lies outside the bounds; 0 means the cell matches. A value exactly on an exclusive
 * maximum is outside by 0, so among zones at the same distance a matching zone comes first.
 * The cell gets the zone with the smallest distance; ties go to the lowest code. For matching
 * only, a null last_frost_doy counts as 0 and a null first_frost_doy as 366.
 */
final class ZoneMatcher
{
    public const METRICS = ['elevation_m', 'winter_min_mean_c', 'last_frost_doy', 'first_frost_doy'];

    /**
     * @param  list<array{id: string, code: string, rules: array<string, mixed>}>  $zones
     * @return string|null id of the nearest zone; null only when there are no zones
     */
    public function nearest(ClimateMetrics $metrics, array $zones): ?string
    {
        $values = $metrics->toArray();
        $values['last_frost_doy'] ??= 0;
        $values['first_frost_doy'] ??= 366;

        $ranked = [];

        foreach ($zones as $zone) {
            [$distance, $matches] = $this->distance($values, $zone['rules']);
            $ranked[] = ['id' => $zone['id'], 'code' => $zone['code'], 'distance' => $distance, 'outside' => $matches ? 0 : 1];
        }

        usort($ranked, fn (array $a, array $b): int => [$a['distance'], $a['outside']] <=> [$b['distance'], $b['outside']]
            ?: strcmp($a['code'], $b['code']));

        return $ranked[0]['id'] ?? null;
    }

    /**
     * @param  array<string, int|float>  $values
     * @param  array<string, mixed>  $rules
     * @return array{0: float, 1: bool} distance outside the bounds, and whether the cell matches
     */
    public function distance(array $values, array $rules): array
    {
        $distance = 0.0;
        $matches = true;

        foreach (self::METRICS as $metric) {
            $bounds = $rules[$metric] ?? null;

            if (! is_array($bounds)) {
                continue;
            }

            $value = (float) $values[$metric];
            $min = $this->bound($bounds['min'] ?? null);
            $max = $this->bound($bounds['max'] ?? null);

            if ($min !== null && $value < $min) {
                $distance += $min - $value;
                $matches = false;
            }

            if ($max !== null && $value >= $max) {
                $distance += $value - $max;
                $matches = false;
            }
        }

        return [$distance, $matches];
    }

    private function bound(mixed $value): ?float
    {
        return is_int($value) || is_float($value) ? (float) $value : null;
    }
}
