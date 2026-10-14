<?php

use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Weather\Climate\CellZones;
use App\Modules\Weather\Climate\ClimateMetrics;
use App\Modules\Weather\Events\CellZoneChanged;
use App\Modules\Weather\Exceptions\WeatherUnavailable;
use App\Modules\Weather\Jobs\ComputeCellClimate;
use App\Modules\Weather\Models\WeatherCell;
use App\Modules\Weather\Provider\DailyWeather;
use App\Modules\Weather\Provider\FakeWeatherProvider;
use App\Modules\Weather\Provider\WeatherProvider;
use App\Modules\Weather\Services\WeatherCells;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Queue;

uses(RefreshDatabase::class);

/**
 * Daily history of whole years: every day `$base` °C, January `$january` °C, and a frost
 * (-1 °C) on the given dates.
 *
 * @param  list<int>  $years
 * @param  list<string>  $frosts  'Y-m-d'
 * @return list<DailyWeather>
 */
function weatherHistory(array $years, float $base = 10.0, float $january = 5.0, array $frosts = []): array
{
    $days = [];

    foreach ($years as $year) {
        for ($date = CarbonImmutable::create($year, 1, 1); $date->year === $year; $date = $date->addDay()) {
            $min = in_array($date->toDateString(), $frosts, true) ? -1.0 : ($date->month === 1 ? $january : $base);
            $days[] = new DailyWeather($date, 0.0, $min, $min + 8);
        }
    }

    return $days;
}

function fakeWeather(): FakeWeatherProvider
{
    $fake = new FakeWeatherProvider;
    app()->instance(WeatherProvider::class, $fake);

    return $fake;
}

// --- Climate metrics (DATA-009) ---

it('stores last_frost_doy as null when only 3 of 10 years had a frost before 1 July', function () {
    $metrics = ClimateMetrics::fromHistory(120, weatherHistory(range(2016, 2025), frosts: ['2016-03-01', '2019-03-10', '2023-02-20']));

    expect($metrics?->lastFrostDoy)->toBeNull()
        ->and($metrics?->firstFrostDoy)->toBeNull();
});

it('stores the mean day of year of the last spring and first autumn frost when at least half of the years had one', function () {
    // Last frost before 1 July in 5 of 10 years: day 60 (1 March) in non-leap years, plus an
    // earlier frost that is not the last one; first frost from 1 July on in 6 of 10 years.
    $frosts = ['2017-01-10', '2017-03-01', '2018-03-01', '2019-03-01', '2021-03-01', '2022-03-01',
        '2017-12-01', '2018-12-01', '2019-12-01', '2021-12-01', '2022-12-01', '2023-12-01', '2023-12-20'];

    $metrics = ClimateMetrics::fromHistory(120, weatherHistory(range(2016, 2025), frosts: $frosts));

    expect($metrics?->lastFrostDoy)->toBe(60)
        ->and($metrics?->firstFrostDoy)->toBe(335)
        ->and($metrics?->elevationM)->toBe(120);
});

it('treats a daily minimum of exactly 0 °C as frost and 0.1 °C as no frost', function () {
    $days = array_map(function (DailyWeather $day) {
        $min = match ($day->date->format('m-d')) {
            '03-01' => $day->date->year % 2 === 0 ? 0.0 : 0.1,
            default => 10.0,
        };

        return new DailyWeather($day->date, 0.0, $min, 20.0);
    }, weatherHistory(range(2016, 2025)));

    // 0 °C in the 5 even years: half of the years, so the date counts.
    expect(ClimateMetrics::fromHistory(0, $days)?->lastFrostDoy)->toBe(61);
});

it('computes winter_min_mean_c as the mean over the years of the mean daily minimum of the coldest month', function () {
    $days = array_merge(weatherHistory([2016], january: 4.0), weatherHistory([2017], january: 6.0));

    // February of 2017 is colder than its January: that year's coldest month is February.
    $days = array_map(fn (DailyWeather $day) => $day->date->format('Y-m') === '2017-02'
        ? new DailyWeather($day->date, 0.0, $day->date->day % 2 === 0 ? 1.0 : 3.0, 10.0)
        : $day, $days);

    // 2016: January 4.0; 2017: February mean of 1.0 and 3.0 alternating over 28 days = 2.0.
    expect(ClimateMetrics::fromHistory(0, $days)?->winterMinMeanC)->toBe(3.0);
});

// --- Computing a cell (DATA-001, DATA-009) ---

it('computes the metrics of a new cell once, from one history call over the last 10 full calendar years, and assigns its zone', function () {
    $this->travelTo(CarbonImmutable::parse('2026-10-14 12:00'));
    Event::fake([CellZoneChanged::class]);
    $mild = ClimateZone::factory()->create(['code' => 'mild', 'rules' => ['winter_min_mean_c' => ['min' => 4, 'max' => null]]]);
    ClimateZone::factory()->create(['code' => 'cold', 'rules' => ['winter_min_mean_c' => ['min' => null, 'max' => 4]]]);
    $fake = fakeWeather()->withElevation(85)->withHistory(weatherHistory(range(2016, 2025), january: 6.5));

    $cellId = app(WeatherCells::class)->cellFor(37.98412, 23.72754);
    $cell = WeatherCell::query()->findOrFail($cellId);

    expect($fake->calls)->toBe([
        ['operation' => 'elevation', 'lat' => 38.0, 'lon' => 23.7],
        ['operation' => 'history', 'lat' => 38.0, 'lon' => 23.7, 'from' => '2016-01-01', 'to' => '2025-12-31'],
    ])
        ->and($cell->lat)->toBe(38.0)
        ->and($cell->lon)->toBe(23.7)
        ->and($cell->elevation_m)->toBe(85)
        ->and($cell->winter_min_mean_c)->toBe(6.5)
        ->and($cell->last_frost_doy)->toBeNull()
        ->and($cell->climate_zone_id)->toBe($mild->id)
        ->and(app(WeatherCells::class)->climateZoneId($cellId))->toBe($mild->id);

    Event::assertDispatched(CellZoneChanged::class, fn (CellZoneChanged $e) => $e->weatherCellId === $cellId
        && $e->previousClimateZoneId === null && $e->climateZoneId === $mild->id);

    // Reused: another location in the same cell neither creates a cell nor calls the provider again.
    expect(app(WeatherCells::class)->cellFor(38.03, 23.66))->toBe($cellId)
        ->and($fake->calls)->toHaveCount(2)
        ->and(WeatherCell::query()->count())->toBe(1);
});

/**
 * Runs the database queue worker once and returns how many seconds the next attempt of the
 * (only) queued job lies ahead, or null when no job is left.
 */
function workOnce(): ?int
{
    Artisan::call('queue:work', ['connection' => 'database', '--once' => true, '--stop-when-empty' => true]);

    $job = DB::table('jobs')->first();

    return $job === null ? null : $job->available_at - now()->getTimestamp();
}

it('retries a cell 3 times (30 s, 2 m, 10 m) when EXT-002 is unavailable, then leaves it without metrics and zone until a later run succeeds (INT-002)', function (string $reason, array $failing) {
    $zone = ClimateZone::factory()->create(['code' => 'any', 'rules' => []]);
    config(['queue.default' => 'database']);
    $fake = fakeWeather()->fail($reason, $failing);

    $cellId = app(WeatherCells::class)->cellFor(40.64, 22.94);
    expect(DB::table('jobs')->count())->toBe(1);

    $delays = [];
    for ($attempt = 1; $attempt <= 4; $attempt++) {
        $delay = workOnce();
        if ($delay !== null) {
            $delays[] = $delay;
            $this->travel($delay)->seconds();
        }
    }

    $cell = WeatherCell::query()->findOrFail($cellId);

    expect($delays)->toBe([30, 120, 600])
        ->and($fake->callCount($failing[0]))->toBe(4)
        ->and(DB::table('jobs')->count())->toBe(0)
        ->and(DB::table('failed_jobs')->count())->toBe(1)
        ->and($cell->hasMetrics())->toBeFalse()
        ->and($cell->elevation_m)->toBeNull()
        ->and($cell->winter_min_mean_c)->toBeNull()
        ->and($cell->last_frost_doy)->toBeNull()
        ->and($cell->first_frost_doy)->toBeNull()
        ->and($cell->climate_zone_id)->toBeNull()
        // SCOPE-004: a garden in this cell is saved without a zone.
        ->and(app(WeatherCells::class)->climateZoneId($cellId))->toBeNull();

    // A later run (a new garden in the cell, or `weather:compute-cells`) succeeds.
    $fake->recover();
    $this->artisan('weather:compute-cells')->assertSuccessful();
    expect(workOnce())->toBeNull()
        ->and(app(WeatherCells::class)->climateZoneId($cellId))->toBe($zone->id);
})->with([
    'elevation unavailable' => ['unavailable', ['elevation']],
    'elevation timeout' => ['timeout', ['elevation']],
    'history unavailable' => ['unavailable', ['history']],
    'history timeout' => ['timeout', ['history']],
]);

it('stores no partial metrics when elevation succeeds but history fails', function () {
    Queue::fake();
    ClimateZone::factory()->create(['code' => 'any', 'rules' => []]);
    $fake = fakeWeather()->withElevation(300)->fail('timeout', ['history']);
    $cellId = app(WeatherCells::class)->cellFor(35.34, 25.14);

    expect(fn () => (new ComputeCellClimate($cellId))->handle($fake, app(CellZones::class)))
        ->toThrow(WeatherUnavailable::class);

    $cell = WeatherCell::query()->findOrFail($cellId);
    expect($fake->callCount('elevation'))->toBe(1)
        ->and($cell->elevation_m)->toBeNull()
        ->and($cell->climate_zone_id)->toBeNull();
});

it('logs a failed cell without its coordinates (SEC-002)', function () {
    Log::spy();

    (new ComputeCellClimate('cell-id'))->failed(WeatherUnavailable::because('history', 'HTTP 503'));

    Log::shouldHaveReceived('warning')->once()->withArgs(fn (string $message, array $context) => $context === [
        'weather_cell_id' => 'cell-id',
        'reason' => 'Weather service unavailable during history: HTTP 503',
    ]);
});
