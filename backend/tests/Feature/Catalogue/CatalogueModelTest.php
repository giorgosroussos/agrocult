<?php

use App\Modules\Catalogue\Enums\AliasKind;
use App\Modules\Catalogue\Enums\CalendarActivity;
use App\Modules\Catalogue\Enums\CareAction;
use App\Modules\Catalogue\Enums\CompanionRelation;
use App\Modules\Catalogue\Enums\FrostHardiness;
use App\Modules\Catalogue\Enums\Sun;
use App\Modules\Catalogue\Enums\TextLanguage;
use App\Modules\Catalogue\Enums\TipStatus;
use App\Modules\Catalogue\Models\CareInterval;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Companion;
use App\Modules\Catalogue\Models\FactSource;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantAlias;
use App\Modules\Catalogue\Models\PlantCalendar;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Models\PlantPhoto;
use App\Modules\Catalogue\Models\PlantTranslation;
use App\Modules\Catalogue\Models\Settlement;
use App\Modules\Catalogue\Models\Tip;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

uses(RefreshDatabase::class);

/**
 * A plant with one row in every child entity.
 *
 * @return array{plant: Plant, zone: ClimateZone, other: Plant}
 */
function fullPlant(): array
{
    $plant = Plant::factory()->create([
        'scientific_name' => 'Solanum lycopersicum',
        'gbif_id' => 2930137,
        'temp_min_c' => 10,
        'temp_opt_c' => 24.5,
        'temp_max_c' => 35,
        'water_need' => 4,
        'sun' => Sun::FullSun,
        'soil_types' => ['loam', 'sandy'],
        'ph_min' => 6.0,
        'ph_max' => 6.8,
        'frost_hardiness' => FrostHardiness::Tender,
        'propagation' => ['seed', 'seedling'],
        'sow_depth_cm' => 0.5,
        'spacing_cm' => 50,
        'row_spacing_cm' => 80,
        'days_to_harvest' => 75,
    ]);
    $other = Plant::factory()->create(['scientific_name' => 'Ocimum basilicum']);
    $zone = ClimateZone::factory()->create(['code' => 'coastal', 'rules' => ['min_temp_jan' => ['gte' => 8]]]);

    PlantTranslation::create(['plant_id' => $plant->id, 'lang' => TextLanguage::El, 'name' => 'Ντομάτα', 'care' => 'Πότισμα']);
    PlantTranslation::create(['plant_id' => $plant->id, 'lang' => TextLanguage::En, 'name' => 'Tomato']);
    PlantAlias::create(['plant_id' => $plant->id, 'lang' => TextLanguage::El, 'alias' => 'ntomata', 'kind' => AliasKind::Greeklish]);
    PlantCalendar::create(['plant_id' => $plant->id, 'climate_zone_id' => $zone->id, 'activity' => CalendarActivity::SowIndoors, 'month_from' => 11, 'month_to' => 2]);
    Companion::create(['plant_id' => $plant->id, 'other_plant_id' => $other->id, 'relation' => CompanionRelation::Good]);
    CareInterval::create(['plant_id' => $plant->id, 'action' => CareAction::Water, 'interval_days' => 3, 'month_from' => 5, 'month_to' => 9]);
    PlantPhoto::create(['plant_id' => $plant->id, 'file_path' => 'catalogue/tomato.webp', 'credit' => 'A. Photographer', 'licence' => 'CC BY 4.0']);
    FactSource::create(['plant_id' => $plant->id, 'field' => 'temp_opt_c', 'source_name' => 'GBIF', 'source_url' => 'https://www.gbif.org/species/2930137', 'licence' => 'CC0', 'imported_at' => now()]);

    return ['plant' => $plant, 'zone' => $zone, 'other' => $other];
}

it('creates a table for every catalogue entity with a UUID primary key (DATA-006)', function () {
    $tables = [
        'plants', 'plant_categories', 'plant_translations', 'plant_aliases', 'climate_zones', 'plant_calendars',
        'companions', 'care_intervals', 'plant_photos', 'fact_sources', 'tips', 'settlements', 'plant_audits',
    ];

    foreach ($tables as $table) {
        expect(Schema::hasTable($table))->toBeTrue("missing table {$table}");

        $id = collect(Schema::getColumns($table))->firstWhere('name', 'id');
        expect($id['type_name'] ?? null)->toBe('uuid', "{$table}.id is not a uuid");
    }
});

it('stores plant timestamps as timestamptz in UTC', function () {
    foreach (['reviewed_at', 'published_at', 'updated_at'] as $column) {
        $type = collect(Schema::getColumns('plants'))->firstWhere('name', $column)['type_name'] ?? null;
        expect($type)->toBe('timestamptz');
    }

    expect(config('app.timezone'))->toBe('UTC');
});

it('stores every attribute of a plant and its related entities', function () {
    ['plant' => $plant, 'zone' => $zone, 'other' => $other] = fullPlant();

    $fresh = Plant::with(['category', 'translations', 'aliases', 'calendars.climateZone', 'companions.otherPlant', 'careIntervals', 'photos', 'factSources'])
        ->findOrFail($plant->id);

    expect(Str::isUuid($fresh->id))->toBeTrue()
        ->and($fresh->gbif_id)->toBe(2930137)
        ->and($fresh->temp_opt_c)->toBe('24.5')
        ->and($fresh->sun)->toBe(Sun::FullSun)
        ->and($fresh->frost_hardiness)->toBe(FrostHardiness::Tender)
        ->and($fresh->soil_types)->toBe(['loam', 'sandy'])
        ->and($fresh->propagation)->toBe(['seed', 'seedling'])
        ->and($fresh->sow_depth_cm)->toBe('0.5')
        ->and($fresh->days_to_harvest)->toBe(75)
        ->and($fresh->updated_at)->not->toBeNull()
        ->and($fresh->category)->toBeInstanceOf(PlantCategory::class)
        ->and($fresh->translations->pluck('name', 'lang.value')->all())->toBe(['el' => 'Ντομάτα', 'en' => 'Tomato'])
        ->and($fresh->aliases->first()?->kind)->toBe(AliasKind::Greeklish)
        ->and($fresh->calendars->first()?->climateZone?->is($zone))->toBeTrue()
        ->and($fresh->calendars->first()?->month_to)->toBe(2)
        ->and($fresh->companions->first()?->otherPlant?->is($other))->toBeTrue()
        ->and($fresh->careIntervals->first()?->action)->toBe(CareAction::Water)
        ->and($fresh->photos->first()?->licence)->toBe('CC BY 4.0')
        ->and($fresh->factSources->first()?->source_name)->toBe('GBIF');

    expect(ClimateZone::find($zone->id)?->rules)->toBe(['min_temp_jan' => ['gte' => 8]]);
});

it('deletes the texts, aliases, calendar, companions, care intervals, photos and fact sources with the plant', function () {
    ['plant' => $plant, 'zone' => $zone] = fullPlant();

    $plant->delete();

    foreach ([PlantTranslation::class, PlantAlias::class, PlantCalendar::class, Companion::class, CareInterval::class, PlantPhoto::class, FactSource::class] as $model) {
        expect($model::query()->where('plant_id', $plant->id)->count())->toBe(0, "{$model} rows were kept");
    }

    expect(ClimateZone::find($zone->id))->not->toBeNull();
});

it('does not delete a category that still has plants', function () {
    $plant = Plant::factory()->create();

    expect(fn () => DB::transaction(fn () => $plant->category->delete()))->toThrow(QueryException::class);
    expect(PlantCategory::find($plant->category_id))->not->toBeNull();
});

it('keeps categories as curator-managed data with an optional parent (DATA-004)', function () {
    $parent = PlantCategory::factory()->create(['code' => 'vegetables', 'name_el' => 'Λαχανικά', 'name_en' => 'Vegetables']);
    $child = PlantCategory::factory()->create(['code' => 'fruiting', 'parent_id' => $parent->id, 'sort_order' => 2]);

    expect($child->parent?->is($parent))->toBeTrue()
        ->and($parent->children->pluck('id')->all())->toBe([$child->id])
        ->and(PlantCategory::count())->toBe(2);
});

it('rejects duplicate unique values', function (Closure $duplicate) {
    $plant = Plant::factory()->create(['scientific_name' => 'Allium sativum', 'gbif_id' => 2856681]);
    PlantCategory::factory()->create(['code' => 'herbs']);
    ClimateZone::factory()->create(['code' => 'mountain']);
    PlantTranslation::create(['plant_id' => $plant->id, 'lang' => TextLanguage::El, 'name' => 'Σκόρδο']);

    expect(fn () => DB::transaction(fn () => $duplicate($plant)))->toThrow(QueryException::class);
})->with([
    'scientific name' => fn (Plant $p) => Plant::factory()->create(['scientific_name' => 'Allium sativum']),
    'gbif id' => fn (Plant $p) => Plant::factory()->create(['gbif_id' => 2856681]),
    'category code' => fn (Plant $p) => PlantCategory::factory()->create(['code' => 'herbs']),
    'climate zone code' => fn (Plant $p) => ClimateZone::factory()->create(['code' => 'mountain']),
    'translation per language' => fn (Plant $p) => PlantTranslation::create(['plant_id' => $p->id, 'lang' => TextLanguage::El, 'name' => 'Άλλο']),
]);

it('rejects values outside the ranges of the data model', function (Closure $invalid) {
    $plant = Plant::factory()->create();
    $zone = ClimateZone::factory()->create();

    expect(fn () => DB::transaction(fn () => $invalid($plant, $zone)))->toThrow(QueryException::class);
})->with([
    'calendar month 13' => fn (Plant $p, ClimateZone $z) => PlantCalendar::create(['plant_id' => $p->id, 'climate_zone_id' => $z->id, 'activity' => CalendarActivity::Harvest, 'month_from' => 6, 'month_to' => 13]),
    'calendar month 0' => fn (Plant $p, ClimateZone $z) => PlantCalendar::create(['plant_id' => $p->id, 'climate_zone_id' => $z->id, 'activity' => CalendarActivity::Harvest, 'month_from' => 0, 'month_to' => 3]),
    'care interval of 0 days' => fn (Plant $p, ClimateZone $z) => CareInterval::create(['plant_id' => $p->id, 'action' => CareAction::Water, 'interval_days' => 0]),
    'tip month 13' => fn (Plant $p, ClimateZone $z) => Tip::create(['text_el' => 'α', 'text_en' => 'a', 'month_from' => 13]),
    'water need 6' => fn (Plant $p, ClimateZone $z) => $p->update(['water_need' => 6]),
    'companion of itself' => fn (Plant $p, ClimateZone $z) => Companion::create(['plant_id' => $p->id, 'other_plant_id' => $p->id, 'relation' => CompanionRelation::Bad]),
]);

it('rejects enum values that are not in the data model', function () {
    $plant = Plant::factory()->create();

    expect(fn () => PlantAlias::create(['plant_id' => $plant->id, 'alias' => 'x', 'kind' => 'nickname']))
        ->toThrow(ValueError::class);
});

it('includes only published plants in the catalogue query (ARCH-003, UC-010)', function () {
    $draft = Plant::factory()->create();
    $inReview = Plant::factory()->inReview()->create();
    $published = Plant::factory()->published()->create();
    $archived = Plant::factory()->archived()->create();

    $ids = Plant::query()->published()->pluck('id')->all();

    expect($ids)->toBe([$published->id])
        ->not->toContain($draft->id)
        ->not->toContain($inReview->id)
        ->not->toContain($archived->id);
});

it('includes only published tips in the catalogue query (ARCH-003)', function () {
    $draft = Tip::create(['text_el' => 'Πρόχειρο', 'text_en' => 'Draft']);
    $published = Tip::create(['text_el' => 'Σπείρετε σκόρδο', 'text_en' => 'Sow garlic', 'month_from' => 10, 'month_to' => 12, 'status' => TipStatus::Published]);

    expect($draft->fresh()?->status)->toBe(TipStatus::Draft)
        ->and(Tip::query()->published()->pluck('id')->all())->toBe([$published->id]);
});

it('stores settlements with coordinates', function () {
    $settlement = Settlement::create(['name_el' => 'Ναύπλιο', 'name_en' => 'Nafplio', 'region' => 'Πελοπόννησος', 'lat' => 37.567, 'lon' => 22.8]);

    expect($settlement->fresh()?->lat)->toBe('37.567000')
        ->and($settlement->fresh()?->lon)->toBe('22.800000');
});
