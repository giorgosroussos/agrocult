<?php

use App\Modules\Catalogue\Enums\AliasKind;
use App\Modules\Catalogue\Enums\CalendarActivity;
use App\Modules\Catalogue\Enums\CompanionRelation;
use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Enums\TipStatus;
use App\Modules\Catalogue\Exceptions\InvalidPlantTransition;
use App\Modules\Catalogue\Exceptions\PlantSourceUnavailable;
use App\Modules\Catalogue\Import\DraftFacts;
use App\Modules\Catalogue\Import\PlantSource;
use App\Modules\Catalogue\Import\PlantSourceImporter;
use App\Modules\Catalogue\Import\SettlementImporter;
use App\Modules\Catalogue\Jobs\BuildCatalogueSnapshot;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Models\Tip;
use App\Modules\Catalogue\Services\CatalogueSnapshots;
use App\Modules\Catalogue\Services\PlantWorkflow;
use App\Modules\Catalogue\Snapshot\SearchKeys;
use App\Modules\Catalogue\Snapshot\SnapshotWriter;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Bus;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

uses(RefreshDatabase::class);

beforeEach(function () {
    Storage::fake('local');
    Http::preventStrayRequests();

    $this->vegetables = PlantCategory::factory()->create(['code' => 'vegetables', 'name_el' => 'Λαχανικά', 'name_en' => 'Vegetables']);
    $this->herbs = PlantCategory::factory()->create(['code' => 'herbs', 'name_el' => 'Αρωματικά', 'name_en' => 'Herbs']);
});

/**
 * A plant with Greek and English names and optional aliases, walked to the given state.
 *
 * @param  list<array{0: string, 1: string|null}>  $aliases  [alias, lang]
 */
function snapshotPlant(string $scientific, string $el, string $en, PlantCategory $category, PlantStatus $status = PlantStatus::Published, array $aliases = []): Plant
{
    $plant = Plant::factory()->create(['scientific_name' => $scientific, 'category_id' => $category->id]);
    $plant->translations()->create(['lang' => 'el', 'name' => $el, 'description' => "Περιγραφή: {$el}"]);
    $plant->translations()->create(['lang' => 'en', 'name' => $en, 'description' => "About {$en}"]);

    foreach ($aliases as [$alias, $lang]) {
        $plant->aliases()->create(['alias' => $alias, 'lang' => $lang, 'kind' => AliasKind::Synonym]);
    }

    $workflow = app(PlantWorkflow::class);
    $path = match ($status) {
        PlantStatus::Draft => [],
        PlantStatus::InReview => [PlantStatus::InReview],
        PlantStatus::Published => [PlantStatus::InReview, PlantStatus::Published],
        PlantStatus::Archived => [PlantStatus::InReview, PlantStatus::Published, PlantStatus::Archived],
    };

    foreach ($path as $to) {
        $workflow->transition($plant, $to);
    }

    return $plant->refresh();
}

/** Downloads the current snapshot like the app does (no account) and opens it. */
function downloadSnapshot(TestCase $test): PDO
{
    $version = $test->getJson('/api/v1/catalogue/version')->assertOk()->json();
    $response = $test->get(parse_url($version['download_url'], PHP_URL_PATH))->assertOk();

    $file = tempnam(sys_get_temp_dir(), 'snapshot-test-');
    file_put_contents($file, $response->streamedContent());

    expect(hash_file('sha256', $file))->toBe($version['sha256'])
        ->and(filesize($file))->toBe($version['size']);

    return new PDO('sqlite:'.$file, options: [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
}

/**
 * Searches the local snapshot like the app does: normalise the query with the snapshot's
 * rules and match every query word as a prefix of a search key.
 *
 * @return list<string> Greek names of the matching plants
 */
function searchSnapshot(PDO $db, string $query): array
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
 * The 'in season now' filter on the local snapshot: plants whose sowing months in the
 * garden's climate zone include the month (ranges may wrap around the new year).
 *
 * @return list<string> scientific names
 */
function inSeason(PDO $db, string $climateZoneId, int $month): array
{
    $statement = $db->prepare(
        'SELECT DISTINCT p.scientific_name FROM plants p JOIN plant_calendars c ON c.plant_id = p.id '
        ."WHERE c.climate_zone_id = :zone AND c.activity IN ('sow_indoors', 'sow_outdoors') "
        .'AND ((c.month_from <= c.month_to AND :m1 BETWEEN c.month_from AND c.month_to) '
        .'OR (c.month_from > c.month_to AND (:m2 >= c.month_from OR :m3 <= c.month_to))) ORDER BY p.scientific_name',
    );
    $statement->execute(['zone' => $climateZoneId, 'm1' => $month, 'm2' => $month, 'm3' => $month]);

    return $statement->fetchAll(PDO::FETCH_COLUMN);
}

/**
 * @return list<string>
 */
function column(PDO $db, string $sql): array
{
    return $db->query($sql)->fetchAll(PDO::FETCH_COLUMN);
}

function standardCatalogue(): void
{
    $vegetables = PlantCategory::query()->where('code', 'vegetables')->firstOrFail();
    $herbs = PlantCategory::query()->where('code', 'herbs')->firstOrFail();

    snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $vegetables);
    snapshotPlant('Mentha spicata', 'Δυόσμος', 'Spearmint', $herbs, aliases: [['ηδύοσμος', 'el']]);
    snapshotPlant('Ocimum basilicum', 'Βασιλικός', 'Basil', $herbs);
    snapshotPlant('Allium sativum', 'Σκόρδο', 'Garlic', $vegetables);
}

// --- Phase AC and UC-010: only published content -------------------------------------------

it('contains exactly the published plants when built from 3 published plants and 1 draft (ARCH-003, UC-010)', function () {
    $published = [
        snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables),
        snapshotPlant('Ocimum basilicum', 'Βασιλικός', 'Basil', $this->herbs),
        snapshotPlant('Allium sativum', 'Σκόρδο', 'Garlic', $this->vegetables),
    ];
    $draft = snapshotPlant('Cucumis sativus', 'Αγγούρι', 'Cucumber', $this->vegetables, PlantStatus::Draft, [['αγγουράκι', 'el']]);

    $db = downloadSnapshot($this);

    expect(column($db, 'SELECT id FROM plants ORDER BY scientific_name'))
        ->toEqualCanonicalizing(array_map(fn (Plant $plant) => $plant->id, $published))
        ->and(column($db, "SELECT plant_id FROM plant_translations WHERE plant_id = '{$draft->id}'"))->toBe([])
        ->and(column($db, "SELECT plant_id FROM plant_aliases WHERE plant_id = '{$draft->id}'"))->toBe([])
        ->and(column($db, "SELECT plant_id FROM plant_search WHERE plant_id = '{$draft->id}'"))->toBe([])
        ->and(searchSnapshot($db, 'αγγουρι'))->toBe([]);
});

it('leaves out plants in review or archived and everything that belongs to them', function () {
    $tomato = snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables);
    $inReview = snapshotPlant('Cucumis sativus', 'Αγγούρι', 'Cucumber', $this->vegetables, PlantStatus::InReview);
    $archived = snapshotPlant('Pisum sativum', 'Μπιζέλι', 'Pea', $this->vegetables, PlantStatus::Archived);
    $zone = ClimateZone::factory()->create();

    foreach ([$tomato, $inReview, $archived] as $plant) {
        $plant->calendars()->create(['climate_zone_id' => $zone->id, 'activity' => CalendarActivity::SowOutdoors, 'month_from' => 3, 'month_to' => 5]);
        $plant->careIntervals()->create(['action' => 'water', 'interval_days' => 3]);
        $plant->photos()->create(['file_path' => 'catalogue/photos/x.jpg', 'credit' => 'Curator', 'licence' => 'CC BY 4.0']);
        $plant->factSources()->create(['field' => 'gbif_id', 'source_name' => 'GBIF', 'licence' => 'CC BY 4.0', 'imported_at' => now()]);
    }
    $tomato->companions()->create(['other_plant_id' => $archived->id, 'relation' => CompanionRelation::Good]);
    $archived->companions()->create(['other_plant_id' => $tomato->id, 'relation' => CompanionRelation::Bad]);
    app(CatalogueSnapshots::class)->rebuild();

    $db = downloadSnapshot($this);

    foreach (['plant_calendars', 'care_intervals', 'plant_photos', 'fact_sources'] as $table) {
        expect(column($db, "SELECT DISTINCT plant_id FROM {$table}"))->toBe([$tomato->id]);
    }

    expect(column($db, 'SELECT id FROM plants'))->toBe([$tomato->id])
        ->and(column($db, 'SELECT id FROM companions'))->toBe([]);
});

it('contains only published tips, and no tip of a plant that is not published (ARCH-003)', function () {
    $tomato = snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables);
    $draft = snapshotPlant('Cucumis sativus', 'Αγγούρι', 'Cucumber', $this->vegetables, PlantStatus::Draft);

    $general = Tip::query()->create(['text_el' => 'Ποτίστε νωρίς', 'text_en' => 'Water early', 'status' => TipStatus::Published]);
    $ofTomato = Tip::query()->create(['text_el' => 'Δέστε τις ντομάτες', 'text_en' => 'Stake tomatoes', 'plant_id' => $tomato->id, 'status' => TipStatus::Published]);
    Tip::query()->create(['text_el' => 'Πρόχειρο', 'text_en' => 'Draft', 'status' => TipStatus::Draft]);
    Tip::query()->create(['text_el' => 'Αγγούρια', 'text_en' => 'Cucumbers', 'plant_id' => $draft->id, 'status' => TipStatus::Published]);

    expect(column(downloadSnapshot($this), 'SELECT id FROM tips'))->toEqualCanonicalizing([$general->id, $ofTomato->id]);
});

it('ships plant fields, texts, categories, climate zones and settlements but no curator-only data', function () {
    $zone = ClimateZone::factory()->create(['code' => 'coastal', 'rules' => ['frost_days' => 'rare']]);
    $tomato = snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables);
    $tomato->update(['temp_min_c' => 10.5, 'water_need' => 4, 'soil_types' => ['loam'], 'spacing_cm' => 50]);
    app(SettlementImporter::class)->replace([['name_el' => 'Καλαμάτα', 'name_en' => 'Kalamata', 'region' => 'Πελοπόννησος', 'lat' => 37.0389, 'lon' => 22.1142]]);

    $db = downloadSnapshot($this);
    $plant = $db->query('SELECT * FROM plants')->fetch(PDO::FETCH_ASSOC);

    expect($plant)->toMatchArray(['scientific_name' => 'Solanum lycopersicum', 'temp_min_c' => 10.5, 'water_need' => 4, 'soil_types' => '["loam"]', 'spacing_cm' => 50])
        ->and($plant)->not->toHaveKeys(['status', 'reviewed_by', 'reviewed_at'])
        ->and($plant['published_at'])->toEndWith('Z')
        ->and(column($db, "SELECT description FROM plant_translations WHERE lang = 'el'"))->toBe(['Περιγραφή: Ντομάτα'])
        ->and(column($db, 'SELECT code FROM categories ORDER BY code'))->toBe(['herbs', 'vegetables'])
        ->and(column($db, 'SELECT rules FROM climate_zones'))->toBe(['{"frost_days":"rare"}'])
        ->and(column($db, 'SELECT name_el FROM settlements'))->toBe(['Καλαμάτα'])
        ->and(column($db, "SELECT settlement_id FROM settlement_search WHERE settlement_search MATCH '\"kalam\"*'"))->toHaveCount(1)
        ->and($db->query('PRAGMA table_info(plant_photos)')->fetchAll(PDO::FETCH_COLUMN, 1))->not->toContain('file_path')
        ->and((int) $db->query('PRAGMA user_version')->fetchColumn())->toBe(SnapshotWriter::SCHEMA_VERSION)
        ->and(column($db, "SELECT value FROM meta WHERE key = 'version'"))->toBe([(string) app(CatalogueSnapshots::class)->current()->version]);

    expect($zone->id)->toBeIn(column($db, 'SELECT id FROM climate_zones'));
});

// --- UC-003 search on the snapshot ----------------------------------------------------------

it('finds Ντομάτα when searching τοματα (UC-003)', function () {
    standardCatalogue();

    expect(searchSnapshot(downloadSnapshot($this), 'τοματα'))->toBe(['Ντομάτα']);
});

it('finds Ντομάτα when searching the Greeklish ntomata or domata (UC-003)', function (string $query) {
    standardCatalogue();

    expect(searchSnapshot(downloadSnapshot($this), $query))->toBe(['Ντομάτα']);
})->with(['ntomata', 'domata', 'NTOMATA', 'ntom', 'Ντομάτα', 'ντοματα']);

it('finds Δυόσμος through its alias ηδύοσμος when searching ηδυοσμος (UC-003)', function (string $query) {
    standardCatalogue();

    expect(searchSnapshot(downloadSnapshot($this), $query))->toBe(['Δυόσμος']);
})->with(['ηδυοσμος', 'ηδύοσμος', 'idyosmos', 'dyosmos']);

it('finds Βασιλικός when searching the English name basil, whatever the UI language (UC-003)', function () {
    standardCatalogue();
    app()->setLocale('el');

    expect(searchSnapshot(downloadSnapshot($this), 'basil'))->toBe(['Βασιλικός']);
});

it('finds plants by scientific name, and nothing for a name not in the catalogue (UC-003)', function () {
    standardCatalogue();
    $db = downloadSnapshot($this);

    expect(searchSnapshot($db, 'allium'))->toBe(['Σκόρδο'])
        ->and(searchSnapshot($db, 'μελιτζανα'))->toBe([])
        ->and(searchSnapshot($db, 'τοματα'))->not->toContain('Βασιλικός');
});

it('searches the local snapshot for σκόρδο without any network request once it is on the device (UC-003)', function () {
    standardCatalogue();
    $db = downloadSnapshot($this);

    Http::fake();

    expect(searchSnapshot($db, 'σκόρδο'))->toBe(['Σκόρδο']);
    Http::assertNothingSent();
});

it('lets a visitor without an account get the version and the snapshot and search and filter it (UC-003, SCOPE-002)', function () {
    standardCatalogue();

    $this->assertGuest();
    $this->getJson('/api/v1/catalogue/version')->assertOk()->assertJsonStructure(['version', 'schema_version', 'built_at', 'size', 'sha256', 'download_url']);
    $db = downloadSnapshot($this);

    $herbs = $db->prepare('SELECT t.name FROM plants p JOIN categories c ON c.id = p.category_id '
        ."JOIN plant_translations t ON t.plant_id = p.id AND t.lang = 'el' WHERE c.code = ? ORDER BY t.name");
    $herbs->execute(['herbs']);

    expect(searchSnapshot($db, 'σκορδο'))->toBe(['Σκόρδο'])
        ->and($herbs->fetchAll(PDO::FETCH_COLUMN))->toBe(['Βασιλικός', 'Δυόσμος']);
});

it('lists garlic under in season now for a garden in a climate zone whose garlic sowing months include the current month (UC-003)', function () {
    standardCatalogue();
    $coastal = ClimateZone::factory()->create(['code' => 'coastal']);
    $mountain = ClimateZone::factory()->create(['code' => 'mountain']);
    $garlic = Plant::query()->where('scientific_name', 'Allium sativum')->firstOrFail();
    $garlic->calendars()->create(['climate_zone_id' => $coastal->id, 'activity' => CalendarActivity::SowOutdoors, 'month_from' => 10, 'month_to' => 1]);
    $garlic->calendars()->create(['climate_zone_id' => $mountain->id, 'activity' => CalendarActivity::SowOutdoors, 'month_from' => 3, 'month_to' => 4]);
    $garlic->calendars()->create(['climate_zone_id' => $mountain->id, 'activity' => CalendarActivity::Harvest, 'month_from' => 11, 'month_to' => 12]);

    $this->travelTo(now()->setDate(2026, 11, 14));
    $db = downloadSnapshot($this);

    expect(inSeason($db, $coastal->id, now()->month))->toBe(['Allium sativum'])
        ->and(inSeason($db, $coastal->id, 1))->toBe(['Allium sativum'])
        ->and(inSeason($db, $coastal->id, 6))->toBe([])
        ->and(inSeason($db, $mountain->id, now()->month))->toBe([]);
});

// --- Versions and download --------------------------------------------------------------------

it('builds a new version when a plant is published and serves it for download', function () {
    snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables);
    $first = $this->getJson('/api/v1/catalogue/version')->assertOk()->assertHeader('Cache-Control', 'no-cache, private');

    snapshotPlant('Allium sativum', 'Σκόρδο', 'Garlic', $this->vegetables);
    $second = $this->getJson('/api/v1/catalogue/version')->assertOk();

    expect($second->json('version'))->toBe($first->json('version') + 1)
        ->and($second->json('schema_version'))->toBe(SnapshotWriter::SCHEMA_VERSION)
        ->and($second->json('download_url'))->toEndWith('/api/v1/catalogue/snapshots/'.$second->json('version'));

    $download = $this->get('/api/v1/catalogue/snapshots/'.$second->json('version'))->assertOk()
        ->assertHeader('Content-Type', 'application/vnd.sqlite3')
        ->assertHeader('X-Catalogue-Version', (string) $second->json('version'));

    expect(hash('sha256', $download->streamedContent()))->toBe($second->json('sha256'))
        ->and($download->headers->get('Cache-Control'))->toContain('immutable');
});

it('keeps the version when the published content did not change', function () {
    snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables);
    $before = app(CatalogueSnapshots::class)->current();

    $after = app(CatalogueSnapshots::class)->rebuild();
    snapshotPlant('Cucumis sativus', 'Αγγούρι', 'Cucumber', $this->vegetables, PlantStatus::InReview);

    expect($after->version)->toBe($before->version)
        ->and(app(CatalogueSnapshots::class)->current()->version)->toBe($before->version);
});

it('removes a plant from the next version when it goes back to draft or is archived', function (PlantStatus $to) {
    $tomato = snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables);
    snapshotPlant('Allium sativum', 'Σκόρδο', 'Garlic', $this->vegetables);

    app(PlantWorkflow::class)->transition($tomato, $to);

    expect(column(downloadSnapshot($this), 'SELECT scientific_name FROM plants'))->toBe(['Allium sativum']);
})->with([PlantStatus::Draft, PlantStatus::Archived]);

it('rebuilds when published content is edited but not when a draft is edited', function () {
    $tomato = snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables);
    $draft = snapshotPlant('Cucumis sativus', 'Αγγούρι', 'Cucumber', $this->vegetables, PlantStatus::Draft);

    Bus::fake([BuildCatalogueSnapshot::class]);

    $draft->update(['spacing_cm' => 40]);
    $draft->aliases()->create(['alias' => 'agouri', 'kind' => AliasKind::Greeklish]);
    Bus::assertNotDispatched(BuildCatalogueSnapshot::class);

    $tomato->aliases()->create(['alias' => 'τομάτα', 'lang' => 'el', 'kind' => AliasKind::LocalName]);
    Bus::assertDispatched(BuildCatalogueSnapshot::class);
});

it('keeps the last versions downloadable and answers older or unknown versions with a problem document', function () {
    config(['catalogue.snapshot.keep' => 2]);

    foreach (['Allium sativum', 'Allium cepa', 'Allium porrum'] as $i => $name) {
        snapshotPlant($name, "Φυτό {$i}", "Plant {$i}", $this->vegetables);
    }

    expect(app(CatalogueSnapshots::class)->current()->version)->toBe(3);
    $this->get('/api/v1/catalogue/snapshots/3')->assertOk();
    $this->get('/api/v1/catalogue/snapshots/2')->assertOk();

    foreach ([1, 99] as $version) {
        $this->getJson('/api/v1/catalogue/snapshots/'.$version)->assertNotFound()
            ->assertHeader('Content-Type', 'application/problem+json')
            ->assertJson(['status' => 404]);
    }
});

it('answers the version request with a problem document while no snapshot exists', function () {
    $this->getJson('/api/v1/catalogue/version')->assertNotFound()
        ->assertHeader('Content-Type', 'application/problem+json')
        ->assertJson(['status' => 404, 'title' => 'Not Found']);
});

it('keeps the previous snapshot when a build fails', function () {
    snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables);
    $before = app(CatalogueSnapshots::class)->current();

    app()->instance(SnapshotWriter::class, new class extends SnapshotWriter
    {
        public function write(string $path, array $tables, array $meta): void
        {
            throw new RuntimeException('disk full');
        }
    });

    expect(fn () => snapshotPlant('Allium sativum', 'Σκόρδο', 'Garlic', $this->vegetables))->toThrow(RuntimeException::class, 'disk full');

    $this->getJson('/api/v1/catalogue/version')->assertOk()->assertJson(['version' => $before->version, 'sha256' => $before->sha256]);
    expect(Storage::disk('local')->files('catalogue/snapshots'))->toEqualCanonicalizing(['catalogue/snapshots/current.json', $before->path]);
});

it('builds the snapshot on demand and copies it to a file for the app bundle', function () {
    standardCatalogue();
    $output = tempnam(sys_get_temp_dir(), 'bundle-');

    $this->artisan('catalogue:build-snapshot', ['--output' => $output])
        ->expectsOutputToContain('Catalogue snapshot v')
        ->assertSuccessful();

    expect(hash_file('sha256', $output))->toBe(app(CatalogueSnapshots::class)->current()->sha256);
});

it('rebuilds the snapshot after the settlement list is replaced', function () {
    Bus::fake([BuildCatalogueSnapshot::class]);

    app(SettlementImporter::class)->replace([['name_el' => 'Βόλος', 'name_en' => 'Volos', 'region' => null, 'lat' => 39.36, 'lon' => 22.94]]);

    Bus::assertDispatched(BuildCatalogueSnapshot::class);
});

// --- ENT-Plant and INT-006 do not reach devices ------------------------------------------------

it('rejects a transition not in the state model, leaves the state unchanged and builds no snapshot (ENT-Plant)', function (PlantStatus $from, PlantStatus $to) {
    $plant = snapshotPlant('Solanum lycopersicum', 'Ντομάτα', 'Tomato', $this->vegetables, $from);
    $before = app(CatalogueSnapshots::class)->current();

    Bus::fake([BuildCatalogueSnapshot::class]);

    expect(fn () => app(PlantWorkflow::class)->transition($plant, $to))->toThrow(InvalidPlantTransition::class);

    expect($plant->status)->toBe($from)
        ->and($plant->refresh()->status)->toBe($from)
        ->and(app(CatalogueSnapshots::class)->current()?->version)->toBe($before?->version);
    Bus::assertNotDispatched(BuildCatalogueSnapshot::class);
})->with([
    'draft -> published' => [PlantStatus::Draft, PlantStatus::Published],
    'draft -> archived' => [PlantStatus::Draft, PlantStatus::Archived],
    'archived -> published' => [PlantStatus::Archived, PlantStatus::Published],
    'published -> in_review' => [PlantStatus::Published, PlantStatus::InReview],
]);

it('stops the import with a message and publishes nothing to devices when EXT-006 is unavailable or times out (INT-006)', function (string $reason) {
    snapshotPlant('Ocimum basilicum', 'Βασιλικός', 'Basil', $this->herbs);
    $before = app(CatalogueSnapshots::class)->current();

    app()->instance(PlantSourceImporter::class, new class($reason) implements PlantSourceImporter
    {
        public function __construct(private string $reason) {}

        public function import(PlantSource $source, string $scientificName): DraftFacts
        {
            throw new PlantSourceUnavailable($source, $this->reason);
        }
    });
    Bus::fake([BuildCatalogueSnapshot::class]);

    $this->artisan('catalogue:import-plant', ['scientific_name' => 'Solanum lycopersicum', '--category' => 'vegetables'])
        ->expectsOutputToContain('is unavailable')
        ->assertFailed();

    expect(Plant::query()->where('scientific_name', 'Solanum lycopersicum')->exists())->toBeFalse()
        ->and(app(CatalogueSnapshots::class)->current()->version)->toBe($before->version);
    Bus::assertNotDispatched(BuildCatalogueSnapshot::class);
})->with(['timed out after 30 s', 'HTTP 503']);

// --- Search keys --------------------------------------------------------------------------------

it('normalises text to lower case without accents and with σ for final sigma', function () {
    expect(SearchKeys::normalise('Ντομάτα'))->toBe('ντοματα')
        ->and(SearchKeys::normalise('ΗΔΎΟΣΜΟΣ'))->toBe('ηδυοσμοσ')
        ->and(SearchKeys::normalise('Δυόσμος, ο ήμερος'))->toBe('δυοσμοσ ο ημεροσ')
        ->and(SearchKeys::normalise('Ἀμπέλι ϊΐ'))->toBe('αμπελι ιι')
        ->and(SearchKeys::normalise('Crème brûlée'))->toBe('creme brulee');
});

it('adds Greeklish spellings and the spelling without a leading nasal to Greek words', function () {
    expect(SearchKeys::forWord('ντοματα'))->toContain('ντοματα', 'τοματα', 'ntomata', 'domata')
        ->and(SearchKeys::forWord('μπαμιεσ'))->toContain('παμιεσ', 'bamies', 'mpamies')
        ->and(SearchKeys::forWord('φασολι'))->toContain('fasoli', 'phasoli')
        ->and(SearchKeys::forWord('basil'))->toBe(['basil'])
        ->and(count(SearchKeys::greeklish('ψυχοθεραπευτησ')))->toBeLessThanOrEqual(SearchKeys::MAX_VARIANTS_PER_WORD);
});
