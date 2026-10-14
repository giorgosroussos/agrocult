<?php

namespace App\Modules\Catalogue\Models;

use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * One entry of the audit trail on catalogue plant changes (ENT-Plant audit: true).
 * Append-only: written by PlantAuditObserver, never updated.
 *
 * changes holds {attribute: {old, new}} for updates and {attribute: {old: null, new}} on
 * creation; on deletion it holds the last values as old.
 *
 * @property string $id
 * @property string $plant_id
 * @property string|null $user_id
 * @property string $event
 * @property array<string, array{old: mixed, new: mixed}> $changes
 * @property CarbonImmutable $created_at
 */
class PlantAudit extends Model
{
    use HasUuids;

    public const UPDATED_AT = null;

    public const EVENT_CREATED = 'created';

    public const EVENT_UPDATED = 'updated';

    public const EVENT_DELETED = 'deleted';

    protected $table = 'plant_audits';

    /** @var list<string> */
    protected $fillable = [
        'plant_id',
        'user_id',
        'event',
        'changes',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'changes' => 'array',
            'created_at' => 'immutable_datetime',
        ];
    }

    protected static function booted(): void
    {
        static::updating(fn (): bool => false);
    }

    /**
     * @return BelongsTo<Plant, $this>
     */
    public function plant(): BelongsTo
    {
        return $this->belongsTo(Plant::class);
    }
}
