<?php

namespace App\Modules\Catalogue\Models;

use App\Modules\Catalogue\Enums\AliasKind;
use App\Modules\Catalogue\Enums\TextLanguage;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ENT-PlantAlias: synonym, local name or Greeklish spelling used by search.
 *
 * @property string $id
 * @property string $plant_id
 * @property TextLanguage|null $lang
 * @property string $alias
 * @property AliasKind|null $kind
 */
class PlantAlias extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $table = 'plant_aliases';

    /** @var list<string> */
    protected $fillable = [
        'plant_id',
        'lang',
        'alias',
        'kind',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'lang' => TextLanguage::class,
            'kind' => AliasKind::class,
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
