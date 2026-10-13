<?php

use App\Support\Modules\ModuleServiceProvider;

/**
 * Backend components of the design (design/model/architecture.yaml) and the
 * modules they live in. CMP-App* components are the Flutter app.
 */
const BACKEND_MODULES = [
    'Identity', 'Catalogue', 'Weather', 'Gardens', 'Identification', 'Notifications', 'Privacy',
];

function backendPath(string $path = ''): string
{
    return dirname(__DIR__, 2).($path === '' ? '' : '/'.$path);
}

it('has a module folder with its own service provider for every backend component', function () {
    $folders = array_map('basename', glob(backendPath('app/Modules/*'), GLOB_ONLYDIR) ?: []);

    expect($folders)->toEqualCanonicalizing(BACKEND_MODULES);

    foreach (BACKEND_MODULES as $module) {
        $class = "App\\Modules\\{$module}\\{$module}ServiceProvider";
        expect(class_exists($class))->toBeTrue("missing {$class}")
            ->and(is_subclass_of($class, ModuleServiceProvider::class))->toBeTrue();
    }
});

it('registers every module provider in bootstrap/providers.php', function () {
    $providers = require backendPath('bootstrap/providers.php');

    foreach (BACKEND_MODULES as $module) {
        expect($providers)->toContain("App\\Modules\\{$module}\\{$module}ServiceProvider");
    }
});

it('has no runtime dependency outside the approved list', function () {
    $approved = [
        'php', 'laravel/framework', 'laravel/sanctum', 'filament/filament',
        'kreait/laravel-firebase', 'intervention/image',
    ];

    $composer = json_decode((string) file_get_contents(backendPath('composer.json')), true);

    expect(array_keys($composer['require']))->toEqualCanonicalizing($approved);
});
