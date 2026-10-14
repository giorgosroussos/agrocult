<?php

namespace App\Modules\Catalogue\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

/**
 * ENT-Settlement: Greek settlement for area search, derived from OpenStreetMap.
 *
 * @property string $id
 * @property string $name_el
 * @property string|null $name_en
 * @property string|null $region
 * @property string $lat
 * @property string $lon
 */
class Settlement extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $table = 'settlements';

    /** @var list<string> */
    protected $fillable = [
        'name_el',
        'name_en',
        'region',
        'lat',
        'lon',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'lat' => 'decimal:6',
            'lon' => 'decimal:6',
        ];
    }
}
