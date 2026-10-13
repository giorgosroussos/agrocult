<?php

return [

    // SEC-001: sign-in attempts per minute per email and IP.
    'sign_in_attempts_per_minute' => (int) env('IDENTITY_SIGN_IN_ATTEMPTS_PER_MINUTE', 5),

    // Requests per minute per IP to the endpoints that send email
    // (sign-up, verification resend, password reset request).
    'email_requests_per_minute' => (int) env('IDENTITY_EMAIL_REQUESTS_PER_MINUTE', 6),

    // Lifetime of the signed email verification link, in minutes.
    'verification_link_minutes' => (int) env('IDENTITY_VERIFICATION_LINK_MINUTES', 60),

    // Where the password reset link in the email points to; the app (or a
    // page that hands over to the app) receives ?token=...&email=...
    'password_reset_url' => env('IDENTITY_PASSWORD_RESET_URL', 'agrocult://reset-password'),

    // INT-004: queued emails are retried 5 times with exponential backoff (seconds).
    'mail' => [
        'tries' => (int) env('IDENTITY_MAIL_TRIES', 5),
        'backoff' => [15, 60, 240, 960],
    ],

];
