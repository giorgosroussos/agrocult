<?php

namespace App\Modules\Weather;

use App\Modules\Catalogue\Events\ClimateZoneRulesChanged;
use App\Modules\Weather\Console\ComputeCellsCommand;
use App\Modules\Weather\Jobs\ReassignCellZones;
use App\Modules\Weather\Provider\FakeWeatherProvider;
use App\Modules\Weather\Provider\OpenMeteoWeatherProvider;
use App\Modules\Weather\Provider\WeatherProvider;
use App\Support\Modules\ModuleServiceProvider;
use Illuminate\Support\Facades\Event;

/**
 * CMP-Weather: weather cells, forecasts through WeatherProvider, daily history, cell climate
 * metrics and zone assignment.
 */
class WeatherServiceProvider extends ModuleServiceProvider
{
    public function register(): void
    {
        // INT-002: EXT-002 is reached only through this interface.
        $this->app->singleton(WeatherProvider::class, fn () => match (config('weather.provider')) {
            'open-meteo' => new OpenMeteoWeatherProvider,
            default => new FakeWeatherProvider,
        });
    }

    public function boot(): void
    {
        parent::boot();

        if ($this->app->runningInConsole()) {
            $this->commands([ComputeCellsCommand::class]);
        }

        // DATA-009: zone rules changed in CMP-Catalogue, so every cell is re-assigned (queued).
        Event::listen(ClimateZoneRulesChanged::class, fn () => ReassignCellZones::dispatch());
    }
}
