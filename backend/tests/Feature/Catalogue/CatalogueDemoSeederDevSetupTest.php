<?php

use App\Modules\Catalogue\Jobs\BuildCatalogueSnapshot;
use App\Modules\Catalogue\Services\CatalogueSnapshots;
use App\Modules\Weather\Jobs\ReassignCellZones;
use Illuminate\Foundation\Testing\DatabaseTruncation;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;

/*
 * The development setup of `php artisan db:seed`: database cache store (unique job locks in
 * PostgreSQL) and database queue, with real transactions (no wrapping test transaction).
 * A unique-lock attempt inside a PostgreSQL transaction must not abort it, so that publishing
 * several plants while a snapshot build is still queued works.
 */
uses(DatabaseTruncation::class);

beforeEach(function () {
    Storage::fake('local');
    Http::preventStrayRequests();
    config(['cache.default' => 'database', 'queue.default' => 'database']);
});

// Leave the tables empty for the tests that follow (they use RefreshDatabase transactions).
afterEach(function () {
    $tables = array_diff(Schema::getTableListing(schemaQualified: false), ['migrations']);
    DB::statement('TRUNCATE TABLE '.implode(', ', array_map(fn (string $table) => '"'.$table.'"', $tables)).' CASCADE');
});

it('seeds the demo catalogue with the database cache and queue, and the queued build ships the 8 published plants', function () {
    $this->seed();

    // One snapshot build, and one re-assignment of weather cells for the new zones (DATA-009).
    $jobs = DB::table('jobs')->pluck('payload')->map(fn (string $payload) => json_decode($payload, true)['displayName'])->sort()->values()->all();

    expect($jobs)->toBe([BuildCatalogueSnapshot::class, ReassignCellZones::class])
        ->and(app(CatalogueSnapshots::class)->current())->toBeNull();

    $this->artisan('queue:work', ['--stop-when-empty' => true])->assertSuccessful();

    $snapshots = app(CatalogueSnapshots::class);
    $db = new PDO('sqlite:'.$snapshots->disk()->path($snapshots->current()->path));

    expect($db->query('SELECT COUNT(*) FROM plants')->fetchColumn())->toBe(8);

    $this->seed();

    expect(DB::table('plants')->count())->toBe(10)
        ->and(DB::table('jobs')->count())->toBe(0);
});
