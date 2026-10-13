<?php

use App\Support\Modules\ModuleServiceProvider;
use Composer\InstalledVersions;

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

it('installs every approved backend dependency (design v1.0.1, ARCH-005)', function () {
    $approved = [
        'laravel/framework' => '^13.8',
        'laravel/sanctum' => '^4.0',
        'filament/filament' => '^5.7',
        'kreait/laravel-firebase' => '^7.0',
        'intervention/image' => '^3.0',
        'pestphp/pest' => '^4.0',
        'laravel/pint' => '^1.0',
        'larastan/larastan' => '^3.0',
        'deptrac/deptrac' => '^3.0',
    ];

    foreach ($approved as $package => $constraint) {
        expect(InstalledVersions::isInstalled($package))->toBeTrue("{$package} is not installed");

        // Caret constraint: same major version, at least the given minimum.
        $minimum = ltrim($constraint, '^');
        $installed = ltrim((string) InstalledVersions::getPrettyVersion($package), 'v');

        expect(explode('.', $installed)[0])->toBe(explode('.', $minimum)[0], "{$package} {$installed} does not satisfy {$constraint}")
            ->and(version_compare($installed, $minimum, '>='))->toBeTrue("{$package} {$installed} does not satisfy {$constraint}");
    }
});
