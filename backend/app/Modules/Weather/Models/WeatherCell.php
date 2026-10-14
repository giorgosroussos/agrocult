<?php

namespace App\Modules\Weather\Models;

use App\Modules\Weather\Climate\ClimateMetrics;
use App\Modules\Weather\Database\Factories\WeatherCellFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * ENT-WeatherCell: a grid cell of about 10 km (config weather.grid_step). One forecast and one
 * set of climate metrics per cell serve all its gardens (DATA-001, DATA-009).
 *
 * @property string $id
 * @property float $lat
 * @property float $lon
 * @property int|null $elevation_m
 * @property float|null $winter_min_mean_c
 * @property int|null $last_frost_doy
 * @property int|null $first_frost_doy
 * @property string|null $climate_zone_id
 */
class WeatherCell extends Model
{
    /** @use HasFactory<WeatherCellFactory> */
    use HasFactory;

    use HasUuids;

    public $timestamps = false;

    protected $table = 'weather_cells';

    /** @var list<string> */
    protected $fillable = [
        'lat',
        'lon',
        'elevation_m',
        'winter_min_mean_c',
        'last_frost_doy',
        'first_frost_doy',
        'climate_zone_id',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'lat' => 'float',
            'lon' => 'float',
            'elevation_m' => 'integer',
            'winter_min_mean_c' => 'float',
            'last_frost_doy' => 'integer',
            'first_frost_doy' => 'integer',
        ];
    }

    public function hasMetrics(): bool
    {
        return $this->elevation_m !== null && $this->winter_min_mean_c !== null;
    }

    public function metrics(): ?ClimateMetrics
    {
        if ($this->elevation_m === null || $this->winter_min_mean_c === null) {
            return null;
        }

        return new ClimateMetrics($this->elevation_m, $this->winter_min_mean_c, $this->last_frost_doy, $this->first_frost_doy);
    }

    /**
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeWithMetrics(Builder $query): Builder
    {
        return $query->whereNotNull('elevation_m')->whereNotNull('winter_min_mean_c');
    }

    protected static function newFactory(): WeatherCellFactory
    {
        return WeatherCellFactory::new();
    }
}
