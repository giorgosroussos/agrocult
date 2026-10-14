<?php

namespace App\Modules\Identity\Console;

use App\Modules\Identity\Enums\Language;
use App\Modules\Identity\Enums\Role;
use App\Modules\Identity\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

/**
 * Creates a curator or admin account for the admin panel. The password is
 * asked interactively and never passed on the command line. TOTP is set up
 * by the account itself at its first panel sign-in (SEC-005).
 */
class CreatePanelAccount extends Command
{
    protected $signature = 'identity:create-panel-account
        {email : Email address of the account}
        {--role=curator : curator or admin}
        {--language=el : el or en}';

    protected $description = 'Create a curator or admin account for the admin panel';

    public function handle(): int
    {
        $data = [
            'email' => User::normalizeEmail((string) $this->argument('email')),
            'role' => (string) $this->option('role'),
            'language' => (string) $this->option('language'),
        ];

        $validator = Validator::make($data, [
            'email' => ['required', 'email', 'max:254'],
            'role' => ['required', 'in:'.Role::Curator->value.','.Role::Admin->value],
            'language' => ['required', 'in:'.Language::Greek->value.','.Language::English->value],
        ]);

        if ($validator->fails()) {
            foreach ($validator->errors()->all() as $error) {
                $this->error($error);
            }

            return self::FAILURE;
        }

        if (User::query()->where('email', $data['email'])->exists()) {
            $this->error('An account with this email already exists.');

            return self::FAILURE;
        }

        $password = (string) $this->secret('Password (at least 8 characters)');

        if (mb_strlen($password) < 8 || mb_strlen($password) > 255) {
            $this->error('The password must be between 8 and 255 characters.');

            return self::FAILURE;
        }

        $user = new User([
            'email' => $data['email'],
            'password_hash' => Hash::make($password),
            'role' => Role::from($data['role']),
            'language' => Language::from($data['language']),
        ]);
        $user->email_verified_at = now()->toImmutable();
        $user->save();

        $this->info("Created {$data['role']} account {$user->id}. TOTP is set up at the first panel sign-in.");

        return self::SUCCESS;
    }
}
