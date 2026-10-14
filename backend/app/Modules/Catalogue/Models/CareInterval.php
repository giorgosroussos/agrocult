<?php

namespace App\Modules\Catalogue\Models;

use App\Modules\Catalogue\Enums\CareAction;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ENT-CareInterval: how often a care action is due, optionally only in some months (DEC-004).
 *
 * @property string $id
 * @property string $plant_id
 * @property CareAction $action
 * @property int $interval_days
 * @property int|null $month_from
 * @property int|null $month_to
 */
class CareInterval extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $table = 'care_intervals';

    /** @var list<string> */
    protected $fillable = [
        'plant_id',
        'action',
        'interval_days',
        'month_from',
        'month_to',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'action' => CareAction::class,
            'interval_days' => 'integer',
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
}
