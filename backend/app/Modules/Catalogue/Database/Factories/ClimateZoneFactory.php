<?php

namespace App\Modules\Catalogue\Database\Factories;

use App\Modules\Catalogue\Models\ClimateZone;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ClimateZone>
 */
class ClimateZoneFactory extends Factory
{
    protected $model = ClimateZone::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $code = $this->faker->unique()->lexify('zone_????????');

        return [
            'code' => $code,
            'name_el' => $code,
            'name_en' => $code,
            'rules' => [],
        ];
    }
}
