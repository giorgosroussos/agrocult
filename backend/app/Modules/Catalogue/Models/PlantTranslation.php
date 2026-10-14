<?php

namespace App\Modules\Catalogue\Models;

use App\Modules\Catalogue\Enums\TextLanguage;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ENT-PlantTranslation: texts of a plant in one language (one row per language).
 *
 * @property string $id
 * @property string $plant_id
 * @property TextLanguage $lang
 * @property string $name
 * @property string|null $description
 * @property string|null $planting
 * @property string|null $care
 * @property string|null $seed_saving
 * @property string|null $tips
 */
class PlantTranslation extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $table = 'plant_translations';

    /** @var list<string> */
    protected $fillable = [
        'plant_id',
        'lang',
        'name',
        'description',
        'planting',
        'care',
        'seed_saving',
        'tips',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'lang' => TextLanguage::class,
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
