<?php

use App\Modules\Identity\Mail\ResetPasswordMail;
use App\Modules\Identity\Mail\VerifyEmailMail;
use App\Modules\Identity\Models\User;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Symfony\Component\Mailer\Envelope;
use Symfony\Component\Mailer\Exception\TransportException;
use Symfony\Component\Mailer\SentMessage;
use Symfony\Component\Mailer\Transport\TransportInterface;
use Symfony\Component\Mime\RawMessage;

uses(RefreshDatabase::class);

/**
 * A mail server that is unavailable: every send fails like an SMTP timeout.
 */
function useUnavailableMailServer(): void
{
    Mail::extend('unavailable', fn () => new class implements TransportInterface
    {
        public function send(RawMessage $message, ?Envelope $envelope = null): ?SentMessage
        {
            throw new TransportException('Connection timed out');
        }

        public function __toString(): string
        {
            return 'unavailable://';
        }
    });

    config([
        'mail.mailers.unavailable' => ['transport' => 'unavailable'],
        'mail.default' => 'unavailable',
        'queue.default' => 'database',
    ]);
}

it('queues account emails with 5 tries and exponential backoff (INT-004)', function () {
    foreach ([new VerifyEmailMail('https://x', 60), new ResetPasswordMail('https://x', 60)] as $mail) {
        expect($mail)->toBeInstanceOf(ShouldQueue::class)
            ->and($mail->tries)->toBe(5)
            ->and($mail->backoff)->toBe([15, 60, 240, 960]);
    }

    expect(config('mail.mailers.smtp.timeout'))->toBe(15);
});

it('keeps the email queued and retries it when the mail server is unavailable (INT-004)', function () {
    useUnavailableMailServer();

    // The API request succeeds although the mail server is down.
    $this->postJson('/api/v1/auth/sign-up', [
        'email' => 'sofia@example.com',
        'password' => 'tomatoes-2026',
        'age_confirmed' => true,
        'language' => 'el',
    ])->assertStatus(202);
    expect(User::query()->count())->toBe(1)
        ->and(DB::table('jobs')->count())->toBe(1);

    Artisan::call('queue:work', ['connection' => 'database', '--once' => true, '--stop-when-empty' => true]);

    // Released back to the queue for a later retry, not failed.
    $job = DB::table('jobs')->sole();
    expect($job->attempts)->toBe(1)
        ->and($job->available_at)->toBeGreaterThan(now()->getTimestamp())
        ->and(DB::table('failed_jobs')->count())->toBe(0);

    // The user can ask for a new verification email meanwhile.
    $this->postJson('/api/v1/auth/email/verification-notification', ['email' => 'sofia@example.com'])
        ->assertStatus(202);
    expect(DB::table('jobs')->count())->toBe(2);

    // And a password reset email is queued the same way.
    $this->postJson('/api/v1/auth/password/forgot', ['email' => 'sofia@example.com'])->assertStatus(202);
    expect(DB::table('jobs')->count())->toBe(3);
});

it('does not write the email address to the logs when sending fails', function () {
    useUnavailableMailServer();
    $log = storage_path('logs/identity-test.log');
    @unlink($log);
    config([
        'logging.default' => 'identity-test',
        'logging.channels.identity-test' => ['driver' => 'single', 'path' => $log],
    ]);

    $this->postJson('/api/v1/auth/sign-up', [
        'email' => 'sofia@example.com',
        'password' => 'tomatoes-2026',
        'age_confirmed' => true,
        'language' => 'el',
    ])->assertStatus(202);
    Artisan::call('queue:work', ['connection' => 'database', '--once' => true, '--stop-when-empty' => true]);

    $contents = is_file($log) ? (string) file_get_contents($log) : '';
    @unlink($log);
    expect($contents)->not->toContain('sofia@example.com')
        ->and($contents)->not->toContain('tomatoes-2026');
});
