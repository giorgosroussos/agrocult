<?php

use App\Modules\Catalogue\Models\Settlement;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;

uses(RefreshDatabase::class);

beforeEach(function () {
    Http::preventStrayRequests();
});

function overpassFile(mixed $content): string
{
    $path = tempnam(sys_get_temp_dir(), 'overpass');
    file_put_contents($path, is_string($content) ? $content : json_encode($content));

    return $path;
}

it('replaces the settlement list from an OpenStreetMap Overpass export', function () {
    Settlement::create(['name_el' => 'Παλιό χωριό', 'lat' => 38, 'lon' => 23]);

    $file = overpassFile(['elements' => [
        ['type' => 'node', 'lat' => 40.6403167, 'lon' => 22.9352716, 'tags' => ['place' => 'city', 'name' => 'Θεσσαλονίκη', 'name:en' => 'Thessaloniki', 'is_in:region' => 'Κεντρική Μακεδονία']],
        ['type' => 'way', 'center' => ['lat' => 35.3387352, 'lon' => 25.1442126], 'tags' => ['place' => 'town', 'name' => 'Heraklion', 'name:el' => 'Ηράκλειο', 'addr:state' => 'Κρήτη']],
        ['type' => 'node', 'lat' => 39.0, 'lon' => 21.0, 'tags' => ['place' => 'village']],
        ['type' => 'node', 'tags' => ['place' => 'village', 'name' => 'Χωρίς συντεταγμένες']],
        ['type' => 'node', 'lat' => 40.6403167, 'lon' => 22.9352716, 'tags' => ['place' => 'city', 'name' => 'Θεσσαλονίκη']],
    ]]);

    $this->artisan('catalogue:import-settlements', ['file' => $file])
        ->expectsOutputToContain('Imported 2 settlements')
        ->assertSuccessful();

    Http::assertNothingSent();

    $settlements = Settlement::orderBy('name_el')->get();
    expect($settlements)->toHaveCount(2)
        ->and($settlements[0]->only(['name_el', 'name_en', 'region', 'lat', 'lon']))->toEqual([
            'name_el' => 'Ηράκλειο', 'name_en' => null, 'region' => 'Κρήτη', 'lat' => '35.338735', 'lon' => '25.144213',
        ])
        ->and($settlements[1]->only(['name_el', 'name_en', 'region']))->toEqual([
            'name_el' => 'Θεσσαλονίκη', 'name_en' => 'Thessaloniki', 'region' => 'Κεντρική Μακεδονία',
        ])
        ->and(Settlement::where('name_el', 'Παλιό χωριό')->exists())->toBeFalse();
});

it('keeps the previous list when the file is missing, not an Overpass export or has no settlements', function (?string $content, string $message) {
    Settlement::create(['name_el' => 'Παλιό χωριό', 'lat' => 38, 'lon' => 23]);
    $file = $content === null ? '/nonexistent/overpass.json' : overpassFile($content);

    $this->artisan('catalogue:import-settlements', ['file' => $file])
        ->expectsOutputToContain($message)
        ->assertFailed();

    expect(Settlement::pluck('name_el')->all())->toBe(['Παλιό χωριό']);
})->with([
    'missing file' => [null, 'Cannot read'],
    'not JSON' => ['<osm></osm>', 'not an Overpass API JSON export'],
    'no elements' => ['{"version": 0.6}', 'not an Overpass API JSON export'],
    'no usable settlement' => ['{"elements": [{"type": "node", "tags": {"place": "village"}}]}', 'has no settlement'],
]);
