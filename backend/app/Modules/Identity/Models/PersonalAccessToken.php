<?php

namespace App\Modules\Identity\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Laravel\Sanctum\PersonalAccessToken as SanctumPersonalAccessToken;

/**
 * Sanctum API token with a UUID primary key (DATA-006). The token name is
 * the device id, so a user has at most one token per device (SEC-001).
 */
class PersonalAccessToken extends SanctumPersonalAccessToken
{
    use HasUuids;
}
