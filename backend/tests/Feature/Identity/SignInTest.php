<?php

use App\Modules\Identity\Models\PersonalAccessToken;
use App\Modules\Identity\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Illuminate\Testing\TestResponse;

uses(RefreshDatabase::class);

function signIn(array $overrides = []): TestResponse
{
    return test()->postJson('/api/v1/auth/sign-in', array_merge([
        'email' => 'nikos@example.com',
        'password' => 'password-1234',
        'device_id' => 'device-a',
    ], $overrides));
}

beforeEach(function () {
    $this->user = User::factory()->create(['email' => 'nikos@example.com']);
});

it('signs in a verified user and issues a bearer token for the device', function () {
    $response = signIn(['email' => 'Nikos@Example.COM'])->assertOk()
        ->assertJsonPath('token_type', 'Bearer')
        ->assertJsonPath('user.id', $this->user->id)
        ->assertJsonPath('user.email', 'nikos@example.com')
        ->assertJsonMissingPath('user.password_hash');

    $this->withToken($response->json('token'))
        ->getJson('/api/v1/me')
        ->assertOk()
        ->assertJsonPath('data.id', $this->user->id);
});

it('answers a wrong password exactly like an unknown email (UC-012)', function () {
    $wrongPassword = signIn(['password' => 'wrong-password']);
    $unknownEmail = signIn(['email' => 'nobody@example.com', 'device_id' => 'device-b']);

    $wrongPassword->assertStatus(422)->assertHeader('Content-Type', 'application/problem+json');
    expect($unknownEmail->status())->toBe($wrongPassword->status())
        ->and($unknownEmail->json())->toBe($wrongPassword->json())
        ->and($wrongPassword->json('errors.email.0'))->toBe('These credentials do not match our records.');

    expect(PersonalAccessToken::query()->count())->toBe(0);
});

it('does not sign in before the email is confirmed', function () {
    $this->user->forceFill(['email_verified_at' => null])->save();

    signIn()->assertStatus(403)
        ->assertJsonPath('code', 'email_not_verified')
        ->assertJsonMissingPath('token');

    expect(PersonalAccessToken::query()->count())->toBe(0);
});

it('keeps one token per device (SEC-001)', function () {
    signIn()->assertOk();
    signIn()->assertOk();
    expect($this->user->tokens()->count())->toBe(1);

    signIn(['device_id' => 'device-b'])->assertOk();
    expect($this->user->tokens()->pluck('name')->sort()->values()->all())->toBe(['device-a', 'device-b']);
});

it('stores API tokens with UUID primary keys', function () {
    signIn()->assertOk();

    expect(Str::isUuid(PersonalAccessToken::query()->sole()->id))->toBeTrue();
});

it('rate-limits sign-in to 5 attempts per minute per email and IP (SEC-001)', function () {
    foreach (range(1, 5) as $attempt) {
        signIn(['password' => 'wrong-password'])->assertStatus(422);
    }

    // Even the right password is refused now.
    signIn()->assertStatus(429)->assertHeader('Content-Type', 'application/problem+json');
    // Another email from the same IP is still allowed.
    signIn(['email' => 'nobody@example.com'])->assertStatus(422);
});

it('revokes the device token on sign-out', function () {
    $token = signIn()->json('token');
    signIn(['device_id' => 'device-b'])->assertOk();

    $this->withToken($token)->postJson('/api/v1/auth/sign-out')->assertNoContent();

    expect($this->user->tokens()->pluck('name')->all())->toBe(['device-b']);

    app('auth')->forgetGuards();
    $this->withToken($token)->getJson('/api/v1/me')->assertUnauthorized();
});

it('requires authentication for sign-out', function () {
    $this->postJson('/api/v1/auth/sign-out')
        ->assertUnauthorized()
        ->assertHeader('Content-Type', 'application/problem+json');
});
