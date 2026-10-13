<?php

use App\Modules\Identity\Mail\ResetPasswordMail;
use App\Modules\Identity\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

uses(RefreshDatabase::class);

beforeEach(function () {
    Mail::fake();
    $this->user = User::factory()->create(['email' => 'kostas@example.com']);
});

/**
 * @return array{token: string, email: string}
 */
function requestResetLink(string $email): array
{
    test()->postJson('/api/v1/auth/password/forgot', ['email' => $email])->assertStatus(202);

    $url = null;
    Mail::assertQueued(ResetPasswordMail::class, function (ResetPasswordMail $mail) use (&$url) {
        $url = $mail->url;

        return true;
    });

    parse_str((string) parse_url((string) $url, PHP_URL_QUERY), $query);

    return ['token' => (string) $query['token'], 'email' => (string) $query['email']];
}

it('answers an unknown email exactly like a known one (UC-013)', function () {
    $known = $this->postJson('/api/v1/auth/password/forgot', ['email' => 'kostas@example.com']);
    $unknown = $this->postJson('/api/v1/auth/password/forgot', ['email' => 'nobody@example.com']);
    // A second request within the throttle window looks the same as well.
    $throttled = $this->postJson('/api/v1/auth/password/forgot', ['email' => 'kostas@example.com']);

    $known->assertStatus(202);
    foreach ([$unknown, $throttled] as $response) {
        expect($response->status())->toBe($known->status())
            ->and($response->json())->toBe($known->json());
    }

    Mail::assertQueuedCount(1);
    Mail::assertQueued(ResetPasswordMail::class, fn (ResetPasswordMail $mail) => $mail->hasTo('kostas@example.com'));
});

it('sets a new password with the link and revokes every API token (SEC-001)', function () {
    $this->user->createToken('device-a');
    $this->user->createToken('device-b');

    $link = requestResetLink('kostas@example.com');
    expect($link['email'])->toBe('kostas@example.com');

    $this->postJson('/api/v1/auth/password/reset', $link + ['password' => 'new-password-1'])->assertOk();

    $user = $this->user->fresh();
    expect(Hash::check('new-password-1', $user->password_hash))->toBeTrue()
        ->and(password_get_info($user->password_hash)['algoName'])->toBe('argon2id')
        ->and($user->tokens()->count())->toBe(0);
});

it('rejects a reset link that was already used once (UC-013)', function () {
    $link = requestResetLink('kostas@example.com');

    $this->postJson('/api/v1/auth/password/reset', $link + ['password' => 'new-password-1'])->assertOk();

    $this->postJson('/api/v1/auth/password/reset', $link + ['password' => 'new-password-2'])
        ->assertStatus(422)
        ->assertHeader('Content-Type', 'application/problem+json')
        ->assertJsonValidationErrors('token');

    expect(Hash::check('new-password-1', $this->user->fresh()->password_hash))->toBeTrue();
});

it('rejects a wrong token and a token for another email', function () {
    $link = requestResetLink('kostas@example.com');
    User::factory()->create(['email' => 'other@example.com']);

    $this->postJson('/api/v1/auth/password/reset', ['token' => 'wrong', 'email' => $link['email'], 'password' => 'new-password-1'])
        ->assertStatus(422);
    $this->postJson('/api/v1/auth/password/reset', ['token' => $link['token'], 'email' => 'other@example.com', 'password' => 'new-password-1'])
        ->assertStatus(422);

    expect(Hash::check('password-1234', $this->user->fresh()->password_hash))->toBeTrue();
});
