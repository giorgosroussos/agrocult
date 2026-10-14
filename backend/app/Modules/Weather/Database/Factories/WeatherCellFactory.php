<?php

namespace App\Modules\Weather\Database\Factories;

use App\Modules\Weather\Models\WeatherCell;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WeatherCell>
 */
class WeatherCellFactory extends Factory
{
    protected $model = WeatherCell::class;

    /**
     * A cell without metrics on the 0.1° grid over Greece.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'lat' => $this->faker->unique()->numberBetween(350, 415) / 10,
            'lon' => $this->faker->numberBetween(200, 280) / 10,
        ];
    }

    public function withMetrics(int $elevation = 50, float $winterMin = 6.0, ?int $lastFrost = null, ?int $firstFrost = null): self
    {
        return $this->state([
            'elevation_m' => $elevation,
            'winter_min_mean_c' => $winterMin,
            'last_frost_doy' => $lastFrost,
            'first_frost_doy' => $firstFrost,
        ]);
    }
}
