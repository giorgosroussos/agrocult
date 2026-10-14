<?php

namespace App\Modules\Catalogue\Models;

use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ENT-FactSource: provenance (source and licence) of an imported catalogue fact (SCOPE-001).
 *
 * @property string $id
 * @property string $plant_id
 * @property string $field
 * @property string $source_name
 * @property string|null $source_url
 * @property string $licence
 * @property CarbonImmutable|null $imported_at
 */
class FactSource extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $table = 'fact_sources';

    /** @var list<string> */
    protected $fillable = [
        'plant_id',
        'field',
        'source_name',
        'source_url',
        'licence',
        'imported_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'imported_at' => 'immutable_datetime',
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
