<?php

namespace App\Modules\Identity\Enums;

/**
 * Notification types a user can switch on or off (ENT-Notification.type).
 */
enum NotificationType: string
{
    case Summary = 'summary';
    case Frost = 'frost';
    case Heatwave = 'heatwave';

    /**
     * Preferences of a new account: every type switched on.
     *
     * @return array<string, bool>
     */
    public static function defaultPreferences(): array
    {
        $prefs = [];
        foreach (self::cases() as $case) {
            $prefs[$case->value] = true;
        }

        return $prefs;
    }

    /**
     * @return list<string>
     */
    public static function values(): array
    {
        return array_map(fn (self $case) => $case->value, self::cases());
    }
}
