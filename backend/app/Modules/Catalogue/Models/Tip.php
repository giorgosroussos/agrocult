<?php

namespace App\Modules\Catalogue\Models;

use App\Modules\Catalogue\Enums\TipStatus;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ENT-Tip: short tip or fact for the home screen, optionally tied to months, a climate zone or a plant.
 *
 * @property string $id
 * @property string $text_el
 * @property string $text_en
 * @property int|null $month_from
 * @property int|null $month_to
 * @property string|null $climate_zone_id
 * @property string|null $plant_id
 * @property TipStatus|null $status
 */
class Tip extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $table = 'tips';

    /** @var array<string, mixed> */
    protected $attributes = [
        'status' => 'draft',
    ];

    /** @var list<string> */
    protected $fillable = [
        'text_el',
        'text_en',
        'month_from',
        'month_to',
        'climate_zone_id',
        'plant_id',
        'status',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'month_from' => 'integer',
            'month_to' => 'integer',
            'status' => TipStatus::class,
        ];
    }

    /**
     * Only published tips go to the catalogue snapshot and to devices (ARCH-003).
     *
     * @param  Builder<Tip>  $query
     */
    public function scopePublished(Builder $query): void
    {
        $query->where('status', TipStatus::Published->value);
    }

    /**
     * @return BelongsTo<ClimateZone, $this>
     */
    public function climateZone(): BelongsTo
    {
        return $this->belongsTo(ClimateZone::class, 'climate_zone_id');
    }

    /**
     * @return BelongsTo<Plant, $this>
     */
    public function plant(): BelongsTo
    {
        return $this->belongsTo(Plant::class, 'plant_id');
    }
}
