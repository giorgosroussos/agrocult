<?php

namespace App\Modules\Identity\Mail;

use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;

/**
 * INT-004 sendPasswordReset: one-time link to set a new password.
 */
class ResetPasswordMail extends IdentityMail
{
    public function __construct(
        public readonly string $url,
        public readonly int $minutes,
    ) {
        parent::__construct();
    }

    public function envelope(): Envelope
    {
        return new Envelope(subject: __('identity::mail.reset.subject'));
    }

    public function content(): Content
    {
        return new Content(text: 'identity::mail.reset-password');
    }
}
