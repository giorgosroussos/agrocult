<?php

namespace App\Modules\Catalogue\Models;

use App\Modules\Catalogue\Database\Factories\PlantCategoryFactory;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * ENT-PlantCategory: curator-managed plant category with an optional parent (DATA-004).
 *
 * @property string $id
 * @property string $code
 * @property string $name_el
 * @property string $name_en
 * @property string|null $parent_id
 * @property int|null $sort_order
 */
class PlantCategory extends Model
{
    /** @use HasFactory<PlantCategoryFactory> */
    use HasFactory;

    use HasUuids;

    public $timestamps = false;

    protected $table = 'plant_categories';

    /** @var list<string> */
    protected $fillable = [
        'code',
        'name_el',
        'name_en',
        'parent_id',
        'sort_order',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
        ];
    }

    /**
     * @return BelongsTo<PlantCategory, $this>
     */
    public function parent(): BelongsTo
    {
        return $this->belongsTo(PlantCategory::class, 'parent_id');
    }

    /**
     * @return HasMany<PlantCategory, $this>
     */
    public function children(): HasMany
    {
        return $this->hasMany(PlantCategory::class, 'parent_id');
    }

    /**
     * @return HasMany<Plant, $this>
     */
    public function plants(): HasMany
    {
        return $this->hasMany(Plant::class, 'category_id');
    }

    protected static function newFactory(): PlantCategoryFactory
    {
        return PlantCategoryFactory::new();
    }
}
