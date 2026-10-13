<?php

namespace App\Modules\Identity\Services;

use App\Modules\Identity\Mail\ResetPasswordMail;
use App\Modules\Identity\Mail\VerifyEmailMail;
use App\Modules\Identity\Models\User;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\URL;

/**
 * INT-004: account emails through Laravel Mail (queued, never sent inline).
 */
class AccountMailer
{
    public function sendVerification(User $user): void
    {
        $minutes = (int) config('identity.verification_link_minutes', 60);

        $url = URL::temporarySignedRoute(
            'identity.email.verify',
            now()->addMinutes($minutes),
            ['user' => $user->id, 'hash' => sha1($user->email)],
        );

        Mail::to($user->email)
            ->locale($user->language->value)
            ->queue(new VerifyEmailMail($url, $minutes));
    }

    public function sendPasswordReset(User $user, string $token): void
    {
        $minutes = (int) config('auth.passwords.users.expire', 60);
        $base = (string) config('identity.password_reset_url');

        $url = $base.(str_contains($base, '?') ? '&' : '?').http_build_query([
            'token' => $token,
            'email' => $user->email,
        ]);

        Mail::to($user->email)
            ->locale($user->language->value)
            ->queue(new ResetPasswordMail($url, $minutes));
    }
}
