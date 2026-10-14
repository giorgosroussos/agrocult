<?php

namespace App\Modules\Catalogue\Services;

use App\Modules\Catalogue\Models\ClimateZone;

/**
 * Public read service for the climate zones (DATA-009): other modules (CMP-Weather) read the
 * zones and their rules only through this class, as plain data, never through the models.
 */
class ClimateZones
{
    /**
     * Every climate zone ordered by code.
     *
     * @return list<array{id: string, code: string, rules: array<string, mixed>}>
     */
    public function all(): array
    {
        return ClimateZone::query()
            ->orderBy('code')
            ->get(['id', 'code', 'rules'])
            ->map(fn (ClimateZone $zone): array => [
                'id' => (string) $zone->id,
                'code' => (string) $zone->code,
                'rules' => $zone->rules,
            ])
            ->values()
            ->all();
    }
}
