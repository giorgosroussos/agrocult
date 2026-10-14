<?php

namespace App\Modules\Catalogue\Database\Factories;

use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Services\PlantWorkflow;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Plants are created as draft (the state model's initial state); the status states
 * walk the plant through PlantWorkflow after creation.
 *
 * @extends Factory<Plant>
 */
class PlantFactory extends Factory
{
    protected $model = Plant::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'scientific_name' => ucfirst($this->faker->unique()->lexify('??????')).' '.$this->faker->lexify('??????'),
            'category_id' => PlantCategory::factory(),
        ];
    }

    public function inReview(): static
    {
        return $this->afterCreating(function (Plant $plant): void {
            app(PlantWorkflow::class)->transition($plant, PlantStatus::InReview);
        });
    }

    public function published(): static
    {
        return $this->inReview()->afterCreating(function (Plant $plant): void {
            app(PlantWorkflow::class)->transition($plant, PlantStatus::Published);
        });
    }

    public function archived(): static
    {
        return $this->published()->afterCreating(function (Plant $plant): void {
            app(PlantWorkflow::class)->transition($plant, PlantStatus::Archived);
        });
    }
}
