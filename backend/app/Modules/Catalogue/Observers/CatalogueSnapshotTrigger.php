<?php

namespace App\Modules\Catalogue\Observers;

use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Enums\TipStatus;
use App\Modules\Catalogue\Jobs\BuildCatalogueSnapshot;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Companion;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Models\Settlement;
use App\Modules\Catalogue\Models\Tip;
use BackedEnum;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

/**
 * Queues a snapshot build (after the transaction commits) whenever a change reaches what
 * devices see: a plant or tip is published or leaves the published state, published content
 * is edited or deleted, or a category, climate zone or settlement changes while something
 * is published. Draft work never triggers a build.
 */
class CatalogueSnapshotTrigger
{
    public function saved(Model $model): void
    {
        $this->trigger($model);
    }

    public function deleted(Model $model): void
    {
        $this->trigger($model);
    }

    private function trigger(Model $model): void
    {
        if ($this->affectsSnapshot($model)) {
            // The whole dispatch waits for the commit, including the job's unique lock: with
            // the database cache store a lock already held makes its INSERT fail, which would
            // abort an open PostgreSQL transaction (e.g. a second publish while a build is queued).
            DB::afterCommit(fn () => BuildCatalogueSnapshot::dispatch());
        }
    }

    private function affectsSnapshot(Model $model): bool
    {
        return match (true) {
            $model instanceof Plant => $this->isOrWas($model, PlantStatus::Published->value),
            $model instanceof Tip => $this->isOrWas($model, TipStatus::Published->value),
            $model instanceof Settlement => true,
            $model instanceof PlantCategory, $model instanceof ClimateZone => Plant::query()->published()->exists()
                || Tip::query()->published()->exists(),
            $model instanceof Companion => $this->anyPublished($model, ['plant_id', 'other_plant_id']),
            default => $this->anyPublished($model, ['plant_id']),
        };
    }

    private function isOrWas(Model $model, string $status): bool
    {
        return $this->raw($model->getAttributes()['status'] ?? null) === $status
            || $this->raw($model->getRawOriginal('status')) === $status;
    }

    /**
     * @param  list<string>  $columns  plant references of the model (current and original values count)
     */
    private function anyPublished(Model $model, array $columns): bool
    {
        $ids = [];

        foreach ($columns as $column) {
            $ids[] = $model->getAttribute($column);
            $ids[] = $model->getRawOriginal($column);
        }

        $ids = array_values(array_unique(array_filter($ids, 'is_string')));

        return $ids !== [] && Plant::query()->published()->whereKey($ids)->exists();
    }

    private function raw(mixed $status): ?string
    {
        return match (true) {
            $status instanceof BackedEnum => (string) $status->value,
            is_string($status) => $status,
            default => null,
        };
    }
}
