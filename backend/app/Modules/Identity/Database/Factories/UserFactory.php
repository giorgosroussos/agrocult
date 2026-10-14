<?php

namespace App\Modules\Identity\Database\Factories;

use App\Modules\Identity\Enums\Language;
use App\Modules\Identity\Enums\NotificationType;
use App\Modules\Identity\Enums\Role;
use App\Modules\Identity\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    protected $model = User::class;

    private static ?string $passwordHash = null;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'email' => fake()->unique()->safeEmail(),
            'password_hash' => self::$passwordHash ??= Hash::make('password-1234'),
            'email_verified_at' => now(),
            'role' => Role::Gardener,
            'language' => Language::Greek,
            'notification_prefs' => NotificationType::defaultPreferences(),
        ];
    }

    public function unverified(): static
    {
        return $this->state(fn () => ['email_verified_at' => null]);
    }

    public function role(Role $role): static
    {
        return $this->state(fn () => ['role' => $role]);
    }

    /**
     * A confirmed TOTP secret and the hashes of the given recovery codes.
     *
     * @param  list<string>  $recoveryCodes  plain recovery codes; stored hashed
     */
    public function withAppAuthentication(string $secret, array $recoveryCodes = []): static
    {
        return $this->afterCreating(function (User $user) use ($secret, $recoveryCodes) {
            $user->saveAppAuthenticationSecret($secret);
            $user->saveAppAuthenticationRecoveryCodes(array_map(fn (string $code) => Hash::make($code), $recoveryCodes));
        });
    }
}
