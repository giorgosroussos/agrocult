<?php

namespace App\Modules\Identity\Database\Factories;

use App\Modules\Identity\Enums\Platform;
use App\Modules\Identity\Models\PushToken;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<PushToken>
 */
class PushTokenFactory extends Factory
{
    protected $model = PushToken::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'token' => Str::random(152),
            'platform' => Platform::Android,
            'last_seen_at' => now(),
        ];
    }
}
