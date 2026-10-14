<?php

use App\Modules\Catalogue\Database\Seeders\CatalogueDemoSeeder;
use App\Modules\Catalogue\Enums\AliasKind;
use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantTranslation;
use App\Modules\Catalogue\Models\Tip;
use App\Modules\Catalogue\Services\CatalogueSnapshots;
use App\Modules\Catalogue\Snapshot\SearchKeys;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Storage;

uses(RefreshDatabase::class);

const DEMO_PUBLISHED = [
    'Solanum lycopersicum', 'Ocimum basilicum', 'Capsicum annuum', 'Olea europaea',
    'Citrus limon', 'Lactuca sativa', 'Cucurbita pepo', 'Salvia rosmarinus',
];

const DEMO_TABLES = [
    'plant_categories', 'climate_zones', 'plants', 'plant_translations', 'plant_aliases', 'plant_calendars',
    'companions', 'care_intervals', 'plant_photos', 'fact_sources', 'tips', 'settlements', 'plant_audits',
];

beforeEach(function () {
    Storage::fake('local');
    // No external calls: any HTTP request fails the test.
    Http::preventStrayRequests();
});

/** Runs `php artisan db:seed` (DatabaseSeeder, which calls the demo seeder). */
function seedDemo(): void
{
    test()->seed();
}

/** Opens the latest catalogue snapshot (the file the app downloads). */
function latestDemoSnapshot(): PDO
{
    $snapshots = app(CatalogueSnapshots::class);
    $current = $snapshots->current();

    expect($current)->not->toBeNull();

    return new PDO('sqlite:'.$snapshots->disk()->path($current->path), options: [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
}

/**
 * Searches the snapshot like the app: normalised query words as prefixes of the search keys.
 *
 * @return list<string> Greek names
 */
function searchDemo(PDO $db, string $query): array
{
    $words = array_filter(explode(' ', SearchKeys::normalise($query)));
    $match = implode(' ', array_map(fn (string $word): string => '"'.$word.'"*', $words));
    $statement = $db->prepare(
        "SELECT t.name FROM plant_search s JOIN plant_translations t ON t.plant_id = s.plant_id AND t.lang = 'el' "
        .'WHERE plant_search MATCH ? ORDER BY t.name',
    );
    $statement->execute([$match]);

    return $statement->fetchAll(PDO::FETCH_COLUMN);
}

/**
 * @return array<string, int>
 */
function demoRowCounts(): array
{
    return collect(DEMO_TABLES)->mapWithKeys(fn (string $table): array => [$table => DB::table($table)->count()])->all();
}

it('builds a snapshot with exactly the 8 published demo plants from an empty catalogue', function () {
    expect(Plant::query()->count())->toBe(0);

    seedDemo();

    $db = latestDemoSnapshot();

    expect($db->query('SELECT scientific_name FROM plants')->fetchAll(PDO::FETCH_COLUMN))
        ->toEqualCanonicalizing(DEMO_PUBLISHED)
        ->and(Plant::query()->published()->pluck('scientific_name')->all())->toEqualCanonicalizing(DEMO_PUBLISHED)
        ->and(Plant::query()->where('scientific_name', 'Ficus carica')->value('status'))->toBe(PlantStatus::InReview)
        ->and(Plant::query()->where('scientific_name', 'Allium sativum')->value('status'))->toBe(PlantStatus::Draft);

    // The demo content is usable in the app: search by Greek, Greeklish, accent-free and English.
    expect(searchDemo($db, 'ntomata'))->toBe(['Ντομάτα'])
        ->and(searchDemo($db, 'domata'))->toBe(['Ντομάτα'])
        ->and(searchDemo($db, 'τοματα'))->toBe(['Ντομάτα'])
        ->and(searchDemo($db, 'basil'))->toBe(['Βασιλικός'])
        // In-review fig and draft garlic never reach devices.
        ->and(searchDemo($db, 'σκορδο'))->toBe([])
        ->and(searchDemo($db, 'συκια'))->toBe([])
        ->and((int) $db->query('SELECT COUNT(*) FROM climate_zones')->fetchColumn())->toBe(5)
        ->and((int) $db->query('SELECT COUNT(*) FROM settlements')->fetchColumn())->toBeGreaterThanOrEqual(5)
        ->and((int) $db->query('SELECT COUNT(*) FROM categories')->fetchColumn())->toBeGreaterThanOrEqual(3)
        ->and((int) $db->query('SELECT COUNT(*) FROM tips')->fetchColumn())->toBeGreaterThan(0)
        ->and((int) $db->query('SELECT COUNT(*) FROM companions')->fetchColumn())->toBeGreaterThan(0);
});

it('seeds complete content for every demo plant: texts, Greeklish aliases, calendars per zone, care intervals', function () {
    seedDemo();

    $zones = ClimateZone::query()->count();
    expect(Plant::query()->count())->toBe(10)
        ->and($zones)->toBeGreaterThanOrEqual(4)->toBeLessThanOrEqual(5);

    foreach (Plant::query()->with(['translations', 'aliases', 'calendars', 'careIntervals'])->get() as $plant) {
        expect($plant->translations->pluck('lang')->map->value->all())->toEqualCanonicalizing(['el', 'en'])
            ->and($plant->aliases->contains(fn ($alias) => $alias->kind === AliasKind::Greeklish))->toBeTrue()
            ->and($plant->calendars->pluck('climate_zone_id')->unique()->count())->toBeGreaterThanOrEqual(4)
            ->and($plant->careIntervals)->not->toBeEmpty();

        foreach ($plant->translations as $translation) {
            expect([$translation->planting, $translation->care, $translation->seed_saving, $translation->tips])->each->not->toBeEmpty();
        }
    }
});

it('creates no duplicate rows and no new snapshot version when it runs again', function () {
    seedDemo();
    $before = demoRowCounts();
    $statuses = Plant::query()->pluck('status', 'scientific_name')->all();
    $version = app(CatalogueSnapshots::class)->current()?->version;

    seedDemo();

    expect(demoRowCounts())->toBe($before)
        ->and(Plant::query()->pluck('status', 'scientific_name')->all())->toEqual($statuses)
        ->and(app(CatalogueSnapshots::class)->current()?->version)->toBe($version);
});

it('exits without writing any row when APP_ENV=production', function () {
    app()->detectEnvironment(fn () => 'production');
    Queue::fake();

    // Through DatabaseSeeder (what db:seed runs) and the demo seeder directly.
    app(DatabaseSeeder::class)->setContainer(app())->__invoke();
    app(CatalogueDemoSeeder::class)->setContainer(app())->__invoke();

    expect(array_sum(demoRowCounts()))->toBe(0)
        ->and(app(CatalogueSnapshots::class)->current())->toBeNull();
    Queue::assertNothingPushed();
});

it('marks every seeded climate zone, plant and tip as demo content, but not the plant names', function () {
    seedDemo();

    $marker = CatalogueDemoSeeder::DEMO_MARKER;
    expect($marker)->toBe('demo - not expert-reviewed');

    foreach (ClimateZone::query()->get() as $zone) {
        expect($zone->description)->toContain($marker);
    }

    foreach (Plant::query()->with('translations')->get() as $plant) {
        expect($plant->translations)->toHaveCount(2);
        foreach ($plant->translations as $translation) {
            expect($translation->description)->toContain($marker)
                ->and($translation->name)->not->toContain('demo');
        }
    }

    expect(PlantTranslation::query()->where('name', 'like', '%demo%')->count())->toBe(0);

    foreach (Tip::query()->get() as $tip) {
        expect($tip->text_el)->toContain($marker)->and($tip->text_en)->toContain($marker);
    }
});
