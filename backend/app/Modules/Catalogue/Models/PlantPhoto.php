<?php

namespace App\Modules\Catalogue\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ENT-PlantPhoto: catalogue photo with credit and licence; file_path is on the Laravel filesystem.
 *
 * @property string $id
 * @property string $plant_id
 * @property string $file_path
 * @property string $credit
 * @property string $licence
 * @property string|null $source_url
 */
class PlantPhoto extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $table = 'plant_photos';

    /** @var list<string> */
    protected $fillable = [
        'plant_id',
        'file_path',
        'credit',
        'licence',
        'source_url',
    ];

    /**
     * @return BelongsTo<Plant, $this>
     */
    public function plant(): BelongsTo
    {
        return $this->belongsTo(Plant::class, 'plant_id');
    }
}
