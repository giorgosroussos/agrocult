<?php

namespace App\Modules\Identity;

use App\Modules\Identity\Console\CreatePanelAccount;
use App\Modules\Identity\Models\PersonalAccessToken;
use App\Modules\Identity\Models\PushToken;
use App\Modules\Identity\Models\User;
use App\Modules\Identity\Policies\PushTokenPolicy;
use App\Modules\Identity\Policies\UserPolicy;
use App\Support\Modules\ModuleServiceProvider;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\RateLimiter;
use Laravel\Sanctum\Sanctum;

/**
 * CMP-Identity: accounts, sign-up, sign-in, password reset, API tokens,
 * language and notification preferences, push tokens.
 */
class IdentityServiceProvider extends ModuleServiceProvider
{
    public function boot(): void
    {
        parent::boot();

        $this->loadViewsFrom($this->modulePath().'/resources/views', 'identity');
        $this->loadTranslationsFrom($this->modulePath().'/resources/lang', 'identity');

        if ($this->app->runningInConsole()) {
            $this->commands([CreatePanelAccount::class]);
        }

        Sanctum::usePersonalAccessTokenModel(PersonalAccessToken::class);

        Gate::policy(User::class, UserPolicy::class);
        Gate::policy(PushToken::class, PushTokenPolicy::class);

        // SEC-001: 5 sign-in attempts per minute per email and IP.
        RateLimiter::for('identity-sign-in', function (Request $request) {
            $email = User::normalizeEmail((string) $request->input('email', ''));

            return Limit::perMinute((int) config('identity.sign_in_attempts_per_minute', 5))
                ->by(sha1($email).'|'.$request->ip());
        });

        RateLimiter::for('identity-email', function (Request $request) {
            return Limit::perMinute((int) config('identity.email_requests_per_minute', 6))
                ->by((string) $request->ip());
        });
    }
}
