<?php

namespace App\Modules\Identity\Http\Controllers;

use App\Modules\Identity\Enums\Language;
use App\Modules\Identity\Enums\NotificationType;
use App\Modules\Identity\Enums\Role;
use App\Modules\Identity\Http\Resources\UserResource;
use App\Modules\Identity\Models\PersonalAccessToken;
use App\Modules\Identity\Models\User;
use App\Modules\Identity\Services\AccountMailer;
use App\Support\Http\ProblemDetails;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

/**
 * UC-012: sign-up, sign-in and sign-out. No response reveals whether an
 * email address is registered (DEC-004).
 */
class AuthController
{
    public function __construct(private readonly AccountMailer $mailer) {}

    public function signUp(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'string', 'email:rfc', 'max:254'],
            'password' => ['required', 'string', 'min:8', 'max:255'],
            // SEC-004: the visitor confirms they are at least 15 years old.
            'age_confirmed' => ['required', 'accepted'],
            'language' => ['required', Rule::enum(Language::class)],
        ]);

        $email = User::normalizeEmail($data['email']);
        // Hash before the lookup so both paths take the same time.
        $passwordHash = Hash::make($data['password']);

        if (! User::query()->where('email', $email)->exists()) {
            try {
                $user = User::query()->create([
                    'email' => $email,
                    'password_hash' => $passwordHash,
                    'role' => Role::Gardener,
                    'language' => Language::from($data['language']),
                    'notification_prefs' => NotificationType::defaultPreferences(),
                ]);
                $this->mailer->sendVerification($user);
            } catch (UniqueConstraintViolationException) {
                // Registered concurrently: answer exactly as for an existing account.
            }
        }

        return new JsonResponse(['message' => __('identity::auth.sign_up_accepted')], Response::HTTP_ACCEPTED);
    }

    public function signIn(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'string', 'max:254'],
            'password' => ['required', 'string', 'max:255'],
            // Stable id of the app installation: one API token per device (SEC-001).
            'device_id' => ['required', 'string', 'max:100'],
        ]);

        $user = User::query()->where('email', User::normalizeEmail($data['email']))->first();

        if ($user === null) {
            // Same work and the same answer as a wrong password.
            Hash::check($data['password'], self::dummyHash());

            throw self::failed();
        }

        if (! Hash::check($data['password'], $user->password_hash)) {
            throw self::failed();
        }

        if (! $user->hasVerifiedEmail()) {
            return ProblemDetails::response(
                Response::HTTP_FORBIDDEN,
                $request,
                __('identity::auth.unverified'),
                ['code' => 'email_not_verified'],
            );
        }

        if (Hash::needsRehash($user->password_hash)) {
            $user->password_hash = Hash::make($data['password']);
            $user->save();
        }

        $user->tokens()->where('name', $data['device_id'])->delete();
        $token = $user->createToken($data['device_id']);

        return new JsonResponse([
            'token' => $token->plainTextToken,
            'token_type' => 'Bearer',
            'user' => (new UserResource($user))->resolve($request),
        ]);
    }

    public function signOut(Request $request): Response
    {
        $data = $request->validate([
            'push_token' => ['nullable', 'string', 'max:255'],
        ]);

        /** @var User $user */
        $user = $request->user();

        $token = $user->currentAccessToken();
        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }

        if (! empty($data['push_token'])) {
            $user->pushTokens()->where('token', $data['push_token'])->delete();
        }

        return response()->noContent();
    }

    private static function failed(): ValidationException
    {
        return ValidationException::withMessages(['email' => __('identity::auth.failed')]);
    }

    private static function dummyHash(): string
    {
        static $hash = null;

        return $hash ??= Hash::make('agrocult-dummy-password');
    }
}
