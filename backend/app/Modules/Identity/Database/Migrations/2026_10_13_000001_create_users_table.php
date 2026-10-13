<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Query\Expression;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ENT-User. Emails are stored lower-case, so the unique index is case-insensitive.
        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('email', 254)->unique();
            $table->string('password_hash', 255);
            $table->timestampTz('email_verified_at')->nullable();
            $table->string('role');
            $table->string('language');
            $table->jsonb('notification_prefs')->nullable();
            $table->timestampTz('created_at')->nullable();
        });

        // Password reset tokens (hashed), one per email; deleted when used.
        Schema::create('password_reset_tokens', function (Blueprint $table) {
            // The framework's token repository does not set an id, so PostgreSQL generates it.
            $table->uuid('id')->primary()->default(new Expression('gen_random_uuid()'));
            $table->string('email', 254)->unique();
            $table->string('token');
            $table->timestampTz('created_at')->nullable();
        });

        // Sanctum API tokens, one per device of a user.
        Schema::create('personal_access_tokens', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuidMorphs('tokenable');
            $table->text('name');
            $table->string('token', 64)->unique();
            $table->text('abilities')->nullable();
            $table->timestampTz('last_used_at')->nullable();
            $table->timestampTz('expires_at')->nullable()->index();
            $table->timestampsTz();
        });

        // ENT-PushToken.
        Schema::create('push_tokens', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('token', 255)->unique();
            $table->string('platform')->nullable();
            $table->timestampTz('last_seen_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('push_tokens');
        Schema::dropIfExists('personal_access_tokens');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('users');
    }
};
