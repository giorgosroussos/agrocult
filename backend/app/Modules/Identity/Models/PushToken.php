<?php

namespace App\Modules\Identity\Models;

use App\Modules\Identity\Database\Factories\PushTokenFactory;
use App\Modules\Identity\Enums\Platform;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ENT-PushToken: FCM token of one device of a user.
 *
 * @property string $id
 * @property string $user_id
 * @property string $token
 * @property Platform|null $platform
 * @property CarbonImmutable|null $last_seen_at
 */
class PushToken extends Model
{
    /** @use HasFactory<PushTokenFactory> */
    use HasFactory;

    use HasUuids;

    public $timestamps = false;

    protected $table = 'push_tokens';

    /** @var list<string> */
    protected $fillable = [
        'token',
        'platform',
        'last_seen_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'platform' => Platform::class,
            'last_seen_at' => 'immutable_datetime',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    protected static function newFactory(): PushTokenFactory
    {
        return PushTokenFactory::new();
    }
}
