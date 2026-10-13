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

it('rejects shared code that depends on a module', function () {
    $dir = fixtureSource([
        'Support/Helper.php' => "<?php\nnamespace App\\Support;\nclass Helper { public function __construct(public \\App\\Modules\\Identity\\Account \$a) {} }\n",
        'Identity/Account.php' => "<?php\nnamespace App\\Modules\\Identity;\nclass Account {}\n",
    ]);

    $process = runDeptrac($dir);

    expect($process->getExitCode())->not->toBe(0);
});
