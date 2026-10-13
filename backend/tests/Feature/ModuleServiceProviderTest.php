<?php

use Illuminate\Support\Facades\Route;
use Tests\Fixtures\Modules\Sample\SampleServiceProvider;

beforeEach(function () {
    $this->app->register(SampleServiceProvider::class);
    Route::getRoutes()->refreshNameLookups();
});

it('mounts a module routes/api.php under /api/v1 with the api middleware', function () {
    $route = Route::getRoutes()->getByName('sample.ping');

    expect($route)->not->toBeNull()
        ->and($route?->uri())->toBe('api/v1/sample/ping')
        ->and($route?->middleware())->toContain('api');

    $this->getJson('/api/v1/sample/ping')->assertOk()->assertExactJson(['pong' => true]);
});

it('loads the module own migrations', function () {
    $paths = $this->app->make('migrator')->paths();

    expect($paths)->toContain(base_path('tests/Fixtures/Modules/Sample/Database/Migrations'));
});

it('does not expose module routes outside /api/v1', function () {
    $this->getJson('/sample/ping')->assertNotFound();
    $this->getJson('/api/sample/ping')->assertNotFound();
});
