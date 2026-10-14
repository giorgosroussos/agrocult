<?php

namespace App\Modules\Catalogue\Policies;

use App\Modules\Catalogue\Models\PlantCategory;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Model;

/**
 * A category is deleted only while no plant and no sub-category uses it
 * (ENT-PlantCategory -> ENT-Plant: on delete restrict).
 */
class PlantCategoryPolicy extends CataloguePolicy
{
    public function delete(Authenticatable $user, Model $record): bool
    {
        return $this->curates($user)
            && $record instanceof PlantCategory
            && ! $record->plants()->exists()
            && ! $record->children()->exists();
    }
}
