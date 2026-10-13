<?php

namespace App\Modules\Identity\Http\Resources;

use App\Modules\Identity\Models\PushToken;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin PushToken
 */
class PushTokenResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'token' => $this->token,
            'platform' => $this->platform?->value,
            'last_seen_at' => $this->last_seen_at?->toIso8601ZuluString(),
        ];
    }
}
