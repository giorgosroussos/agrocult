<?php

use Symfony\Component\Process\Process;

/**
 * Runs deptrac with the project rules against the given source directory.
 */
function runDeptrac(string $sourceDir): Process
{
    $root = dirname(__DIR__, 2);
    $work = sys_get_temp_dir().'/deptrac-'.bin2hex(random_bytes(6));
    mkdir($work);

    $config = (string) file_get_contents($root.'/deptrac.yaml');
    $config = str_replace('- ./app', '- '.$sourceDir, $config);
    file_put_contents($work.'/deptrac.yaml', $config);

    $process = new Process([
        PHP_BINARY, $root.'/vendor/bin/deptrac', 'analyse',
        '--config-file='.$work.'/deptrac.yaml',
        '--cache-file='.$work.'/.deptrac.cache',
        '--no-progress',
    ], $root);
    $process->run();

    return $process;
}

/**
 * @param  array<string, string>  $files  relative path => PHP source
 */
function fixtureSource(array $files): string
{
    $dir = sys_get_temp_dir().'/deptrac-src-'.bin2hex(random_bytes(6));
    foreach ($files as $path => $code) {
        @mkdir(dirname($dir.'/'.$path), 0777, true);
        file_put_contents($dir.'/'.$path, $code);
    }

    return $dir;
}

it('accepts the application code', function () {
    $process = runDeptrac(dirname(__DIR__, 2).'/app');

    expect($process->getExitCode())->toBe(0, $process->getOutput().$process->getErrorOutput());
});

it('accepts a dependency that may_depend_on allows', function () {
    $dir = fixtureSource([
        'Gardens/Plot.php' => "<?php\nnamespace App\\Modules\\Gardens;\nclass Plot { public function __construct(public \\App\\Modules\\Weather\\Cell \$cell) {} }\n",
        'Weather/Cell.php' => "<?php\nnamespace App\\Modules\\Weather;\nclass Cell {}\n",
    ]);

    $process = runDeptrac($dir);

    expect($process->getExitCode())->toBe(0, $process->getOutput());
});

it('rejects a dependency that may_depend_on does not allow', function () {
    $dir = fixtureSource([
        'Identity/Account.php' => "<?php\nnamespace App\\Modules\\Identity;\nclass Account { public function __construct(public \\App\\Modules\\Gardens\\Garden \$garden) {} }\n",
        'Gardens/Garden.php' => "<?php\nnamespace App\\Modules\\Gardens;\nclass Garden {}\n",
    ]);

    $process = runDeptrac($dir);

    expect($process->getExitCode())->not->toBe(0)
        ->and($process->getOutput())->toContain('App\\Modules\\Identity\\Account');
});

it('lets CMP-Weather read climate zones through the CMP-Catalogue ClimateZones service and its event (DATA-009)', function () {
    $dir = fixtureSource([
        'Weather/Zones.php' => "<?php\nnamespace App\\Modules\\Weather;\nclass Zones { public function __construct(public \\App\\Modules\\Catalogue\\Services\\ClimateZones \$zones, public ?\\App\\Modules\\Catalogue\\Events\\ClimateZoneRulesChanged \$event = null) {} }\n",
        'Catalogue/Services/ClimateZones.php' => "<?php\nnamespace App\\Modules\\Catalogue\\Services;\nclass ClimateZones { public function __construct(public ?\\App\\Modules\\Catalogue\\Models\\ClimateZone \$m = null) {} }\n",
        'Catalogue/Events/ClimateZoneRulesChanged.php' => "<?php\nnamespace App\\Modules\\Catalogue\\Events;\nclass ClimateZoneRulesChanged {}\n",
        'Catalogue/Models/ClimateZone.php' => "<?php\nnamespace App\\Modules\\Catalogue\\Models;\nclass ClimateZone { public function __construct(public ?\\App\\Modules\\Catalogue\\Services\\ClimateZones \$s = null) {} }\n",
    ]);

    $process = runDeptrac($dir);

    expect($process->getExitCode())->toBe(0, $process->getOutput());
});

it('rejects CMP-Weather using CMP-Catalogue models or other classes instead of the ClimateZones service (DATA-009)', function (string $class) {
    $dir = fixtureSource([
        'Weather/Zones.php' => "<?php\nnamespace App\\Modules\\Weather;\nclass Zones { public function __construct(public \\{$class} \$zone) {} }\n",
        'Catalogue/'.str_replace(['App\\Modules\\Catalogue\\', '\\'], ['', '/'], $class).'.php' => '<?php
namespace '.substr($class, 0, (int) strrpos($class, '\\')).";\nclass ".substr($class, (int) strrpos($class, '\\') + 1)." {}\n",
    ]);

    $process = runDeptrac($dir);

    expect($process->getExitCode())->not->toBe(0)
        ->and($process->getOutput())->toContain('App\\Modules\\Weather\\Zones');
})->with([
    'model' => 'App\\Modules\\Catalogue\\Models\\ClimateZone',
    'other service' => 'App\\Modules\\Catalogue\\Services\\CatalogueSnapshots',
]);

it('rejects shared code that depends on a module', function () {
    $dir = fixtureSource([
        'Support/Helper.php' => "<?php\nnamespace App\\Support;\nclass Helper { public function __construct(public \\App\\Modules\\Identity\\Account \$a) {} }\n",
        'Identity/Account.php' => "<?php\nnamespace App\\Modules\\Identity;\nclass Account {}\n",
    ]);

    $process = runDeptrac($dir);

    expect($process->getExitCode())->not->toBe(0);
});
