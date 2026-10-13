<?php

namespace App\Modules\Identity\Http\Controllers;

use App\Modules\Identity\Models\User;
use App\Modules\Identity\Services\AccountMailer;
use Illuminate\Contracts\Auth\PasswordBroker;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;

/**
 * UC-013: password reset with a one-time, expiring link.
 */
class PasswordResetController
{
    public function __construct(private readonly AccountMailer $mailer) {}

    /**
     * The answer is the same whether or not the email is registered
     * (and whether or not a link was sent recently).
     */
    public function forgot(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'string', 'max:254'],
        ]);

        Password::broker()->sendResetLink(
            ['email' => User::normalizeEmail($data['email'])],
            function (User $user, string $token): void {
                $this->mailer->sendPasswordReset($user, $token);
            },
        );

        return new JsonResponse(['message' => __('identity::auth.reset_sent')], Response::HTTP_ACCEPTED);
    }

    public function reset(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'max:254'],
            'password' => ['required', 'string', 'min:8', 'max:255'],
        ]);

        // The broker deletes the token once used, so a link works only once.
        $status = Password::broker()->reset(
            [
                'email' => User::normalizeEmail($data['email']),
                'token' => $data['token'],
                'password' => $data['password'],
            ],
            function (User $user, string $password): void {
                $user->password_hash = Hash::make($password);
                $user->save();
                // SEC-001: a password change revokes every API token of the user.
                $user->tokens()->delete();
            },
        );

        if ($status !== PasswordBroker::PASSWORD_RESET) {
            throw ValidationException::withMessages(['token' => __('identity::auth.reset_invalid')]);
        }

        return new JsonResponse(['message' => __('identity::auth.reset_done')]);
    }
}
