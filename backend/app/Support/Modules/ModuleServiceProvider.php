<?php

namespace App\Support\Modules;

use Illuminate\Support\Facades\Route;
use Illuminate\Support\ServiceProvider;
use ReflectionClass;

/**
 * Base provider for a backend module in app/Modules/<Module>/.
 *
 * A module keeps its own API routes in routes/api.php (mounted under /api/v1
 * with the "api" middleware group) and its own migrations in
 * Database/Migrations. Both are optional.
 */
abstract class ModuleServiceProvider extends ServiceProvider
{
    public const API_PREFIX = 'api/v1';

    public function boot(): void
    {
        $path = $this->modulePath();

        if (is_dir($path.'/Database/Migrations')) {
            $this->loadMigrationsFrom($path.'/Database/Migrations');
        }

        if (is_file($path.'/routes/api.php') && ! $this->app->routesAreCached()) {
            Route::prefix(self::API_PREFIX)
                ->middleware('api')
                ->group($path.'/routes/api.php');
        }
    }

    protected function modulePath(): string
    {
        return dirname((string) (new ReflectionClass(static::class))->getFileName());
    }
}
