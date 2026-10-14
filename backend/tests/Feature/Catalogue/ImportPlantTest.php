<?php

use App\Modules\Catalogue\Enums\CompanionRelation;
use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Enums\Sun;
use App\Modules\Catalogue\Import\PlantSource;
use App\Modules\Catalogue\Import\PlantSourceImporter;
use App\Modules\Catalogue\Models\Companion;
use App\Modules\Catalogue\Models\FactSource;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantAlias;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Models\PlantTranslation;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;

uses(RefreshDatabase::class);

const TOMATO = 'Solanum lycopersicum';

beforeEach(function () {
    config([
        'catalogue.import.sources.gbif.url' => 'https://gbif.test/v1',
        'catalogue.import.sources.wikidata.url' => 'https://wikidata.test/sparql',
        'catalogue.import.sources.openfarm.url' => 'https://openfarm.test/crops.json',
        'catalogue.import.sources.trefle.url' => 'https://trefle.test',
        'catalogue.import.sources.trefle.token' => 'secret-trefle-token',
    ]);

    Http::preventStrayRequests();

    $this->vegetables = PlantCategory::factory()->create(['code' => 'vegetables']);
});

/**
 * Fake answers of the four sources for the tomato; $overrides replaces a source's answer.
 *
 * @param  array<string, mixed>  $overrides
 */
function fakeSources(array $overrides = []): void
{
    Http::fake($overrides + [
        'gbif.test/*' => Http::response(['usageKey' => 2930137, 'matchType' => 'EXACT', 'scientificName' => 'Solanum lycopersicum L.']),
        'wikidata.test/*' => Http::response(['results' => ['bindings' => [
            ['item' => ['value' => 'http://www.wikidata.org/entity/Q23501'], 'gbif' => ['value' => '2930137'], 'label' => ['value' => 'ντομάτα', 'xml:lang' => 'el'], 'kind' => ['value' => 'name']],
            ['item' => ['value' => 'http://www.wikidata.org/entity/Q23501'], 'gbif' => ['value' => '2930137'], 'label' => ['value' => 'tomato', 'xml:lang' => 'en'], 'kind' => ['value' => 'name']],
            ['item' => ['value' => 'http://www.wikidata.org/entity/Q23501'], 'gbif' => ['value' => '2930137'], 'label' => ['value' => 'τομάτα', 'xml:lang' => 'el'], 'kind' => ['value' => 'alias']],
            ['item' => ['value' => 'http://www.wikidata.org/entity/Q23501'], 'gbif' => ['value' => '2930137'], 'label' => ['value' => 'Solanum lycopersicum', 'xml:lang' => 'en'], 'kind' => ['value' => 'alias']],
        ]]]),
        'openfarm.test/*' => Http::response([
            [
                'slug' => 'tomato', 'name' => 'Tomato', 'binomialName' => 'Solanum lycopersicum',
                'description' => 'A long description that must never be copied.',
                'sun' => 'Full Sun', 'rowSpacingCm' => 90, 'companions' => ['basil', 'unknown-crop'],
                'source' => ['origin' => 'openfarm.cc', 'license' => 'CC0-1.0', 'waybackUrl' => 'https://web.archive.org/web/2024/https://openfarm.cc/crops/tomato'],
            ],
            ['slug' => 'basil', 'name' => 'Basil', 'binomialName' => 'Ocimum basilicum', 'source' => ['license' => 'CC0-1.0']],
        ]),
        'trefle.test/api/v1/species/search*' => Http::response(['data' => [
            ['id' => 41, 'scientific_name' => 'Solanum lycopersicum', 'slug' => 'solanum-lycopersicum'],
        ]]),
        'trefle.test/api/v1/species/41*' => Http::response(['data' => [
            'slug' => 'solanum-lycopersicum', 'common_name' => 'Garden tomato',
            'growth' => [
                'ph_minimum' => 5.5, 'ph_maximum' => 7.5,
                'minimum_temperature' => ['deg_c' => 10], 'maximum_temperature' => ['deg_c' => 35],
                'days_to_harvest' => 80, 'row_spacing' => ['cm' => 100],
            ],
        ]]),
    ]);
}

it('imports facts from every source as a draft plant with a source and licence for every fact (UC-010, SCOPE-001)', function () {
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables'])
        ->expectsOutputToContain('Created draft plant Solanum lycopersicum')
        ->assertSuccessful();

    $plant = Plant::where('scientific_name', TOMATO)->sole();

    expect($plant->status)->toBe(PlantStatus::Draft)
        ->and($plant->published_at)->toBeNull()
        ->and($plant->category_id)->toBe($this->vegetables->id)
        ->and($plant->gbif_id)->toBe(2930137)
        ->and($plant->sun)->toBe(Sun::FullSun)
        ->and($plant->row_spacing_cm)->toBe(90)
        ->and($plant->ph_min)->toBe('5.5')
        ->and($plant->ph_max)->toBe('7.5')
        ->and($plant->temp_min_c)->toBe('10.0')
        ->and($plant->temp_max_c)->toBe('35.0')
        ->and($plant->days_to_harvest)->toBe(80)
        ->and(Plant::published()->count())->toBe(0);

    expect(PlantTranslation::where('plant_id', $plant->id)->pluck('name', 'lang')->all())
        ->toEqual(['el' => 'ντομάτα', 'en' => 'tomato'])
        ->and(PlantTranslation::where('plant_id', $plant->id)->whereNotNull('description')->exists())->toBeFalse()
        ->and(PlantAlias::where('plant_id', $plant->id)->pluck('alias')->sort()->values()->all())
        ->toEqual(['Garden tomato', 'τομάτα']);

    $sources = FactSource::where('plant_id', $plant->id)->get();

    expect($sources)->not->toBeEmpty()
        ->and($sources->every(fn (FactSource $s) => $s->licence !== '' && $s->source_name !== '' && $s->imported_at !== null))->toBeTrue()
        ->and($sources->where('field', 'gbif_id')->pluck('source_name')->sort()->values()->all())->toEqual(['GBIF Backbone Taxonomy', 'Wikidata'])
        ->and($sources->firstWhere('field', 'gbif_id')?->licence)->not->toBeNull()
        ->and($sources->firstWhere('source_name', 'Wikidata')?->licence)->toBe('CC0 1.0')
        ->and($sources->firstWhere('source_name', 'GBIF Backbone Taxonomy')?->licence)->toBe('CC BY 4.0')
        ->and($sources->firstWhere('field', 'sun')?->licence)->toBe('CC0-1.0')
        ->and($sources->firstWhere('field', 'sun')?->source_url)->toBe('https://web.archive.org/web/2024/https://openfarm.cc/crops/tomato')
        ->and($sources->firstWhere('field', 'ph_min')?->source_name)->toBe('Trefle');

    foreach (['gbif_id', 'sun', 'row_spacing_cm', 'ph_min', 'ph_max', 'temp_min_c', 'temp_max_c', 'days_to_harvest', 'name.el', 'name.en', 'alias.el'] as $field) {
        expect($sources->where('field', $field))->not->toBeEmpty("no source recorded for {$field}");
    }
});

it('never records the Trefle token in a source URL', function () {
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables'])->assertSuccessful();

    expect(FactSource::where('source_url', 'like', '%secret-trefle-token%')->exists())->toBeFalse()
        ->and(FactSource::where('source_name', 'Trefle')->first()?->source_url)->toBe('https://trefle.test/api/v1/species/solanum-lycopersicum');
});

it('applies a 30 second time limit to every call to the sources (INT-006)', function () {
    $timeouts = [];
    Http::fake(function (Request $request, array $options) use (&$timeouts) {
        $timeouts[] = [$options['timeout'] ?? null, $options['connect_timeout'] ?? null];

        return Http::response([]);
    });

    foreach (PlantSource::cases() as $source) {
        app(PlantSourceImporter::class)->import($source, TOMATO);
    }

    expect($timeouts)->not->toBeEmpty()
        ->and(collect($timeouts)->every(fn (array $t) => $t === [30, 30]))->toBeTrue();
});

/**
 * How an unavailable source answers.
 */
function unavailableAnswer(string $kind): Closure
{
    return match ($kind) {
        'timeout' => fn () => throw new ConnectionException('cURL error 28: Operation timed out'),
        'server error' => fn () => Http::response('down', 503),
        'rate limited' => fn () => Http::response('slow down', 429),
        'not JSON' => fn () => Http::response('<html>maintenance</html>', 200),
    };
}

it('stops with a message and writes or publishes nothing when a source is unavailable or times out (INT-006)', function (string $source, string $answer) {
    fakeSources(["{$source}.test/*" => unavailableAnswer($answer)]);

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables'])
        ->expectsOutputToContain('is unavailable')
        ->expectsOutputToContain('The import stopped; nothing was written or published')
        ->assertFailed();

    expect(Plant::count())->toBe(0)
        ->and(FactSource::count())->toBe(0)
        ->and(PlantTranslation::count())->toBe(0)
        ->and(PlantAlias::count())->toBe(0);
})->with(['gbif', 'wikidata', 'openfarm', 'trefle'])->with(['timeout', 'server error', 'rate limited', 'not JSON']);

it('leaves an existing draft unchanged when a source is unavailable (INT-006)', function () {
    $plant = Plant::factory()->create(['scientific_name' => TOMATO, 'category_id' => $this->vegetables->id]);
    fakeSources(['trefle.test/*' => fn () => throw new ConnectionException('timed out')]);

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO])->assertFailed();

    $plant->refresh();
    expect($plant->status)->toBe(PlantStatus::Draft)
        ->and($plant->gbif_id)->toBeNull()
        ->and($plant->sun)->toBeNull()
        ->and(FactSource::count())->toBe(0)
        ->and(PlantTranslation::count())->toBe(0);
});

it('never writes to a plant that is not a draft and asks no source', function (string $state) {
    $plant = Plant::factory()->{$state}()->create(['scientific_name' => TOMATO]);
    $before = $plant->refresh()->getAttributes();
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO])
        ->expectsOutputToContain('imports only write to draft plants')
        ->assertFailed();

    Http::assertNothingSent();
    expect($plant->refresh()->getAttributes())->toEqual($before)
        ->and(FactSource::count())->toBe(0);
})->with(['inReview', 'published', 'archived']);

it('needs an existing category for a plant that is not in the catalogue yet (DATA-004)', function (array $options, string $message) {
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO] + $options)
        ->expectsOutputToContain($message)
        ->assertFailed();

    Http::assertNothingSent();
    expect(Plant::count())->toBe(0);
})->with([
    'no category' => [[], '--category=<code>'],
    'unknown category' => [['--category' => 'no-such-code'], 'no plant category with code no-such-code'],
]);

it('rejects a scientific name that is not a name', function (string $name) {
    $this->artisan('catalogue:import-plant', ['scientific_name' => $name, '--category' => 'vegetables'])
        ->expectsOutputToContain('Give a scientific name')
        ->assertFailed();

    Http::assertNothingSent();
})->with(['"} ; DROP', '1234', 'x']);

it('rejects an unknown source and an unconfigured Trefle', function () {
    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables', '--source' => ['permapeople']])
        ->expectsOutputToContain('Unknown source permapeople')
        ->assertFailed();

    config(['catalogue.import.sources.trefle.token' => null]);

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables', '--source' => ['trefle']])
        ->expectsOutputToContain('Trefle is not configured')
        ->assertFailed();

    Http::assertNothingSent();
    expect(Plant::count())->toBe(0);
});

it('skips Trefle by default when it has no token', function () {
    config(['catalogue.import.sources.trefle.token' => '']);
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables'])->assertSuccessful();

    Http::assertNotSent(fn (Request $request) => str_contains($request->url(), 'trefle.test'));
});

it('asks only the requested sources', function () {
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables', '--source' => ['gbif']])->assertSuccessful();

    Http::assertSentCount(1);
    Http::assertSent(fn (Request $request) => str_contains($request->url(), 'gbif.test'));
    expect(FactSource::pluck('source_name')->unique()->values()->all())->toBe(['GBIF Backbone Taxonomy']);
});

it('keeps values the curator entered and reports the differing ones', function () {
    $plant = Plant::factory()->create(['scientific_name' => TOMATO, 'category_id' => $this->vegetables->id, 'row_spacing_cm' => 60, 'sun' => Sun::FullSun]);
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO])
        ->expectsOutputToContain('row_spacing_cm = 90 (OpenFarm (crops rescue)): the plant keeps 60')
        ->assertSuccessful();

    $plant->refresh();
    expect($plant->row_spacing_cm)->toBe(60)
        ->and($plant->status)->toBe(PlantStatus::Draft)
        ->and(FactSource::where('field', 'row_spacing_cm')->pluck('source_name')->all())->toBe([])
        ->and(FactSource::where('field', 'sun')->pluck('source_name')->all())->toBe(['OpenFarm (crops rescue)']);
});

it('does not take a GBIF id that another plant already has', function () {
    Plant::factory()->create(['scientific_name' => 'Lycopersicon esculentum', 'gbif_id' => 2930137]);
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables'])
        ->expectsOutputToContain('another plant already has this GBIF id')
        ->assertSuccessful();

    expect(Plant::where('scientific_name', TOMATO)->sole()->gbif_id)->toBeNull();
});

it('links companions that are in the catalogue as good neighbours and skips the others', function () {
    $basil = Plant::factory()->create(['scientific_name' => 'Ocimum basilicum']);
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables'])->assertSuccessful();

    $tomato = Plant::where('scientific_name', TOMATO)->sole();
    $companion = Companion::where('plant_id', $tomato->id)->sole();

    expect($companion->other_plant_id)->toBe($basil->id)
        ->and($companion->relation)->toBe(CompanionRelation::Good)
        ->and(FactSource::where('plant_id', $tomato->id)->where('field', 'companion')->value('licence'))->toBe('CC0-1.0');
});

it('can be re-run without duplicating facts or sources', function () {
    fakeSources();

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO, '--category' => 'vegetables'])->assertSuccessful();
    $counts = [FactSource::count(), PlantAlias::count(), PlantTranslation::count()];

    $this->artisan('catalogue:import-plant', ['scientific_name' => TOMATO])
        ->expectsOutputToContain('Updated draft plant')
        ->assertSuccessful();

    expect([FactSource::count(), PlantAlias::count(), PlantTranslation::count()])->toBe($counts)
        ->and(Plant::count())->toBe(1);
});

it('writes nothing when no source knows the plant', function () {
    fakeSources([
        'gbif.test/*' => Http::response(['matchType' => 'HIGHERRANK', 'usageKey' => 2930000]),
        'wikidata.test/*' => Http::response(['results' => ['bindings' => []]]),
        'openfarm.test/*' => Http::response([]),
        'trefle.test/*' => Http::response(['data' => []]),
    ]);

    $this->artisan('catalogue:import-plant', ['scientific_name' => 'Imaginaria nonexistens', '--category' => 'vegetables'])
        ->expectsOutputToContain('No source has facts')
        ->assertSuccessful();

    expect(Plant::count())->toBe(0);
});
