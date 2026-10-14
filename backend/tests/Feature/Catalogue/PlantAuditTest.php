<?php

use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantAudit;
use App\Modules\Catalogue\Services\PlantWorkflow;
use App\Modules\Identity\Enums\Role;
use App\Modules\Identity\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

it('records the creation of a plant with its values and the acting user', function () {
    $curator = User::factory()->role(Role::Curator)->create();
    $this->actingAs($curator);

    $plant = Plant::factory()->create(['scientific_name' => 'Ocimum basilicum', 'spacing_cm' => 30]);

    $audit = PlantAudit::query()->where('plant_id', $plant->id)->sole();
    expect($audit->event)->toBe(PlantAudit::EVENT_CREATED)
        ->and($audit->user_id)->toBe($curator->id)
        ->and($audit->changes['scientific_name'])->toEqual(['old' => null, 'new' => 'Ocimum basilicum'])
        ->and($audit->changes['status']['new'])->toBe('draft')
        ->and($audit->created_at)->not->toBeNull();
});

it('records old and new values of every changed attribute', function () {
    $plant = Plant::factory()->create(['spacing_cm' => 30, 'soil_types' => ['loam']]);
    $curator = User::factory()->role(Role::Curator)->create();
    $this->actingAs($curator);

    $plant->update(['spacing_cm' => 40, 'soil_types' => ['loam', 'sandy']]);

    $audit = PlantAudit::query()->where('plant_id', $plant->id)->where('event', PlantAudit::EVENT_UPDATED)->sole();
    expect($audit->user_id)->toBe($curator->id)
        ->and($audit->changes)->toEqual([
            'spacing_cm' => ['old' => 30, 'new' => 40],
            'soil_types' => ['old' => ['loam'], 'new' => ['loam', 'sandy']],
        ]);
});

it('records every status transition', function () {
    $plant = Plant::factory()->create();
    $workflow = app(PlantWorkflow::class);

    $this->travel(1)->minutes();
    $workflow->submitForReview($plant);
    $this->travel(1)->minutes();
    $workflow->publish($plant);
    $this->travel(1)->minutes();
    $workflow->archive($plant);

    $statuses = PlantAudit::query()
        ->where('plant_id', $plant->id)
        ->where('event', PlantAudit::EVENT_UPDATED)
        ->orderBy('created_at')
        ->get()
        ->map(fn (PlantAudit $audit) => $audit->changes['status'] ?? null)
        ->all();

    expect($statuses)->toEqual([
        ['old' => 'draft', 'new' => 'in_review'],
        ['old' => 'in_review', 'new' => 'published'],
        ['old' => 'published', 'new' => 'archived'],
    ]);
});

it('writes no audit entry for a rejected transition', function () {
    $plant = Plant::factory()->create();

    try {
        app(PlantWorkflow::class)->transition($plant, PlantStatus::Published);
    } catch (Throwable) {
    }

    expect(PlantAudit::query()->where('plant_id', $plant->id)->where('event', PlantAudit::EVENT_UPDATED)->count())->toBe(0);
});

it('keeps the audit trail when a plant is deleted', function () {
    $plant = Plant::factory()->create(['scientific_name' => 'Mentha spicata']);

    $plant->delete();

    $events = PlantAudit::query()->where('plant_id', $plant->id)->pluck('event')->all();
    $deleted = PlantAudit::query()->where('plant_id', $plant->id)->where('event', PlantAudit::EVENT_DELETED)->sole();

    expect($events)->toEqualCanonicalizing([PlantAudit::EVENT_CREATED, PlantAudit::EVENT_DELETED])
        ->and($deleted->changes['scientific_name'])->toEqual(['old' => 'Mentha spicata', 'new' => null]);
});

it('does not allow changing an audit entry', function () {
    $plant = Plant::factory()->create();
    $audit = PlantAudit::query()->where('plant_id', $plant->id)->sole();

    $audit->event = 'tampered';

    expect($audit->save())->toBeFalse()
        ->and($audit->fresh()?->event)->toBe(PlantAudit::EVENT_CREATED);
});
