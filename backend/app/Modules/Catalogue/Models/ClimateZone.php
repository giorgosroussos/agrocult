<?php

namespace App\Modules\Catalogue\Models;

use App\Modules\Catalogue\Database\Factories\ClimateZoneFactory;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * ENT-ClimateZone: one of the named climate zones of Greece (DATA-001).
 *
 * @property string $id
 * @property string $code
 * @property string $name_el
 * @property string $name_en
 * @property string|null $description
 * @property array<string, mixed> $rules
 */
class ClimateZone extends Model
{
    /** @use HasFactory<ClimateZoneFactory> */
    use HasFactory;

    use HasUuids;

    public $timestamps = false;

    protected $table = 'climate_zones';

    /** @var list<string> */
    protected $fillable = [
        'code',
        'name_el',
        'name_en',
        'description',
        'rules',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'rules' => 'array',
        ];
    }

    /**
     * @return HasMany<PlantCalendar, $this>
     */
    public function calendars(): HasMany
    {
        return $this->hasMany(PlantCalendar::class, 'climate_zone_id');
    }

    protected static function newFactory(): ClimateZoneFactory
    {
        return ClimateZoneFactory::new();
    }
}
