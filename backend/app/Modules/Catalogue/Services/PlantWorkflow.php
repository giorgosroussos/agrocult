<?php

namespace App\Modules\Catalogue\Services;

use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Exceptions\InvalidPlantTransition;
use App\Modules\Catalogue\Exceptions\PlantNotPublishable;
use App\Modules\Catalogue\Models\Plant;
use Illuminate\Support\Facades\DB;

/**
 * Public service for ENT-Plant status changes (draft -> in_review -> published -> archived ...).
 *
 * Publishing records the reviewer and the review and publication times. A rejected
 * transition throws and leaves the plant unchanged, in memory and in the database.
 */
class PlantWorkflow
{
    /**
     * @throws InvalidPlantTransition
     * @throws PlantNotPublishable
     */
    public function transition(Plant $plant, PlantStatus $to, ?string $reviewerId = null): Plant
    {
        $from = $plant->status;

        if (! $plant->exists || ! $from->canTransitionTo($to)) {
            throw new InvalidPlantTransition($plant->exists ? $from : null, $to);
        }

        $original = $plant->only(['status', 'reviewed_by', 'reviewed_at', 'published_at']);

        $plant->status = $to;

        if ($to === PlantStatus::Published) {
            $now = now()->toImmutable();
            $plant->published_at = $now;
            $plant->reviewed_at = $now;
            if ($reviewerId !== null) {
                $plant->reviewed_by = $reviewerId;
            }
        }

        try {
            DB::transaction(fn () => $plant->save());
        } catch (InvalidPlantTransition|PlantNotPublishable $e) {
            $plant->forceFill($original);

            throw $e;
        }

        return $plant;
    }

    public function submitForReview(Plant $plant): Plant
    {
        return $this->transition($plant, PlantStatus::InReview);
    }

    public function publish(Plant $plant, ?string $reviewerId = null): Plant
    {
        return $this->transition($plant, PlantStatus::Published, $reviewerId);
    }

    public function returnToDraft(Plant $plant): Plant
    {
        return $this->transition($plant, PlantStatus::Draft);
    }

    public function archive(Plant $plant): Plant
    {
        return $this->transition($plant, PlantStatus::Archived);
    }
}
