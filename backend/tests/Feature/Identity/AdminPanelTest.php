<?php

use App\Modules\Identity\Enums\Role;
use App\Modules\Identity\Filament\AdminPanelProvider;
use App\Modules\Identity\Filament\Auth\Login;
use App\Modules\Identity\Filament\Resources\Users\Pages\ListUsers;
use App\Modules\Identity\Models\User;
use Filament\Actions\Testing\TestAction;
use Filament\Auth\MultiFactor\App\AppAuthentication;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Log;
use Laravel\Sanctum\Sanctum;
use Livewire\Livewire;

uses(RefreshDatabase::class);

const PANEL_PASSWORD = 'password-1234';

beforeEach(function () {
    Filament::setCurrentPanel(Filament::getPanel(AdminPanelProvider::ID));

    $this->totp = Filament::getPanel(AdminPanelProvider::ID)->getMultiFactorAuthenticationProviders()['app'];
    $this->secret = $this->totp->generateSecret();
});

function panelAccount(Role $role, ?string $secret = null, array $recoveryCodes = []): User
{
    $factory = User::factory()->role($role);

    return ($secret === null ? $factory : $factory->withAppAuthentication($secret, $recoveryCodes))->create();
}

function totpCode(AppAuthentication $totp, string $secret): string
{
    return $totp->getCurrentCode(new User(['app_authentication_secret' => null]), $secret);
}

it('requires TOTP for every panel account, with one-time recovery codes (SEC-005)', function () {
    $panel = Filament::getPanel(AdminPanelProvider::ID);

    expect($panel->isMultiFactorAuthenticationRequired())->toBeTrue()
        ->and(array_keys($panel->getMultiFactorAuthenticationProviders()))->toBe(['app'])
        ->and($this->totp->isRecoverable())->toBeTrue();
});

it('does not let a gardener account sign in to the admin panel (SEC-005)', function () {
    $gardener = User::factory()->create(['email' => 'gardener@example.com']);

    Livewire::test(Login::class)
        ->fillForm(['email' => 'gardener@example.com', 'password' => PANEL_PASSWORD])
        ->call('authenticate')
        ->assertHasFormErrors(['email']);

    $this->assertGuest();

    // Even with a session of the web guard, every panel page is forbidden.
    $this->actingAs($gardener)->get('/admin')->assertForbidden();
    $this->actingAs($gardener)->get('/admin/users')->assertForbidden();
    $this->actingAs($gardener)->get('/admin/multi-factor-authentication/set-up')->assertForbidden();
});

it('answers a gardener exactly like a wrong password on the panel sign-in', function () {
    User::factory()->create(['email' => 'gardener@example.com']);
    panelAccount(Role::Curator)->update(['email' => 'curator@example.com']);

    $gardener = Livewire::test(Login::class)
        ->fillForm(['email' => 'gardener@example.com', 'password' => PANEL_PASSWORD])
        ->call('authenticate')
        ->errors()->toArray();

    $wrongPassword = Livewire::test(Login::class)
        ->fillForm(['email' => 'curator@example.com', 'password' => 'wrong-password'])
        ->call('authenticate')
        ->errors()->toArray();

    expect($gardener)->toBe($wrongPassword);
});

it('forces a curator or admin without TOTP to set it up before any other panel page (SEC-005)', function (Role $role) {
    $account = panelAccount($role);

    Livewire::test(Login::class)
        ->fillForm(['email' => strtoupper($account->email), 'password' => PANEL_PASSWORD])
        ->call('authenticate')
        ->assertHasNoFormErrors();

    $this->assertAuthenticatedAs($account);

    $setUp = '/admin/multi-factor-authentication/set-up';
    $this->get('/admin')->assertRedirect($setUp);
    $this->get('/admin/users')->assertRedirect($setUp);
    $this->get($setUp)->assertOk();
})->with([Role::Curator, Role::Admin]);

it('lets a curator or admin set up TOTP and then use the panel', function () {
    $curator = panelAccount(Role::Curator);
    $this->actingAs($curator);

    $this->totp->saveSecret($curator, $this->secret);
    $this->totp->saveRecoveryCodes($curator, $this->totp->generateRecoveryCodes());

    $this->get('/admin')->assertOk();
});

it('asks for the TOTP code after the password and signs in only with a valid code (SEC-005)', function () {
    $curator = panelAccount(Role::Curator, $this->secret);

    $login = Livewire::test(Login::class)
        ->fillForm(['email' => $curator->email, 'password' => PANEL_PASSWORD])
        ->call('authenticate')
        ->assertHasNoFormErrors();

    // The password alone does not sign in.
    $this->assertGuest();

    $login->set('data.multiFactor.app.code', '000000')
        ->call('authenticate')
        ->assertHasErrors(['data.multiFactor.app.code']);
    $this->assertGuest();

    $login->set('data.multiFactor.app.code', totpCode($this->totp, $this->secret))
        ->call('authenticate')
        ->assertHasNoErrors();

    $this->assertAuthenticatedAs($curator);
    $this->get('/admin')->assertOk();
});

it('accepts each recovery code only once (SEC-005)', function () {
    $admin = panelAccount(Role::Admin, $this->secret, ['code-one-1111', 'code-two-2222']);

    $signInWithRecoveryCode = function (string $code) use ($admin) {
        auth()->logout();
        // Each sign-in counts against the panel's 5-per-minute sign-in limit.
        cache()->flush();

        return Livewire::test(Login::class)
            ->fillForm(['email' => $admin->email, 'password' => PANEL_PASSWORD])
            ->call('authenticate')
            ->set('data.multiFactor.app.useRecoveryCode', true)
            ->set('data.multiFactor.app.recoveryCode', $code)
            ->call('authenticate');
    };

    $signInWithRecoveryCode('code-one-1111')->assertHasNoErrors();
    $this->assertAuthenticatedAs($admin);
    expect($admin->fresh()->getAppAuthenticationRecoveryCodes())->toHaveCount(1);

    $signInWithRecoveryCode('code-one-1111')->assertHasErrors(['data.multiFactor.app.recoveryCode']);
    $this->assertGuest();

    $signInWithRecoveryCode('code-two-2222')->assertHasNoErrors();
    $this->assertAuthenticatedAs($admin);
    expect($admin->fresh()->getAppAuthenticationRecoveryCodes())->toBe([]);
});

it('stores the TOTP secret and recovery codes encrypted and never exposes them (SEC-005)', function () {
    Log::spy();
    $curator = panelAccount(Role::Curator, $this->secret, ['code-one-1111']);

    $raw = DB::table('users')->where('id', $curator->id)->first();

    expect($raw->app_authentication_secret)->not->toContain($this->secret)
        ->and($raw->app_authentication_recovery_codes)->not->toContain('code-one-1111')
        ->and(json_decode($raw->app_authentication_recovery_codes, true))->toBeString();

    $fresh = $curator->fresh();
    expect($fresh->getAppAuthenticationSecret())->toBe($this->secret)
        ->and(password_verify('code-one-1111', $fresh->getAppAuthenticationRecoveryCodes()[0]))->toBeTrue();

    // Hidden from serialisation and API responses.
    expect($fresh->toArray())->not->toHaveKeys(['app_authentication_secret', 'app_authentication_recovery_codes']);

    Sanctum::actingAs($fresh);
    $body = $this->getJson('/api/v1/me')->assertOk()->getContent();
    expect($body)->not->toContain('app_authentication')
        ->and($body)->not->toContain($this->secret);

    // Never written to logs.
    Log::shouldNotHaveReceived('log');
    foreach (['emergency', 'alert', 'critical', 'error', 'warning', 'notice', 'info', 'debug'] as $level) {
        Log::shouldNotHaveReceived($level);
    }
});

it('lets the admin reset the MFA of another account (SEC-005)', function () {
    $admin = panelAccount(Role::Admin, $this->secret);
    $curator = panelAccount(Role::Curator, $this->totp->generateSecret(), ['code-one-1111']);
    $this->actingAs($admin);

    $this->get('/admin/users')->assertOk();

    Livewire::test(ListUsers::class)
        ->assertCanSeeTableRecords([$admin, $curator])
        ->callAction(TestAction::make('resetMultiFactorAuthentication')->table($curator));

    $curator->refresh();
    expect($curator->getAppAuthenticationSecret())->toBeNull()
        ->and($curator->getAppAuthenticationRecoveryCodes())->toBeNull();

    // The curator must set up TOTP again before using the panel.
    $this->actingAs($curator)->get('/admin')->assertRedirect('/admin/multi-factor-authentication/set-up');
});

it('does not let the admin reset their own MFA from the accounts list', function () {
    $admin = panelAccount(Role::Admin, $this->secret);
    $this->actingAs($admin);

    Livewire::test(ListUsers::class)
        ->assertActionHidden(TestAction::make('resetMultiFactorAuthentication')->table($admin));

    expect($admin->fresh()->getAppAuthenticationSecret())->toBe($this->secret);
});

it('does not let a curator reset any account\'s MFA (SEC-005)', function () {
    $curator = panelAccount(Role::Curator, $this->secret);
    $other = panelAccount(Role::Curator, $otherSecret = $this->totp->generateSecret());
    $admin = panelAccount(Role::Admin, $adminSecret = $this->totp->generateSecret());
    $this->actingAs($curator);

    $this->get('/admin/users')->assertForbidden();
    Livewire::test(ListUsers::class)->assertForbidden();

    expect(Gate::forUser($curator)->allows('resetMultiFactorAuthentication', $other))->toBeFalse()
        ->and(Gate::forUser($curator)->allows('resetMultiFactorAuthentication', $admin))->toBeFalse()
        ->and($other->fresh()->getAppAuthenticationSecret())->toBe($otherSecret)
        ->and($admin->fresh()->getAppAuthenticationSecret())->toBe($adminSecret);
});

it('denies a gardener access to other accounts through the panel and changes nothing (OWN-007)', function () {
    $gardener = User::factory()->create();
    $curator = panelAccount(Role::Curator, $this->secret);
    $before = DB::table('users')->where('id', $curator->id)->first();

    $this->actingAs($gardener)->get('/admin/users')->assertForbidden();

    expect(Gate::forUser($gardener)->allows('viewAny', User::class))->toBeFalse()
        ->and(Gate::forUser($gardener)->allows('resetMultiFactorAuthentication', $curator))->toBeFalse()
        ->and(DB::table('users')->where('id', $curator->id)->first())->toEqual($before);
});

it('creates a curator or admin account from the console with a verified email', function () {
    $this->artisan('identity:create-panel-account', ['email' => 'Curator@Example.com', '--role' => 'curator'])
        ->expectsQuestion('Password (at least 8 characters)', 'a-long-password')
        ->assertSuccessful();

    $account = User::query()->where('email', 'curator@example.com')->firstOrFail();
    expect($account->role)->toBe(Role::Curator)
        ->and($account->hasVerifiedEmail())->toBeTrue()
        ->and($account->hasMultiFactorAuthentication())->toBeFalse()
        ->and(password_get_info($account->password_hash)['algoName'])->toBe('argon2id');

    $this->artisan('identity:create-panel-account', ['email' => 'curator@example.com'])->assertFailed();
    $this->artisan('identity:create-panel-account', ['email' => 'x@example.com', '--role' => 'gardener'])->assertFailed();
    expect(User::query()->count())->toBe(1);
});

it('rate-limits panel sign-in attempts (SEC-005)', function () {
    $curator = panelAccount(Role::Curator, $this->secret);

    foreach (range(1, 5) as $attempt) {
        Livewire::test(Login::class)
            ->fillForm(['email' => $curator->email, 'password' => 'wrong-password'])
            ->call('authenticate')
            ->assertHasFormErrors(['email']);
    }

    // The sixth attempt is refused before the password is checked, even if it is right.
    Livewire::test(Login::class)
        ->fillForm(['email' => $curator->email, 'password' => PANEL_PASSWORD])
        ->call('authenticate')
        ->assertNotified();

    $this->assertGuest();
});
