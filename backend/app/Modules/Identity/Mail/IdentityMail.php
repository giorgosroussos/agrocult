<?php

namespace App\Modules\Identity\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

/**
 * Base of the account emails (INT-004). They are always queued, so an
 * unavailable mail server never fails the API request: the job is retried
 * with exponential backoff and the user can request a new email.
 */
abstract class IdentityMail extends Mailable implements ShouldQueue
{
    use Queueable;
    use SerializesModels;

    public int $tries;

    /** @var list<int> */
    public array $backoff;

    public function __construct()
    {
        $this->tries = (int) config('identity.mail.tries', 5);
        /** @var list<int> $backoff */
        $backoff = config('identity.mail.backoff', [15, 60, 240, 960]);
        $this->backoff = $backoff;
    }
}
