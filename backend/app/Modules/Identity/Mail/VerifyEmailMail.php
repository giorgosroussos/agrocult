<?php

namespace App\Modules\Identity\Mail;

use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;

/**
 * INT-004 sendVerification: link that confirms the email address.
 */
class VerifyEmailMail extends IdentityMail
{
    public function __construct(
        public readonly string $url,
        public readonly int $minutes,
    ) {
        parent::__construct();
    }

    public function envelope(): Envelope
    {
        return new Envelope(subject: __('identity::mail.verify.subject'));
    }

    public function content(): Content
    {
        return new Content(text: 'identity::mail.verify-email');
    }
}
