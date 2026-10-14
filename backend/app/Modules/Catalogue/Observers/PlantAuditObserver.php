<?php

namespace App\Modules\Catalogue\Observers;

use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantAudit;
use Illuminate\Support\Facades\Auth;

/**
 * Writes the audit trail on catalogue plant changes: who changed which attribute and when.
 */
class PlantAuditObserver
{
    /** Bookkeeping columns that are not audited. */
    private const IGNORED = ['id', 'updated_at'];

    private const JSON_COLUMNS = ['soil_types', 'propagation'];

    public function created(Plant $plant): void
    {
        $changes = [];
        foreach ($this->audited($plant->getAttributes()) as $field => $value) {
            $changes[$field] = ['old' => null, 'new' => $value];
        }

        $this->record($plant, PlantAudit::EVENT_CREATED, $changes);
    }

    public function updated(Plant $plant): void
    {
        $changes = [];
        foreach ($this->audited($plant->getChanges()) as $field => $value) {
            $changes[$field] = ['old' => $this->value($field, $plant->getRawOriginal($field)), 'new' => $value];
        }

        if ($changes !== []) {
            $this->record($plant, PlantAudit::EVENT_UPDATED, $changes);
        }
    }

    public function deleted(Plant $plant): void
    {
        $changes = [];
        foreach ($this->audited($plant->getRawOriginal()) as $field => $value) {
            $changes[$field] = ['old' => $value, 'new' => null];
        }

        $this->record($plant, PlantAudit::EVENT_DELETED, $changes);
    }

    /**
     * @param  array<string, mixed>  $attributes
     * @return array<string, mixed>
     */
    private function audited(array $attributes): array
    {
        $values = array_diff_key($attributes, array_flip(self::IGNORED));

        foreach ($values as $field => $value) {
            $values[$field] = $this->value($field, $value);
        }

        return $values;
    }

    /** JSON columns are stored as strings; keep them structured in the trail. */
    private function value(string $field, mixed $value): mixed
    {
        return is_string($value) && in_array($field, self::JSON_COLUMNS, true)
            ? json_decode($value, true)
            : $value;
    }

    /**
     * @param  array<string, array{old: mixed, new: mixed}>  $changes
     */
    private function record(Plant $plant, string $event, array $changes): void
    {
        $actor = Auth::id();

        PlantAudit::query()->create([
            'plant_id' => $plant->getKey(),
            'user_id' => is_string($actor) ? $actor : null,
            'event' => $event,
            'changes' => $changes,
        ]);
    }
}
