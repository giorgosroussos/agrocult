<?php

use App\Modules\Identity\Mail\VerifyEmailMail;
use App\Modules\Identity\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Illuminate\Testing\TestResponse;

uses(RefreshDatabase::class);

beforeEach(fn () => Mail::fake());

function signUp(array $overrides = []): TestResponse
{
    return test()->postJson('/api/v1/auth/sign-up', array_merge([
        'email' => 'maria@example.com',
        'password' => 'tomatoes-2026',
        'age_confirmed' => true,
        'language' => 'el',
    ], $overrides));
}

it('creates an unverified gardener account and queues the verification email', function () {
    signUp()->assertStatus(202);

    $user = User::query()->sole();
    expect($user->email)->toBe('maria@example.com')
        ->and($user->role->value)->toBe('gardener')
        ->and($user->language->value)->toBe('el')
        ->and($user->hasVerifiedEmail())->toBeFalse()
        ->and($user->notificationPreferences())->toBe(['summary' => true, 'frost' => true, 'heatwave' => true]);

    Mail::assertQueued(VerifyEmailMail::class, fn (VerifyEmailMail $mail) => $mail->hasTo('maria@example.com'));
});

it('hashes the password with argon2id', function () {
    signUp()->assertStatus(202);

    $hash = User::query()->sole()->password_hash;
    expect(password_get_info($hash)['algoName'])->toBe('argon2id')
        ->and($hash)->not->toContain('tomatoes-2026');
});

it('does not create a second account for an email that is already registered (UC-012)', function () {
    $first = signUp()->assertStatus(202);
    Mail::fake();

    $second = signUp(['email' => '  Maria@EXAMPLE.com ', 'password' => 'another-password']);

    expect(User::query()->count())->toBe(1);
    // The answer does not reveal that the email is registered.
    expect($second->status())->toBe($first->status())
        ->and($second->json())->toBe($first->json());
    Mail::assertNothingQueued();
});

it('rejects a sign-up without the age confirmation (SEC-004)', function (mixed $confirmed) {
    signUp(['age_confirmed' => $confirmed])
        ->assertStatus(422)
        ->assertHeader('Content-Type', 'application/problem+json')
        ->assertJsonValidationErrors('age_confirmed');

    expect(User::query()->count())->toBe(0);
})->with([false, null, 'no']);

it('rejects an invalid email, a short password and an unknown language', function () {
    signUp(['email' => 'not-an-email'])->assertJsonValidationErrors('email');
    signUp(['password' => 'short'])->assertJsonValidationErrors('password');
    signUp(['language' => 'de'])->assertJsonValidationErrors('language');

    expect(User::query()->count())->toBe(0);
});
