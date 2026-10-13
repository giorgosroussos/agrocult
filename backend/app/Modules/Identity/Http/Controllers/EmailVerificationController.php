<?php

namespace App\Modules\Identity\Http\Controllers;

use App\Modules\Identity\Models\User;
use App\Modules\Identity\Services\AccountMailer;
use App\Support\Http\ProblemDetails;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

/**
 * UC-012 step 2: the email is confirmed through a signed, expiring link.
 */
class EmailVerificationController
{
    public function __construct(private readonly AccountMailer $mailer) {}

    public function verify(Request $request, string $user, string $hash): JsonResponse
    {
        $account = User::query()->find($user);

        if ($account === null || ! hash_equals(sha1($account->email), $hash)) {
            return ProblemDetails::response(Response::HTTP_FORBIDDEN, $request, __('identity::auth.verification_invalid'));
        }

        if (! $account->hasVerifiedEmail()) {
            $account->email_verified_at = now()->toImmutable();
            $account->save();
        }

        return new JsonResponse(['message' => __('identity::auth.verified')]);
    }

    /**
     * A new verification email; the answer is the same for every address.
     */
    public function resend(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'string', 'max:254'],
        ]);

        $user = User::query()->where('email', User::normalizeEmail($data['email']))->first();

        if ($user !== null && ! $user->hasVerifiedEmail()) {
            $this->mailer->sendVerification($user);
        }

        return new JsonResponse(['message' => __('identity::auth.verification_sent')], Response::HTTP_ACCEPTED);
    }
}
