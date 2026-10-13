<?php

use App\Modules\Identity\Mail\VerifyEmailMail;
use App\Modules\Identity\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;

uses(RefreshDatabase::class);

beforeEach(fn () => Mail::fake());

function verificationUrlFromSignUp(string $email): string
{
    test()->postJson('/api/v1/auth/sign-up', [
        'email' => $email,
        'password' => 'tomatoes-2026',
        'age_confirmed' => true,
        'language' => 'en',
    ])->assertStatus(202);

    $url = null;
    Mail::assertQueued(VerifyEmailMail::class, function (VerifyEmailMail $mail) use (&$url) {
        $url = $mail->url;

        return true;
    });

    return (string) $url;
}

it('confirms the email through the signed link, after which sign-in works (UC-012)', function () {
    $url = verificationUrlFromSignUp('eleni@example.com');

    $this->getJson($url)->assertOk();
    expect(User::query()->sole()->hasVerifiedEmail())->toBeTrue();

    $this->postJson('/api/v1/auth/sign-in', [
        'email' => 'eleni@example.com',
        'password' => 'tomatoes-2026',
        'device_id' => 'device-a',
    ])->assertOk();
});

it('rejects a tampered or expired verification link', function () {
    $url = verificationUrlFromSignUp('eleni@example.com');

    $this->getJson($url.'x')->assertForbidden()->assertHeader('Content-Type', 'application/problem+json');

    $this->travel(61)->minutes();
    $this->getJson($url)->assertForbidden();

    expect(User::query()->sole()->hasVerifiedEmail())->toBeFalse();
});

it('renders the verification email in the language of the account', function () {
    $url = verificationUrlFromSignUp('eleni@example.com');

    $mail = new VerifyEmailMail($url, 60);
    $mail->locale('el');

    $mail->assertSeeInText($url);
    $mail->assertHasSubject('Επιβεβαιώστε το email σας για το Agrocult');
});

it('resends the verification email with the same answer for every address', function () {
    User::factory()->unverified()->create(['email' => 'pending@example.com']);
    User::factory()->create(['email' => 'verified@example.com']);

    $pending = $this->postJson('/api/v1/auth/email/verification-notification', ['email' => 'PENDING@example.com']);
    $verified = $this->postJson('/api/v1/auth/email/verification-notification', ['email' => 'verified@example.com']);
    $unknown = $this->postJson('/api/v1/auth/email/verification-notification', ['email' => 'unknown@example.com']);

    $pending->assertStatus(202);
    foreach ([$verified, $unknown] as $response) {
        expect($response->status())->toBe($pending->status())
            ->and($response->json())->toBe($pending->json());
    }

    Mail::assertQueuedCount(1);
    Mail::assertQueued(VerifyEmailMail::class, fn (VerifyEmailMail $mail) => $mail->hasTo('pending@example.com'));
});
