<?php

namespace App\Modules\Identity\Http\Resources;

use App\Modules\Identity\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin User
 */
class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'email' => $this->email,
            'email_verified_at' => $this->email_verified_at?->toIso8601ZuluString(),
            'role' => $this->role->value,
            'language' => $this->language->value,
            'notification_prefs' => $this->notificationPreferences(),
            'created_at' => $this->created_at?->toIso8601ZuluString(),
        ];
    }
}
