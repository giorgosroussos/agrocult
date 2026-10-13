<?php

namespace App\Modules\Identity\Policies;

use App\Modules\Identity\Models\User;

/**
 * OWN-007: a user reads, changes, exports and deletes only their own account.
 */
class UserPolicy
{
    public function view(User $actor, User $account): bool
    {
        return $actor->id === $account->id;
    }

    public function update(User $actor, User $account): bool
    {
        return $actor->id === $account->id;
    }

    public function delete(User $actor, User $account): bool
    {
        return $actor->id === $account->id;
    }
}
