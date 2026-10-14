<?php

namespace App\Modules\Catalogue\Models;

use App\Modules\Catalogue\Enums\CalendarActivity;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ENT-PlantCalendar: month range for an activity in one climate zone; month_to may wrap past December.
 *
 * @property string $id
 * @property string $plant_id
 * @property string $climate_zone_id
 * @property CalendarActivity $activity
 * @property int $month_from
 * @property int $month_to
 */
class PlantCalendar extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $table = 'plant_calendars';

    /** @var list<string> */
    protected $fillable = [
        'plant_id',
        'climate_zone_id',
        'activity',
        'month_from',
        'month_to',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'activity' => CalendarActivity::class,
            'month_from' => 'integer',
            'month_to' => 'integer',
        ];
    }

    /**
     * @return BelongsTo<Plant, $this>
     */
    public function plant(): BelongsTo
    {
        return $this->belongsTo(Plant::class, 'plant_id');
    }

    /**
     * @return BelongsTo<ClimateZone, $this>
     */
    public function climateZone(): BelongsTo
    {
        return $this->belongsTo(ClimateZone::class, 'climate_zone_id');
    }
}
