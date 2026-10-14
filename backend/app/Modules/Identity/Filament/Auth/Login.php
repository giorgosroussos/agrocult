<?php

namespace App\Modules\Identity\Filament\Auth;

use App\Modules\Identity\Models\User;
use Filament\Auth\Pages\Login as BaseLogin;
use SensitiveParameter;

/**
 * Admin panel sign-in. Emails are compared case-insensitively (stored lower-case).
 */
class Login extends BaseLogin
{
    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function getCredentialsFromFormData(#[SensitiveParameter] array $data): array
    {
        return [
            'email' => User::normalizeEmail((string) $data['email']),
            'password' => $data['password'],
        ];
    }
}
