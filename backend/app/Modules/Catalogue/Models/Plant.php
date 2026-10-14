<?php

namespace App\Modules\Catalogue\Models;

use App\Modules\Catalogue\Database\Factories\PlantFactory;
use App\Modules\Catalogue\Enums\FrostHardiness;
use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Enums\Sun;
use App\Modules\Catalogue\Exceptions\InvalidPlantTransition;
use App\Modules\Catalogue\Exceptions\PlantNotPublishable;
use App\Modules\Catalogue\Observers\PlantAuditObserver;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * ENT-Plant: catalogue plant with structured fields used by filters and notification rules.
 *
 * The status follows the state model in PlantStatus. Every save is guarded: a new plant
 * starts as draft, only listed transitions are accepted and a plant without its required
 * structured fields cannot be published. Change the status through PlantWorkflow.
 *
 * @property string $id
 * @property string $scientific_name
 * @property int|null $gbif_id
 * @property string $category_id
 * @property string|null $temp_min_c
 * @property string|null $temp_opt_c
 * @property string|null $temp_max_c
 * @property int|null $water_need
 * @property Sun|null $sun
 * @property list<string>|null $soil_types
 * @property string|null $ph_min
 * @property string|null $ph_max
 * @property FrostHardiness|null $frost_hardiness
 * @property list<string>|null $propagation
 * @property string|null $sow_depth_cm
 * @property int|null $spacing_cm
 * @property int|null $row_spacing_cm
 * @property int|null $days_to_harvest
 * @property PlantStatus $status
 * @property string|null $reviewed_by
 * @property CarbonImmutable|null $reviewed_at
 * @property CarbonImmutable|null $published_at
 * @property CarbonImmutable|null $updated_at
 */
#[ObservedBy(PlantAuditObserver::class)]
class Plant extends Model
{
    /** @use HasFactory<PlantFactory> */
    use HasFactory;

    use HasUuids;

    /** ENT-Plant has updated_at but no created_at (the audit trail records creation). */
    public const CREATED_AT = null;

    /** Structured fields that must be present before a plant can be published (UC-010). */
    public const REQUIRED_FOR_PUBLISHING = ['scientific_name', 'category_id'];

    protected $table = 'plants';

    /** @var array<string, mixed> */
    protected $attributes = [
        'status' => 'draft',
    ];

    /** @var list<string> */
    protected $fillable = [
        'scientific_name',
        'gbif_id',
        'category_id',
        'temp_min_c',
        'temp_opt_c',
        'temp_max_c',
        'water_need',
        'sun',
        'soil_types',
        'ph_min',
        'ph_max',
        'frost_hardiness',
        'propagation',
        'sow_depth_cm',
        'spacing_cm',
        'row_spacing_cm',
        'days_to_harvest',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'gbif_id' => 'integer',
            'temp_min_c' => 'decimal:1',
            'temp_opt_c' => 'decimal:1',
            'temp_max_c' => 'decimal:1',
            'water_need' => 'integer',
            'sun' => Sun::class,
            'soil_types' => 'array',
            'ph_min' => 'decimal:1',
            'ph_max' => 'decimal:1',
            'frost_hardiness' => FrostHardiness::class,
            'propagation' => 'array',
            'sow_depth_cm' => 'decimal:1',
            'spacing_cm' => 'integer',
            'row_spacing_cm' => 'integer',
            'days_to_harvest' => 'integer',
            'status' => PlantStatus::class,
            'reviewed_at' => 'immutable_datetime',
            'published_at' => 'immutable_datetime',
            'updated_at' => 'immutable_datetime',
        ];
    }

    protected static function booted(): void
    {
        static::saving(function (Plant $plant): void {
            $plant->guardStatus();
        });
    }

    /**
     * Rejects a status that the state model does not allow and leaves the status unchanged.
     *
     * @throws InvalidPlantTransition
     * @throws PlantNotPublishable
     */
    public function guardStatus(): void
    {
        $to = $this->status;

        if (! $this->exists) {
            if ($to !== PlantStatus::INITIAL) {
                $this->setAttribute('status', PlantStatus::INITIAL);

                throw new InvalidPlantTransition(null, $to);
            }

            return;
        }

        if (! $this->isDirty('status')) {
            return;
        }

        $original = $this->getRawOriginal('status');
        $from = PlantStatus::from(is_string($original) ? $original : PlantStatus::INITIAL->value);

        if (! $from->canTransitionTo($to)) {
            $this->setAttribute('status', $from);

            throw new InvalidPlantTransition($from, $to);
        }

        if ($to === PlantStatus::Published && ($missing = $this->missingFieldsForPublishing()) !== []) {
            $this->setAttribute('status', $from);

            throw new PlantNotPublishable($missing);
        }
    }

    /**
     * @return list<string>
     */
    public function missingFieldsForPublishing(): array
    {
        return array_values(array_filter(
            self::REQUIRED_FOR_PUBLISHING,
            fn (string $field): bool => trim((string) $this->getAttribute($field)) === '',
        ));
    }

    /**
     * Only published plants go to the catalogue snapshot and to devices (ARCH-003).
     *
     * @param  Builder<Plant>  $query
     */
    public function scopePublished(Builder $query): void
    {
        $query->where('status', PlantStatus::Published->value);
    }

    /**
     * @return BelongsTo<PlantCategory, $this>
     */
    public function category(): BelongsTo
    {
        return $this->belongsTo(PlantCategory::class, 'category_id');
    }

    /**
     * @return HasMany<PlantTranslation, $this>
     */
    public function translations(): HasMany
    {
        return $this->hasMany(PlantTranslation::class);
    }

    /**
     * @return HasMany<PlantAlias, $this>
     */
    public function aliases(): HasMany
    {
        return $this->hasMany(PlantAlias::class);
    }

    /**
     * @return HasMany<PlantCalendar, $this>
     */
    public function calendars(): HasMany
    {
        return $this->hasMany(PlantCalendar::class);
    }

    /**
     * @return HasMany<Companion, $this>
     */
    public function companions(): HasMany
    {
        return $this->hasMany(Companion::class);
    }

    /**
     * @return HasMany<CareInterval, $this>
     */
    public function careIntervals(): HasMany
    {
        return $this->hasMany(CareInterval::class);
    }

    /**
     * @return HasMany<PlantPhoto, $this>
     */
    public function photos(): HasMany
    {
        return $this->hasMany(PlantPhoto::class);
    }

    /**
     * @return HasMany<FactSource, $this>
     */
    public function factSources(): HasMany
    {
        return $this->hasMany(FactSource::class);
    }

    /**
     * @return HasMany<PlantAudit, $this>
     */
    public function audits(): HasMany
    {
        return $this->hasMany(PlantAudit::class);
    }

    protected static function newFactory(): PlantFactory
    {
        return PlantFactory::new();
    }
}
