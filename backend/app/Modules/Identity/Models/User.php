<?php

namespace App\Modules\Identity\Models;

use App\Modules\Identity\Casts\EncryptedJsonList;
use App\Modules\Identity\Database\Factories\UserFactory;
use App\Modules\Identity\Enums\Language;
use App\Modules\Identity\Enums\NotificationType;
use App\Modules\Identity\Enums\Role;
use Carbon\CarbonImmutable;
use Filament\Auth\MultiFactor\App\Contracts\HasAppAuthentication;
use Filament\Auth\MultiFactor\App\Contracts\HasAppAuthenticationRecovery;
use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasName;
use Filament\Panel;
use Illuminate\Auth\Passwords\CanResetPassword;
use Illuminate\Contracts\Auth\CanResetPassword as CanResetPasswordContract;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use SensitiveParameter;

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
 * @property string|null $app_authentication_secret TOTP secret (SEC-005), encrypted at rest
 * @property list<string>|null $app_authentication_recovery_codes hashed one-time recovery codes, encrypted at rest
 * @property CarbonImmutable|null $created_at
 */
class User extends Authenticatable implements CanResetPasswordContract, FilamentUser, HasAppAuthentication, HasAppAuthenticationRecovery, HasName
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
        'app_authentication_secret',
        'app_authentication_recovery_codes',
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
            'app_authentication_secret' => 'encrypted',
            'app_authentication_recovery_codes' => EncryptedJsonList::class,
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
     * SEC-005: only curators and admins may sign in to the admin panel.
     */
    public function canAccessPanel(Panel $panel): bool
    {
        return $this->isPanelUser();
    }

    /**
     * Accounts have no display name; the panel shows the email.
     */
    public function getFilamentName(): string
    {
        return $this->email;
    }

    public function isPanelUser(): bool
    {
        return in_array($this->role, [Role::Curator, Role::Admin], true);
    }

    public function isAdmin(): bool
    {
        return $this->role === Role::Admin;
    }

    public function hasMultiFactorAuthentication(): bool
    {
        return filled($this->app_authentication_secret);
    }

    /**
     * Clears the TOTP secret and recovery codes; the account must set up TOTP
     * again before it can use any other panel page.
     */
    public function resetMultiFactorAuthentication(): void
    {
        $this->app_authentication_secret = null;
        $this->app_authentication_recovery_codes = null;
        $this->save();
    }

    public function getAppAuthenticationSecret(): ?string
    {
        return $this->app_authentication_secret;
    }

    public function saveAppAuthenticationSecret(#[SensitiveParameter] ?string $secret): void
    {
        $this->app_authentication_secret = $secret;
        $this->save();
    }

    public function getAppAuthenticationHolderName(): string
    {
        return $this->email;
    }

    /**
     * @return ?array<string>
     */
    public function getAppAuthenticationRecoveryCodes(): ?array
    {
        return $this->app_authentication_recovery_codes;
    }

    /**
     * @param  ?array<string>  $codes  hashed by Filament before they arrive here
     */
    public function saveAppAuthenticationRecoveryCodes(#[SensitiveParameter] ?array $codes): void
    {
        $this->app_authentication_recovery_codes = $codes === null ? null : array_values($codes);
        $this->save();
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
