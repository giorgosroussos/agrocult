<?php

namespace App\Modules\Catalogue\Snapshot;

use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Enums\TipStatus;
use Carbon\CarbonImmutable;
use Illuminate\Database\Query\Builder;
use Illuminate\Support\Facades\DB;

/**
 * Reads the published catalogue as plain rows for the snapshot (ARCH-003).
 *
 * Only published plants and published tips are exported, together with everything that
 * belongs to those plants; categories, climate zones and settlements are exported whole.
 * Curator-only data (status, reviewer, photo file paths, audits) never leaves the server.
 * Rows are ordered by id so that equal content gives an equal export.
 */
class SnapshotExporter
{
    /**
     * @return array<string, list<array<string, mixed>>> table name => rows
     */
    public function export(): array
    {
        $plants = $this->rows(
            DB::table('plants')->where('status', PlantStatus::Published->value)->orderBy('id'),
        );
        $plantIds = array_map(fn (array $plant): string => (string) $plant['id'], $plants);

        $translations = $this->rows($this->ofPlants('plant_translations', $plantIds)->orderBy('plant_id')->orderBy('lang'));
        $aliases = $this->rows($this->ofPlants('plant_aliases', $plantIds));

        return [
            'categories' => $this->rows(DB::table('plant_categories')
                ->select(['id', 'code', 'name_el', 'name_en', 'parent_id', 'sort_order'])->orderBy('id')),
            'climate_zones' => array_map(
                fn (array $zone): array => ['rules' => $this->json($zone['rules'])] + $zone,
                $this->rows(DB::table('climate_zones')
                    ->select(['id', 'code', 'name_el', 'name_en', 'description', 'rules'])->orderBy('id')),
            ),
            'plants' => array_map(
                fn (array $plant): array => $this->plant($plant, $translations, $aliases),
                $plants,
            ),
            'plant_translations' => array_map(
                fn (array $row): array => array_intersect_key($row, array_flip([
                    'id', 'plant_id', 'lang', 'name', 'description', 'planting', 'care', 'seed_saving', 'tips',
                ])),
                $translations,
            ),
            'plant_aliases' => array_map(
                fn (array $row): array => array_intersect_key($row, array_flip(['id', 'plant_id', 'lang', 'alias', 'kind'])),
                $aliases,
            ),
            'plant_calendars' => $this->rows($this->ofPlants('plant_calendars', $plantIds)
                ->select(['id', 'plant_id', 'climate_zone_id', 'activity', 'month_from', 'month_to'])),
            'companions' => $this->rows($this->ofPlants('companions', $plantIds)
                ->whereIn('other_plant_id', $plantIds)
                ->select(['id', 'plant_id', 'other_plant_id', 'relation'])),
            'care_intervals' => $this->rows($this->ofPlants('care_intervals', $plantIds)
                ->select(['id', 'plant_id', 'action', 'interval_days', 'month_from', 'month_to'])),
            'plant_photos' => $this->rows($this->ofPlants('plant_photos', $plantIds)
                ->select(['id', 'plant_id', 'credit', 'licence', 'source_url'])),
            'fact_sources' => array_map(
                fn (array $row): array => ['imported_at' => $this->timestamp($row['imported_at'])] + $row,
                $this->rows($this->ofPlants('fact_sources', $plantIds)
                    ->select(['id', 'plant_id', 'field', 'source_name', 'source_url', 'licence', 'imported_at'])),
            ),
            'tips' => $this->rows(DB::table('tips')
                ->where('status', TipStatus::Published->value)
                ->where(fn (Builder $query) => $query->whereNull('plant_id')->orWhereIn('plant_id', $plantIds))
                ->select(['id', 'text_el', 'text_en', 'month_from', 'month_to', 'climate_zone_id', 'plant_id'])
                ->orderBy('id')),
            'settlements' => array_map(
                fn (array $row): array => [
                    'lat' => (float) $row['lat'],
                    'lon' => (float) $row['lon'],
                    'search_keys' => SearchKeys::asText([$row['name_el'], $row['name_en']]),
                ] + $row,
                $this->rows(DB::table('settlements')
                    ->select(['id', 'name_el', 'name_en', 'region', 'lat', 'lon'])->orderBy('id')),
            ),
        ];
    }

    /**
     * @param  array<string, mixed>  $plant
     * @param  list<array<string, mixed>>  $translations
     * @param  list<array<string, mixed>>  $aliases
     * @return array<string, mixed>
     */
    private function plant(array $plant, array $translations, array $aliases): array
    {
        $own = fn (array $row): bool => $row['plant_id'] === $plant['id'];

        $texts = array_merge(
            array_map(fn (array $row): string => (string) $row['name'], array_values(array_filter($translations, $own))),
            array_map(fn (array $row): string => (string) $row['alias'], array_values(array_filter($aliases, $own))),
            [(string) $plant['scientific_name']],
        );

        return [
            'id' => $plant['id'],
            'scientific_name' => $plant['scientific_name'],
            'gbif_id' => $this->int($plant['gbif_id']),
            'category_id' => $plant['category_id'],
            'temp_min_c' => $this->float($plant['temp_min_c']),
            'temp_opt_c' => $this->float($plant['temp_opt_c']),
            'temp_max_c' => $this->float($plant['temp_max_c']),
            'water_need' => $this->int($plant['water_need']),
            'sun' => $plant['sun'],
            'soil_types' => $this->json($plant['soil_types']),
            'ph_min' => $this->float($plant['ph_min']),
            'ph_max' => $this->float($plant['ph_max']),
            'frost_hardiness' => $plant['frost_hardiness'],
            'propagation' => $this->json($plant['propagation']),
            'sow_depth_cm' => $this->float($plant['sow_depth_cm']),
            'spacing_cm' => $this->int($plant['spacing_cm']),
            'row_spacing_cm' => $this->int($plant['row_spacing_cm']),
            'days_to_harvest' => $this->int($plant['days_to_harvest']),
            'published_at' => $this->timestamp($plant['published_at']),
            'updated_at' => $this->timestamp($plant['updated_at']),
            'search_keys' => SearchKeys::asText($texts),
        ];
    }

    /**
     * @param  list<string>  $plantIds
     */
    private function ofPlants(string $table, array $plantIds): Builder
    {
        return DB::table($table)->whereIn('plant_id', $plantIds)->orderBy('plant_id')->orderBy('id');
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function rows(Builder $query): array
    {
        return $query->get()->map(fn (object $row): array => (array) $row)->values()->all();
    }

    private function float(mixed $value): ?float
    {
        return $value === null ? null : (float) $value;
    }

    private function int(mixed $value): ?int
    {
        return $value === null ? null : (int) $value;
    }

    /** JSON columns are stored as compact JSON text in SQLite. */
    private function json(mixed $value): ?string
    {
        if ($value === null) {
            return null;
        }

        $decoded = is_string($value) ? json_decode($value, true) : $value;

        return json_encode($decoded, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    }

    /** Timestamps as ISO 8601 in UTC. */
    private function timestamp(mixed $value): ?string
    {
        return $value === null ? null : CarbonImmutable::parse((string) $value)->utc()->toIso8601ZuluString();
    }
}
