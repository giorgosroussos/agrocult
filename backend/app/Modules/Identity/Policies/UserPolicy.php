<?php

namespace App\Modules\Identity\Policies;

use App\Modules\Identity\Models\User;

/**
 * OWN-007: a user reads, changes, exports and deletes only their own account.
 * SEC-005: only the admin lists accounts in the admin panel and resets another
 * account's MFA; a curator may not.
 */
class UserPolicy
{
    public function viewAny(User $actor): bool
    {
        return $actor->isAdmin();
    }

    public function view(User $actor, User $account): bool
    {
        return $actor->id === $account->id;
    }

    public function create(User $actor): bool
    {
        return false;
    }

    public function update(User $actor, User $account): bool
    {
        return $actor->id === $account->id;
    }

    public function delete(User $actor, User $account): bool
    {
        return $actor->id === $account->id;
    }

    public function deleteAny(User $actor): bool
    {
        return false;
    }

    public function resetMultiFactorAuthentication(User $actor, User $account): bool
    {
        return $actor->isAdmin() && $actor->id !== $account->id;
    }
}
