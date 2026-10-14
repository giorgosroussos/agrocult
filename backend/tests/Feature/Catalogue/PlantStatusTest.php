<?php

use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Exceptions\InvalidPlantTransition;
use App\Modules\Catalogue\Exceptions\PlantNotPublishable;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Services\PlantWorkflow;
use App\Modules\Identity\Enums\Role;
use App\Modules\Identity\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

const ALLOWED_TRANSITIONS = [
    ['draft', 'in_review'],
    ['in_review', 'draft'],
    ['in_review', 'published'],
    ['published', 'draft'],
    ['published', 'archived'],
];

function plantIn(PlantStatus $status): Plant
{
    $factory = Plant::factory();

    return match ($status) {
        PlantStatus::Draft => $factory->create(),
        PlantStatus::InReview => $factory->inReview()->create(),
        PlantStatus::Published => $factory->published()->create(),
        PlantStatus::Archived => $factory->archived()->create(),
    };
}

/**
 * Every (from, to) pair of distinct states that the state model does not list.
 *
 * @return array<string, array{PlantStatus, PlantStatus}>
 */
function disallowedTransitions(): array
{
    $pairs = [];
    foreach (PlantStatus::cases() as $from) {
        foreach (PlantStatus::cases() as $to) {
            if ($from !== $to && ! in_array([$from->value, $to->value], ALLOWED_TRANSITIONS, true)) {
                $pairs["{$from->value} -> {$to->value}"] = [$from, $to];
            }
        }
    }

    return $pairs;
}

it('starts every plant as draft', function () {
    $plant = Plant::create([
        'scientific_name' => 'Solanum lycopersicum',
        'category_id' => PlantCategory::factory()->create()->id,
    ]);

    expect($plant->status)->toBe(PlantStatus::Draft)
        ->and(Plant::find($plant->id)?->status)->toBe(PlantStatus::Draft);
});

it('rejects creating a plant in any state other than draft', function (PlantStatus $status) {
    $plant = new Plant([
        'scientific_name' => 'Allium sativum',
        'category_id' => PlantCategory::factory()->create()->id,
    ]);
    $plant->status = $status;

    expect(fn () => $plant->save())->toThrow(InvalidPlantTransition::class);
    expect(Plant::count())->toBe(0);
})->with([PlantStatus::InReview, PlantStatus::Published, PlantStatus::Archived]);

it('allows exactly the transitions of the state model', function (string $from, string $to) {
    $plant = plantIn(PlantStatus::from($from));

    app(PlantWorkflow::class)->transition($plant, PlantStatus::from($to));

    expect($plant->fresh()?->status)->toBe(PlantStatus::from($to));
})->with(ALLOWED_TRANSITIONS);

it('rejects a transition not in the state model through the workflow and leaves the state unchanged', function (PlantStatus $from, PlantStatus $to) {
    $plant = plantIn($from);

    expect(fn () => app(PlantWorkflow::class)->transition($plant, $to))
        ->toThrow(InvalidPlantTransition::class);

    expect($plant->status)->toBe($from)
        ->and($plant->fresh()?->status)->toBe($from);
})->with(disallowedTransitions());

it('rejects a transition not in the state model when the status is saved directly and leaves the state unchanged', function (PlantStatus $from, PlantStatus $to) {
    $plant = plantIn($from);

    $plant->status = $to;

    expect(fn () => $plant->save())->toThrow(InvalidPlantTransition::class);

    expect($plant->status)->toBe($from)
        ->and($plant->fresh()?->status)->toBe($from);
})->with(disallowedTransitions());

it('guards a status set through forceFill as well', function () {
    $plant = plantIn(PlantStatus::Draft);

    expect(fn () => $plant->forceFill(['status' => PlantStatus::Published])->save())
        ->toThrow(InvalidPlantTransition::class);

    expect($plant->fresh()?->status)->toBe(PlantStatus::Draft);
});

it('does not publish a plant without a scientific name (UC-010)', function () {
    $plant = plantIn(PlantStatus::InReview);
    Plant::query()->whereKey($plant->id)->update(['scientific_name' => '']);
    $plant->refresh();

    expect(fn () => app(PlantWorkflow::class)->publish($plant))
        ->toThrow(PlantNotPublishable::class, 'scientific_name');

    $fresh = $plant->fresh();
    expect($plant->status)->toBe(PlantStatus::InReview)
        ->and($plant->published_at)->toBeNull()
        ->and($fresh?->status)->toBe(PlantStatus::InReview)
        ->and($fresh?->published_at)->toBeNull();
});

it('does not publish a plant whose scientific name is only whitespace', function () {
    $plant = plantIn(PlantStatus::InReview);
    $plant->scientific_name = '   ';
    $plant->status = PlantStatus::Published;

    expect(fn () => $plant->save())->toThrow(PlantNotPublishable::class);
    expect($plant->fresh()?->status)->toBe(PlantStatus::InReview);
});

it('records the reviewer and the review and publication times when publishing', function () {
    $curator = User::factory()->role(Role::Curator)->create();
    $plant = plantIn(PlantStatus::InReview);

    $this->freezeSecond();
    app(PlantWorkflow::class)->publish($plant, $curator->id);

    $fresh = $plant->fresh();
    expect($fresh?->status)->toBe(PlantStatus::Published)
        ->and($fresh?->reviewed_by)->toBe($curator->id)
        ->and($fresh?->reviewed_at?->equalTo(now()))->toBeTrue()
        ->and($fresh?->published_at?->equalTo(now()))->toBeTrue();
});
