<?php

namespace App\Modules\Catalogue\Database\Factories;

use App\Modules\Catalogue\Models\PlantCategory;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<PlantCategory>
 */
class PlantCategoryFactory extends Factory
{
    protected $model = PlantCategory::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $code = $this->faker->unique()->lexify('category_????????');

        return [
            'code' => $code,
            'name_el' => $code,
            'name_en' => $code,
            'sort_order' => 0,
        ];
    }
}
