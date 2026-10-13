<?php

namespace App\Modules\Identity\Models;

use App\Modules\Identity\Database\Factories\UserFactory;
use App\Modules\Identity\Enums\Language;
use App\Modules\Identity\Enums\NotificationType;
use App\Modules\Identity\Enums\Role;
use Carbon\CarbonImmutable;
use Illuminate\Auth\Passwords\CanResetPassword;
use Illuminate\Contracts\Auth\CanResetPassword as CanResetPasswordContract;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

/**
 * ENT-User: account of a gardener, curator or admin.
 *
 * @property string $id
 * @property string $email
 * @property string $password_hash
 * @property CarbonImmutable|null $email_verified_at
 * @property Role $role
 * @property Language $language
 * @property array<string, bool>|null $notification_prefs
 * @property CarbonImmutable|null $created_at
 */
class User extends Authenticatable implements CanResetPasswordContract
{
    use CanResetPassword;
    use HasApiTokens;

    /** @use HasFactory<UserFactory> */
    use HasFactory;

    use HasUuids;

    public const UPDATED_AT = null;

    protected $table = 'users';

    protected $authPasswordName = 'password_hash';

    /** @var list<string> */
    protected $fillable = [
        'email',
        'password_hash',
        'role',
        'language',
        'notification_prefs',
    ];

    /** @var list<string> */
    protected $hidden = [
        'password_hash',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'immutable_datetime',
            'created_at' => 'immutable_datetime',
            'password_hash' => 'hashed',
            'role' => Role::class,
            'language' => Language::class,
            'notification_prefs' => 'array',
        ];
    }

    /**
     * Emails are compared case-insensitively, so they are stored lower-case.
     *
     * @return Attribute<string, string>
     */
    protected function email(): Attribute
    {
        return Attribute::make(set: fn (string $value) => self::normalizeEmail($value));
    }

    public static function normalizeEmail(string $email): string
    {
        return mb_strtolower(trim($email));
    }

    public function hasVerifiedEmail(): bool
    {
        return $this->email_verified_at !== null;
    }

    /**
     * Notification preferences with every known type present.
     *
     * @return array<string, bool>
     */
    public function notificationPreferences(): array
    {
        $prefs = NotificationType::defaultPreferences();

        foreach ($this->notification_prefs ?? [] as $type => $enabled) {
            if (array_key_exists($type, $prefs)) {
                $prefs[$type] = (bool) $enabled;
            }
        }

        return $prefs;
    }

    /**
     * @return HasMany<PushToken, $this>
     */
    public function pushTokens(): HasMany
    {
        return $this->hasMany(PushToken::class);
    }

    protected static function newFactory(): UserFactory
    {
        return UserFactory::new();
    }
}
