<?php

namespace App\Modules\Catalogue\Import;

use App\Modules\Catalogue\Enums\AliasKind;
use App\Modules\Catalogue\Enums\CompanionRelation;
use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Enums\TextLanguage;
use App\Modules\Catalogue\Exceptions\PlantImportRejected;
use App\Modules\Catalogue\Models\Companion;
use App\Modules\Catalogue\Models\FactSource;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantAlias;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Models\PlantTranslation;
use BackedEnum;
use Illuminate\Support\Facades\DB;

/**
 * Writes imported facts to a draft plant (INT-006): results land as draft plants with a
 * FactSource row (source and licence) for every fact written or confirmed (SCOPE-001).
 *
 * Imports never publish and never touch a plant outside the draft state. Values the plant
 * already has are kept; a differing value is reported, not written, so the curator can
 * cross-check. Everything is written in one transaction.
 */
class DraftPlantWriter
{
    /** Structured ENT-Plant attributes that imports may fill. */
    public const ATTRIBUTES = ['gbif_id', 'sun', 'row_spacing_cm', 'ph_min', 'ph_max', 'temp_min_c', 'temp_max_c', 'days_to_harvest'];

    /**
     * Checks that facts about the plant may be written: an existing plant must be a draft, a new
     * plant needs an existing category (categories are curator data, DATA-004).
     *
     * @throws PlantImportRejected
     */
    public function assertWritable(string $scientificName, ?string $categoryCode): void
    {
        $plant = $this->find($scientificName);

        if ($plant !== null) {
            if ($plant->status !== PlantStatus::Draft) {
                throw new PlantImportRejected("{$plant->scientific_name} is {$plant->status->value}; imports only write to draft plants. Return it to draft in the admin panel first.");
            }

            return;
        }

        $this->category($categoryCode);
    }

    /**
     * @param  list<DraftFacts>  $drafts
     *
     * @throws PlantImportRejected
     */
    public function write(string $scientificName, array $drafts, ?string $categoryCode): ImportResult
    {
        return DB::transaction(function () use ($scientificName, $drafts, $categoryCode): ImportResult {
            $this->assertWritable($scientificName, $categoryCode);

            $plant = $this->find($scientificName, lock: true);
            $created = $plant === null;

            if ($plant === null) {
                $plant = Plant::create([
                    'scientific_name' => $scientificName,
                    'category_id' => $this->category($categoryCode)->id,
                ]);
            }

            $applied = $confirmed = $skipped = [];

            foreach ($drafts as $draft) {
                foreach ($draft->facts as $fact) {
                    $label = "{$fact->field} = {$fact->value} ({$draft->source->displayName()})";
                    $outcome = $this->apply($plant, $fact);

                    if ($outcome === 'applied' || $outcome === 'confirmed') {
                        $this->recordSource($plant, $fact, $draft);
                        $outcome === 'applied' ? $applied[] = $label : $confirmed[] = $label;
                    } else {
                        $skipped[] = "{$label}: {$outcome}";
                    }
                }
            }

            return new ImportResult($plant->refresh(), $created, $applied, $confirmed, $skipped);
        });
    }

    /**
     * @return 'applied'|'confirmed'|string the reason when the fact is not written
     */
    private function apply(Plant $plant, Fact $fact): string
    {
        if (in_array($fact->field, self::ATTRIBUTES, true)) {
            return $this->applyAttribute($plant, $fact);
        }

        if ($fact->field === 'companion') {
            return $this->applyCompanion($plant, (string) $fact->value);
        }

        [$kind, $lang] = array_pad(explode('.', $fact->field, 2), 2, '');
        $language = TextLanguage::tryFrom($lang);

        return match (true) {
            $language === null => 'unsupported language',
            $kind === 'name' => $this->applyName($plant, $language, (string) $fact->value),
            $kind === 'alias' => $this->applyAlias($plant, $language, (string) $fact->value),
            default => 'unsupported field',
        };
    }

    private function applyAttribute(Plant $plant, Fact $fact): string
    {
        $current = $plant->getAttribute($fact->field);
        $current = $current instanceof BackedEnum ? $current->value : $current;

        if ($current !== null && $current !== '') {
            return $this->same($current, $fact->value) ? 'confirmed' : "the plant keeps {$current}";
        }

        if ($fact->field === 'gbif_id' && Plant::query()->where('gbif_id', $fact->value)->whereKeyNot($plant->id)->exists()) {
            return 'another plant already has this GBIF id';
        }

        $plant->setAttribute($fact->field, $fact->value);
        $plant->save();

        return 'applied';
    }

    private function applyName(Plant $plant, TextLanguage $lang, string $name): string
    {
        $translation = $plant->translations()->where('lang', $lang->value)->first();

        if ($translation === null) {
            PlantTranslation::create(['plant_id' => $plant->id, 'lang' => $lang, 'name' => $name]);

            return 'applied';
        }

        if ($this->same($translation->name, $name)) {
            return 'confirmed';
        }

        // Another name for the plant in the same language is kept as an alias for search.
        return $this->applyAlias($plant, $lang, $name);
    }

    private function applyAlias(Plant $plant, TextLanguage $lang, string $alias): string
    {
        $known = $plant->translations()->where('lang', $lang->value)->pluck('name')
            ->merge($plant->aliases()->pluck('alias'))
            ->contains(fn (string $existing): bool => $this->same($existing, $alias));

        if ($known) {
            return 'confirmed';
        }

        PlantAlias::create(['plant_id' => $plant->id, 'lang' => $lang, 'alias' => $alias, 'kind' => AliasKind::LocalName]);

        return 'applied';
    }

    private function applyCompanion(Plant $plant, string $scientificName): string
    {
        $other = $this->find($scientificName);

        if ($other === null || $other->is($plant)) {
            return 'not in the catalogue yet';
        }

        $existing = Companion::query()->where('plant_id', $plant->id)->where('other_plant_id', $other->id)->first();

        if ($existing !== null) {
            return $existing->relation === CompanionRelation::Good ? 'confirmed' : 'the plant keeps it as a bad neighbour';
        }

        Companion::create(['plant_id' => $plant->id, 'other_plant_id' => $other->id, 'relation' => CompanionRelation::Good]);

        return 'applied';
    }

    private function recordSource(Plant $plant, Fact $fact, DraftFacts $draft): void
    {
        FactSource::query()->updateOrCreate(
            ['plant_id' => $plant->id, 'field' => $fact->field, 'source_name' => $draft->source->displayName()],
            ['source_url' => $draft->sourceUrl, 'licence' => $draft->licence, 'imported_at' => $draft->importedAt],
        );
    }

    private function same(mixed $a, mixed $b): bool
    {
        if (is_numeric($a) && is_numeric($b)) {
            return abs((float) $a - (float) $b) < 0.05;
        }

        return mb_strtolower(trim((string) $a)) === mb_strtolower(trim((string) $b));
    }

    private function find(string $scientificName, bool $lock = false): ?Plant
    {
        $query = Plant::query()->whereRaw('lower(scientific_name) = ?', [mb_strtolower($scientificName)]);

        return ($lock ? $query->lockForUpdate() : $query)->first();
    }

    /**
     * @throws PlantImportRejected
     */
    private function category(?string $code): PlantCategory
    {
        if ($code === null || trim($code) === '') {
            throw new PlantImportRejected('The plant is not in the catalogue yet; give its category with --category=<code>.');
        }

        return PlantCategory::query()->where('code', trim($code))->first()
            ?? throw new PlantImportRejected("There is no plant category with code {$code}.");
    }
}
