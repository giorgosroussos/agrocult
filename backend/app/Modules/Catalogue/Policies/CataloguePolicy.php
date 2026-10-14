<?php

namespace App\Modules\Catalogue\Policies;

use Filament\Facades\Filament;
use Filament\Models\Contracts\FilamentUser;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Model;

/**
 * UC-010: catalogue content is curated only by accounts that may use the admin panel
 * (curators and admins, SEC-005). Gardener accounts are denied every ability.
 */
class CataloguePolicy
{
    public function viewAny(Authenticatable $user): bool
    {
        return $this->curates($user);
    }

    public function view(Authenticatable $user, Model $record): bool
    {
        return $this->curates($user);
    }

    public function create(Authenticatable $user): bool
    {
        return $this->curates($user);
    }

    public function update(Authenticatable $user, Model $record): bool
    {
        return $this->curates($user);
    }

    public function delete(Authenticatable $user, Model $record): bool
    {
        return $this->curates($user);
    }

    public function deleteAny(Authenticatable $user): bool
    {
        return false;
    }

    public function reorder(Authenticatable $user): bool
    {
        return $this->curates($user);
    }

    protected function curates(Authenticatable $user): bool
    {
        $panel = Filament::getDefaultPanel();

        return $user instanceof FilamentUser && $user->canAccessPanel($panel);
    }
}
