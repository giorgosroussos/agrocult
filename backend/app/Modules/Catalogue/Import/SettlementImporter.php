<?php

namespace App\Modules\Catalogue\Import;

use App\Modules\Catalogue\Models\Settlement;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use InvalidArgumentException;

/**
 * Builds the settlement list (ENT-Settlement) from an OpenStreetMap export in Overpass API
 * JSON format ("out center tags"). The list is replaced in one transaction, so a bad file
 * keeps the previous list.
 */
class SettlementImporter
{
    private const REGION_TAGS = ['is_in:region', 'is_in:state', 'addr:region', 'addr:state'];

    /**
     * @return list<array{name_el: string, name_en: string|null, region: string|null, lat: float, lon: float}>
     *
     * @throws InvalidArgumentException when the export is not Overpass JSON
     */
    public function parse(string $json): array
    {
        $data = json_decode($json, true);

        if (! is_array($data) || ! is_array($data['elements'] ?? null)) {
            throw new InvalidArgumentException('The file is not an Overpass API JSON export (no "elements" list).');
        }

        $settlements = [];

        foreach ($data['elements'] as $element) {
            if (! is_array($element) || ! is_array($element['tags'] ?? null)) {
                continue;
            }

            $tags = $element['tags'];
            $nameEl = $this->text($tags['name:el'] ?? null) ?? $this->text($tags['name'] ?? null);
            $lat = $element['lat'] ?? $element['center']['lat'] ?? null;
            $lon = $element['lon'] ?? $element['center']['lon'] ?? null;

            if ($nameEl === null || ! is_numeric($lat) || ! is_numeric($lon) || abs((float) $lat) > 90 || abs((float) $lon) > 180) {
                continue;
            }

            $region = null;
            foreach (self::REGION_TAGS as $tag) {
                $region ??= $this->text($tags[$tag] ?? null);
            }

            $settlement = [
                'name_el' => $nameEl,
                'name_en' => $this->text($tags['name:en'] ?? null),
                'region' => $region,
                'lat' => round((float) $lat, 6),
                'lon' => round((float) $lon, 6),
            ];

            $settlements[mb_strtolower($nameEl).'|'.$settlement['lat'].'|'.$settlement['lon']] ??= $settlement;
        }

        return array_values($settlements);
    }

    /**
     * Replaces every settlement with the given list.
     *
     * @param  list<array{name_el: string, name_en: string|null, region: string|null, lat: float, lon: float}>  $settlements
     */
    public function replace(array $settlements): int
    {
        DB::transaction(function () use ($settlements): void {
            Settlement::query()->delete();

            foreach (array_chunk($settlements, 1000) as $chunk) {
                Settlement::query()->insert(array_map(
                    fn (array $settlement): array => ['id' => (string) Str::uuid7()] + $settlement,
                    $chunk,
                ));
            }
        });

        return count($settlements);
    }

    private function text(mixed $value): ?string
    {
        if (! is_string($value) || trim($value) === '') {
            return null;
        }

        return mb_substr(trim($value), 0, 255);
    }
}
