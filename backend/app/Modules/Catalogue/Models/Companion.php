<?php

namespace App\Modules\Catalogue\Models;

use App\Modules\Catalogue\Enums\CompanionRelation;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ENT-Companion: good or bad neighbour relation between two plants.
 *
 * @property string $id
 * @property string $plant_id
 * @property string $other_plant_id
 * @property CompanionRelation $relation
 */
class Companion extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $table = 'companions';

    /** @var list<string> */
    protected $fillable = [
        'plant_id',
        'other_plant_id',
        'relation',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'relation' => CompanionRelation::class,
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
     * @return BelongsTo<Plant, $this>
     */
    public function otherPlant(): BelongsTo
    {
        return $this->belongsTo(Plant::class, 'other_plant_id');
    }
}
