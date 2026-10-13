<?php

namespace App\Modules\Identity\Policies;

use App\Modules\Identity\Models\PushToken;
use App\Modules\Identity\Models\User;

/**
 * OWN-005: a user registers and removes only their own push tokens.
 */
class PushTokenPolicy
{
    public function view(User $actor, PushToken $pushToken): bool
    {
        return $actor->id === $pushToken->user_id;
    }

    public function delete(User $actor, PushToken $pushToken): bool
    {
        return $actor->id === $pushToken->user_id;
    }
}
