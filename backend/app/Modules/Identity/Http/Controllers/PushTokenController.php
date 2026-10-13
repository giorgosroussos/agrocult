<?php

namespace App\Modules\Identity\Http\Controllers;

use App\Modules\Identity\Enums\Platform;
use App\Modules\Identity\Http\Resources\PushTokenResource;
use App\Modules\Identity\Models\PushToken;
use App\Modules\Identity\Models\User;
use App\Support\Http\ProblemDetails;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;

/**
 * OWN-005: a gardener registers and removes only their own push tokens.
 */
class PushTokenController
{
    public function index(Request $request): AnonymousResourceCollection
    {
        /** @var User $user */
        $user = $request->user();

        return PushTokenResource::collection($user->pushTokens()->orderBy('id')->paginate());
    }

    public function store(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $data = $request->validate([
            'token' => ['required', 'string', 'max:255'],
            'platform' => ['required', Rule::enum(Platform::class)],
        ]);

        $existing = PushToken::query()->where('token', $data['token'])->first();

        if ($existing !== null && $existing->user_id !== $user->id) {
            return ProblemDetails::response(Response::HTTP_FORBIDDEN, $request, __('identity::auth.push_token_taken'));
        }

        $pushToken = $existing ?? new PushToken(['token' => $data['token']]);
        $pushToken->user_id = $user->id;
        $pushToken->platform = Platform::from($data['platform']);
        $pushToken->last_seen_at = now()->toImmutable();
        $pushToken->save();

        return (new PushTokenResource($pushToken))
            ->response($request)
            ->setStatusCode($existing === null ? Response::HTTP_CREATED : Response::HTTP_OK);
    }

    public function destroy(PushToken $pushToken): Response
    {
        Gate::authorize('delete', $pushToken);

        $pushToken->delete();

        return response()->noContent();
    }
}
