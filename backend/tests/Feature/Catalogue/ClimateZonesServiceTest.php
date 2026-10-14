<?php

use App\Modules\Catalogue\Database\Seeders\CatalogueDemoSeeder;
use App\Modules\Catalogue\Events\ClimateZoneRulesChanged;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Services\ClimateZones;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Event;

uses(RefreshDatabase::class);

it('returns every climate zone as plain data (id, code, rules) ordered by code', function () {
    $b = ClimateZone::factory()->create(['code' => 'b_zone', 'rules' => ['elevation_m' => ['min' => 400, 'max' => null]]]);
    $a = ClimateZone::factory()->create(['code' => 'a_zone', 'rules' => []]);

    // Key order inside the rules is not kept by jsonb and does not matter.
    expect(app(ClimateZones::class)->all())->toEqual([
        ['id' => $a->id, 'code' => 'a_zone', 'rules' => []],
        ['id' => $b->id, 'code' => 'b_zone', 'rules' => ['elevation_m' => ['min' => 400, 'max' => null]]],
    ]);
});

it('emits ClimateZoneRulesChanged after commit when a zone is created, its rules change or it is deleted, not on other edits', function () {
    Event::fake([ClimateZoneRulesChanged::class]);

    $zone = ClimateZone::factory()->create(['code' => 'mild', 'rules' => ['winter_min_mean_c' => ['min' => 4, 'max' => null]]]);
    Event::assertDispatchedTimes(ClimateZoneRulesChanged::class, 1);

    $zone->update(['name_en' => 'Mild']);
    Event::assertDispatchedTimes(ClimateZoneRulesChanged::class, 1);

    DB::transaction(function () use ($zone) {
        $zone->update(['rules' => ['winter_min_mean_c' => ['min' => 5, 'max' => null]]]);
        Event::assertDispatchedTimes(ClimateZoneRulesChanged::class, 1);
    });
    Event::assertDispatchedTimes(ClimateZoneRulesChanged::class, 2);

    $zone->delete();
    Event::assertDispatchedTimes(ClimateZoneRulesChanged::class, 3);
    Event::assertDispatched(ClimateZoneRulesChanged::class, fn (ClimateZoneRulesChanged $e) => $e->climateZoneId === $zone->id);
});

it('seeds demo zone rules keyed by the cell metric winter_min_mean_c', function () {
    $this->seed(CatalogueDemoSeeder::class);

    foreach (ClimateZone::query()->get() as $zone) {
        expect($zone->rules)->toHaveKey('winter_min_mean_c')
            ->not->toHaveKey('winter_min_c');
    }
});
