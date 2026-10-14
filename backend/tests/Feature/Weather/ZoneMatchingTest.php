<?php

use App\Modules\Catalogue\Filament\Resources\ClimateZones\Pages\EditClimateZone;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Identity\Enums\Role;
use App\Modules\Identity\Filament\AdminPanelProvider;
use App\Modules\Identity\Models\User;
use App\Modules\Weather\Climate\ClimateMetrics;
use App\Modules\Weather\Climate\ZoneMatcher;
use App\Modules\Weather\Events\CellZoneChanged;
use App\Modules\Weather\Jobs\ReassignCellZones;
use App\Modules\Weather\Models\WeatherCell;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Queue;
use Livewire\Livewire;

uses(RefreshDatabase::class);

/**
 * @param  array<string, array<string, mixed>>  $zones  code => rules
 * @return list<array{id: string, code: string, rules: array<string, mixed>}>
 */
function zoneRules(array $zones): array
{
    return array_map(fn (string $code) => ['id' => "id-{$code}", 'code' => $code, 'rules' => $zones[$code]], array_keys($zones));
}

function cellMetrics(float $winter = 6.0, int $elevation = 100, ?int $last = null, ?int $first = null): ClimateMetrics
{
    return new ClimateMetrics($elevation, $winter, $last, $first);
}

// --- Matching (DATA-009) ---

it('gives a cell with winter_min_mean_c 8 zone A (min 8), not zone B (min 4, max 8): min inclusive, max exclusive', function (string $codeA, string $codeB) {
    $zones = zoneRules([
        $codeA => ['winter_min_mean_c' => ['min' => 8, 'max' => null]],
        $codeB => ['winter_min_mean_c' => ['min' => 4, 'max' => 8]],
    ]);

    $matcher = new ZoneMatcher;

    expect($matcher->nearest(cellMetrics(8.0), $zones))->toBe("id-{$codeA}")
        ->and($matcher->nearest(cellMetrics(7.99), $zones))->toBe("id-{$codeB}")
        ->and($matcher->nearest(cellMetrics(4.0), $zones))->toBe("id-{$codeB}");
})->with([
    'A sorts first' => ['a', 'b'],
    'B sorts first' => ['z', 'b'],
]);

it('gives a cell that matches no zone the zone with the smallest distance outside the bounds', function () {
    $zones = zoneRules([
        'coast' => ['winter_min_mean_c' => ['min' => 4, 'max' => null], 'elevation_m' => ['min' => null, 'max' => 300]],
        'hills' => ['winter_min_mean_c' => ['min' => 0, 'max' => 4], 'elevation_m' => ['min' => 400, 'max' => 800]],
        'mountain' => ['winter_min_mean_c' => ['min' => null, 'max' => -3], 'elevation_m' => ['min' => 800, 'max' => null]],
    ]);

    // 6 °C at 500 m: coast is 200 m away, hills 2 °C away, mountain 300 m + 9 °C away.
    expect((new ZoneMatcher)->nearest(cellMetrics(6.0, 500), $zones))->toBe('id-hills');
});

it('breaks a distance tie by the lowest code', function () {
    $zones = zoneRules([
        'warm' => ['winter_min_mean_c' => ['min' => 8, 'max' => null]],
        'cold' => ['winter_min_mean_c' => ['min' => null, 'max' => 4]],
    ]);

    // 6 °C is 2 °C from both.
    expect((new ZoneMatcher)->nearest(cellMetrics(6.0), $zones))->toBe('id-cold');
});

it('treats null bounds as unbounded and ignores unknown keys and malformed rules', function () {
    $zones = zoneRules([
        'a' => ['placeholder' => true, 'winter_min_c' => ['min' => 50, 'max' => null], 'winter_min_mean_c' => ['min' => null, 'max' => null]],
        'b' => ['elevation_m' => 'high', 'winter_min_mean_c' => ['min' => 'x']],
    ]);

    expect((new ZoneMatcher)->distance(cellMetrics()->toArray(), $zones[0]['rules']))->toBe([0.0, true])
        ->and((new ZoneMatcher)->distance(cellMetrics()->toArray(), $zones[1]['rules']))->toBe([0.0, true])
        ->and((new ZoneMatcher)->nearest(cellMetrics(), $zones))->toBe('id-a');
});

it('counts a null last frost as day 0 and a null first frost as day 366 for matching only', function () {
    $zones = zoneRules([
        'frosty' => ['last_frost_doy' => ['min' => 30, 'max' => null], 'first_frost_doy' => ['min' => null, 'max' => 340]],
        'frostless' => ['last_frost_doy' => ['min' => null, 'max' => 1], 'first_frost_doy' => ['min' => 366, 'max' => null]],
    ]);

    expect((new ZoneMatcher)->nearest(cellMetrics(last: null, first: null), $zones))->toBe('id-frostless')
        ->and((new ZoneMatcher)->nearest(cellMetrics(last: 60, first: 320), $zones))->toBe('id-frosty');
});

// --- Re-assignment after a rule change (DATA-009) ---

it('re-assigns all cells in a queued job when a curator changes zone rules, emitting CellZoneChanged only for cells whose zone changed', function () {
    $mild = ClimateZone::factory()->create(['code' => 'mild', 'rules' => ['winter_min_mean_c' => ['min' => 4, 'max' => null]]]);
    $cold = ClimateZone::factory()->create(['code' => 'cold', 'rules' => ['winter_min_mean_c' => ['min' => null, 'max' => 4]]]);

    $warmCell = WeatherCell::factory()->withMetrics(winterMin: 9.0)->create(['climate_zone_id' => $mild->id]);
    $coolCell = WeatherCell::factory()->withMetrics(winterMin: 5.0)->create(['climate_zone_id' => $mild->id]);
    $coldCell = WeatherCell::factory()->withMetrics(winterMin: 1.0)->create(['climate_zone_id' => $cold->id]);
    $pending = WeatherCell::factory()->create();

    Queue::fake();
    Filament::setCurrentPanel(Filament::getPanel(AdminPanelProvider::ID));
    $totp = Filament::getPanel(AdminPanelProvider::ID)->getMultiFactorAuthenticationProviders()['app'];
    $this->actingAs(User::factory()->role(Role::Curator)->withAppAuthentication($totp->generateSecret())->create());

    // The curator moves the boundary from 4 °C to 6 °C.
    Livewire::test(EditClimateZone::class, ['record' => $cold->getRouteKey()])
        ->fillForm(['rules' => '{"winter_min_mean_c": {"min": null, "max": 6}}'])
        ->call('save')
        ->assertHasNoFormErrors();
    $mild->update(['rules' => ['winter_min_mean_c' => ['min' => 6, 'max' => null]]]);

    // Queued, not done inline: nothing changed yet.
    Queue::assertPushed(ReassignCellZones::class);
    expect($coolCell->fresh()?->climate_zone_id)->toBe($mild->id);

    Event::fake([CellZoneChanged::class]);
    app()->call([new ReassignCellZones, 'handle']);

    expect($warmCell->fresh()?->climate_zone_id)->toBe($mild->id)
        ->and($coolCell->fresh()?->climate_zone_id)->toBe($cold->id)
        ->and($coldCell->fresh()?->climate_zone_id)->toBe($cold->id)
        ->and($pending->fresh()?->climate_zone_id)->toBeNull();

    Event::assertDispatchedTimes(CellZoneChanged::class, 1);
    Event::assertDispatched(CellZoneChanged::class, fn (CellZoneChanged $e) => $e->weatherCellId === $coolCell->id
        && $e->previousClimateZoneId === $mild->id && $e->climateZoneId === $cold->id);
});

it('does not queue a re-assignment when a zone is edited without changing its rules', function () {
    $zone = ClimateZone::factory()->create(['code' => 'mild', 'rules' => ['winter_min_mean_c' => ['min' => 4, 'max' => null]]]);

    Queue::fake();
    $zone->update(['name_en' => 'Mild lowlands']);

    Queue::assertNotPushed(ReassignCellZones::class);
});

it('re-assigns the cells of a deleted zone to the nearest remaining zone', function () {
    $mild = ClimateZone::factory()->create(['code' => 'mild', 'rules' => ['winter_min_mean_c' => ['min' => 4, 'max' => null]]]);
    $cold = ClimateZone::factory()->create(['code' => 'cold', 'rules' => ['winter_min_mean_c' => ['min' => null, 'max' => 4]]]);
    $cell = WeatherCell::factory()->withMetrics(winterMin: 1.0)->create(['climate_zone_id' => $cold->id]);

    Event::fake([CellZoneChanged::class]);
    $cold->delete();

    expect($cell->fresh()?->climate_zone_id)->toBe($mild->id);
    Event::assertDispatched(CellZoneChanged::class, fn (CellZoneChanged $e) => $e->weatherCellId === $cell->id && $e->climateZoneId === $mild->id);
});
