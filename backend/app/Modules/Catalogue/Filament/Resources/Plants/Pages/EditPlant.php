<?php

namespace App\Modules\Catalogue\Filament\Resources\Plants\Pages;

use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Exceptions\InvalidPlantTransition;
use App\Modules\Catalogue\Exceptions\PlantNotPublishable;
use App\Modules\Catalogue\Filament\Resources\Plants\PlantResource;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Services\PlantWorkflow;
use Filament\Actions\Action;
use Filament\Actions\DeleteAction;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;
use Filament\Support\Icons\Heroicon;
use Illuminate\Support\Facades\Gate;

/**
 * Editing a plant and moving it through review and publishing (UC-010).
 *
 * Only the transitions of the ENT-Plant state model are offered; every status change goes
 * through PlantWorkflow, which rejects unlisted transitions and publishing a plant whose
 * required structured fields are missing, leaving the status unchanged.
 *
 * @property Plant $record
 */
class EditPlant extends EditRecord
{
    protected static string $resource = PlantResource::class;

    public function getSubheading(): string
    {
        $plant = $this->getPlant();
        $subheading = PlantResource::statusLabel($plant->status);

        $missing = $plant->missingFieldsForPublishing();
        if ($missing !== [] && $plant->status->canTransitionTo(PlantStatus::Published)) {
            $subheading .= ' · '.__('catalogue::panel.plants.missing_for_publishing', ['fields' => $this->fieldLabels($missing)]);
        }

        return $subheading;
    }

    protected function getHeaderActions(): array
    {
        return [
            $this->statusAction('submitForReview', PlantStatus::InReview, 'submit_for_review', Heroicon::OutlinedPaperAirplane, 'warning'),
            $this->statusAction('publish', PlantStatus::Published, 'publish', Heroicon::OutlinedCheckBadge, 'success')
                ->requiresConfirmation()
                ->modalDescription(__('catalogue::panel.plants.actions.publish_description')),
            $this->statusAction('returnToDraft', PlantStatus::Draft, 'return_to_draft', Heroicon::OutlinedArrowUturnLeft, 'gray'),
            $this->statusAction('archive', PlantStatus::Archived, 'archive', Heroicon::OutlinedArchiveBox, 'danger')
                ->requiresConfirmation()
                ->modalDescription(__('catalogue::panel.plants.actions.archive_description')),
            DeleteAction::make(),
        ];
    }

    private function statusAction(string $name, PlantStatus $to, string $label, Heroicon $icon, string $color): Action
    {
        return Action::make($name)
            ->label(__('catalogue::panel.plants.actions.'.$label))
            ->icon($icon)
            ->color($color)
            ->visible(fn (): bool => $this->getPlant()->status->canTransitionTo($to))
            ->authorize(fn (): bool => Gate::allows('update', $this->getPlant()))
            ->action(fn () => $this->changeStatus($to));
    }

    private function changeStatus(PlantStatus $to): void
    {
        Gate::authorize('update', $this->getPlant());

        // The status in the database is the reference, not the one loaded with the page.
        $plant = $this->getPlant()->refresh();

        try {
            app(PlantWorkflow::class)->transition($plant, $to, $to === PlantStatus::Published ? $this->reviewerId() : null);
        } catch (InvalidPlantTransition $e) {
            $this->notifyRejected(__('catalogue::panel.plants.actions.rejected_transition', [
                'from' => $e->from === null ? '' : PlantResource::statusLabel($e->from),
                'to' => PlantResource::statusLabel($e->to),
            ]));

            return;
        } catch (PlantNotPublishable $e) {
            $this->notifyRejected(__('catalogue::panel.plants.actions.not_publishable', [
                'fields' => $this->fieldLabels($e->missingFields),
            ]));

            return;
        }

        Notification::make()
            ->title(__('catalogue::panel.plants.actions.done', ['status' => PlantResource::statusLabel($plant->status)]))
            ->success()
            ->send();
    }

    private function notifyRejected(string $message): void
    {
        $this->getPlant()->refresh();

        Notification::make()
            ->title($message)
            ->danger()
            ->persistent()
            ->send();
    }

    private function reviewerId(): ?string
    {
        $id = auth()->id();

        return $id === null ? null : (string) $id;
    }

    /**
     * @param  list<string>  $fields
     */
    private function fieldLabels(array $fields): string
    {
        return implode(', ', array_map(
            fn (string $field): string => __('catalogue::panel.plants.fields.'.($field === 'category_id' ? 'category' : $field)),
            $fields,
        ));
    }

    private function getPlant(): Plant
    {
        /** @var Plant $plant */
        $plant = $this->getRecord();

        return $plant;
    }
}
