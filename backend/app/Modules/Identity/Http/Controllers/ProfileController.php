<?php

namespace App\Modules\Identity\Http\Controllers;

use App\Modules\Identity\Enums\Language;
use App\Modules\Identity\Enums\NotificationType;
use App\Modules\Identity\Http\Resources\UserResource;
use App\Modules\Identity\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;

/**
 * The signed-in user's own account (OWN-007): language and notification
 * preferences. There is no endpoint that addresses another user.
 */
class ProfileController
{
    public function show(Request $request): UserResource
    {
        /** @var User $user */
        $user = $request->user();
        Gate::authorize('view', $user);

        return new UserResource($user);
    }

    public function update(Request $request): UserResource
    {
        /** @var User $user */
        $user = $request->user();
        Gate::authorize('update', $user);

        $types = NotificationType::values();

        $data = $request->validate([
            'language' => ['sometimes', Rule::enum(Language::class)],
            'notification_prefs' => ['sometimes', 'array:'.implode(',', $types)],
            'notification_prefs.*' => ['boolean'],
        ]);

        if (array_key_exists('language', $data)) {
            $user->language = Language::from($data['language']);
        }

        if (array_key_exists('notification_prefs', $data)) {
            $prefs = $user->notificationPreferences();
            foreach ($data['notification_prefs'] as $type => $enabled) {
                $prefs[$type] = (bool) $enabled;
            }
            $user->notification_prefs = $prefs;
        }

        $user->save();

        return new UserResource($user);
    }
}
