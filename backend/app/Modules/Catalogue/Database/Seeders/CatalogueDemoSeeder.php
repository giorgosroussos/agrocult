<?php

namespace App\Modules\Catalogue\Database\Seeders;

use App\Modules\Catalogue\Enums\AliasKind;
use App\Modules\Catalogue\Enums\CalendarActivity;
use App\Modules\Catalogue\Enums\CareAction;
use App\Modules\Catalogue\Enums\CompanionRelation;
use App\Modules\Catalogue\Enums\FrostHardiness;
use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Enums\Sun;
use App\Modules\Catalogue\Enums\TipStatus;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Models\Settlement;
use App\Modules\Catalogue\Models\Tip;
use App\Modules\Catalogue\Services\PlantWorkflow;
use Illuminate\Console\Command;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Development-only demo catalogue (P2-T7, CR-P2-T7-1) so that the app can be previewed.
 *
 * Seeds categories, 5 climate zones with placeholder thresholds, 10 common Greek garden
 * plants with texts, aliases, calendars, care intervals, companions and tips, and a few
 * settlements. 8 plants are published through PlantWorkflow (which queues a snapshot
 * build), the fig stays in review and the garlic stays a draft. Every zone and plant
 * carries DEMO_MARKER in its description; plant names stay unmarked.
 *
 * The content is placeholder, not expert-reviewed, and does not count towards the curated
 * catalogue. It never runs in production. It is idempotent: rows are found by their
 * natural keys, and a plant that already exists is left untouched.
 * No photos, no external calls. `php artisan migrate:fresh` removes it.
 */
class CatalogueDemoSeeder extends Seeder
{
    public const DEMO_MARKER = 'demo - not expert-reviewed';

    /** Placeholder calendar shift in months per zone, relative to the coastal lowlands. */
    private const ZONES = [
        'south_islands' => [
            'name_el' => 'Κρήτη και νότια νησιά',
            'name_en' => 'Crete and southern islands',
            'description' => 'Mild winters, rare frost, long hot summers.',
            'rules' => ['placeholder' => true, 'winter_min_mean_c' => ['min' => 8, 'max' => null], 'elevation_m' => ['min' => 0, 'max' => 300]],
            'shift' => -1,
        ],
        'coastal_lowland' => [
            'name_el' => 'Παράκτια και πεδινά',
            'name_en' => 'Coastal lowlands',
            'description' => 'Mild winters with occasional light frost.',
            'rules' => ['placeholder' => true, 'winter_min_mean_c' => ['min' => 4, 'max' => 8], 'elevation_m' => ['min' => 0, 'max' => 300]],
            'shift' => 0,
        ],
        'inland_plains' => [
            'name_el' => 'Ηπειρωτικά πεδινά',
            'name_en' => 'Inland plains',
            'description' => 'Cold winters with regular frost, hot dry summers.',
            'rules' => ['placeholder' => true, 'winter_min_mean_c' => ['min' => 0, 'max' => 4], 'elevation_m' => ['min' => 0, 'max' => 400]],
            'shift' => 1,
        ],
        'semi_mountain' => [
            'name_el' => 'Ημιορεινή',
            'name_en' => 'Semi-mountainous',
            'description' => 'Cold winters, late spring frost, cooler summers.',
            'rules' => ['placeholder' => true, 'winter_min_mean_c' => ['min' => -3, 'max' => 0], 'elevation_m' => ['min' => 400, 'max' => 800]],
            'shift' => 1,
        ],
        'mountain' => [
            'name_el' => 'Ορεινή',
            'name_en' => 'Mountain',
            'description' => 'Long cold winters with snow, short growing season.',
            'rules' => ['placeholder' => true, 'winter_min_mean_c' => ['min' => null, 'max' => -3], 'elevation_m' => ['min' => 800, 'max' => null]],
            'shift' => 2,
        ],
    ];

    private const CATEGORIES = [
        'vegetables' => ['Λαχανικά', 'Vegetables', 1],
        'herbs' => ['Αρωματικά', 'Herbs', 2],
        'fruit_trees' => ['Οπωροφόρα', 'Fruit trees', 3],
    ];

    /** [name_el, name_en, region, lat, lon] */
    private const SETTLEMENTS = [
        ['Αθήνα', 'Athens', 'Αττική', 37.983810, 23.727539],
        ['Θεσσαλονίκη', 'Thessaloniki', 'Κεντρική Μακεδονία', 40.640063, 22.944419],
        ['Ηράκλειο', 'Heraklion', 'Κρήτη', 35.338735, 25.144213],
        ['Πάτρα', 'Patras', 'Δυτική Ελλάδα', 38.246639, 21.734573],
        ['Λάρισα', 'Larissa', 'Θεσσαλία', 39.639022, 22.419125],
        ['Ιωάννινα', 'Ioannina', 'Ήπειρος', 39.665029, 20.853747],
        ['Φλώρινα', 'Florina', 'Δυτική Μακεδονία', 40.781968, 21.409834],
        ['Καλαμάτα', 'Kalamata', 'Πελοπόννησος', 37.038924, 22.114171],
    ];

    /** [plant, other plant, relation] by scientific name */
    private const COMPANIONS = [
        ['Solanum lycopersicum', 'Ocimum basilicum', 'good'],
        ['Ocimum basilicum', 'Solanum lycopersicum', 'good'],
        ['Capsicum annuum', 'Ocimum basilicum', 'good'],
        ['Lactuca sativa', 'Allium sativum', 'good'],
        ['Cucurbita pepo', 'Lactuca sativa', 'good'],
        ['Ocimum basilicum', 'Salvia rosmarinus', 'bad'],
        ['Salvia rosmarinus', 'Ocimum basilicum', 'bad'],
    ];

    public function __construct(private readonly PlantWorkflow $workflow) {}

    public function run(): void
    {
        if (app()->environment('production')) {
            $this->say('warn', 'The catalogue demo seeder never runs in production; nothing was written.');

            return;
        }

        DB::transaction(function (): void {
            $categories = $this->categories();
            $zones = $this->zones();
            $this->settlements();

            /** @var array<string, array{0: Plant, 1: PlantStatus}> $created */
            $created = [];
            foreach ($this->plants() as $data) {
                $plant = Plant::query()->where('scientific_name', $data['scientific_name'])->first();

                if ($plant !== null) {
                    $this->say('info', "Demo plant {$data['scientific_name']} already exists; left unchanged.");

                    continue;
                }

                $created[$data['scientific_name']] = [$this->createPlant($data, $categories, $zones), $data['status']];
            }

            $this->companions();
            $this->tips($zones);

            // Publishing last, once all content is in place, so the snapshot build sees complete plants.
            foreach ($created as [$plant, $status]) {
                $this->walkTo($plant, $status);
            }
        });
    }

    /**
     * @return array<string, PlantCategory> by code
     */
    private function categories(): array
    {
        $categories = [];

        foreach (self::CATEGORIES as $code => [$el, $en, $sort]) {
            $categories[$code] = PlantCategory::query()->firstOrCreate(
                ['code' => $code],
                ['name_el' => $el, 'name_en' => $en, 'sort_order' => $sort],
            );
        }

        return $categories;
    }

    /**
     * @return array<string, ClimateZone> by code
     */
    private function zones(): array
    {
        $zones = [];

        foreach (self::ZONES as $code => $zone) {
            $zones[$code] = ClimateZone::query()->firstOrCreate(['code' => $code], [
                'name_el' => $zone['name_el'],
                'name_en' => $zone['name_en'],
                'description' => $zone['description'].' Placeholder thresholds ('.self::DEMO_MARKER.').',
                'rules' => $zone['rules'],
            ]);
        }

        return $zones;
    }

    private function settlements(): void
    {
        foreach (self::SETTLEMENTS as [$el, $en, $region, $lat, $lon]) {
            Settlement::query()->firstOrCreate(
                ['name_el' => $el, 'region' => $region],
                ['name_en' => $en, 'lat' => $lat, 'lon' => $lon],
            );
        }
    }

    /**
     * @param  array<string, mixed>  $data  one entry of plants()
     * @param  array<string, PlantCategory>  $categories
     * @param  array<string, ClimateZone>  $zones
     */
    private function createPlant(array $data, array $categories, array $zones): Plant
    {
        /** @var array<string, mixed> $fields */
        $fields = $data['fields'];
        $plant = Plant::query()->create(['scientific_name' => $data['scientific_name'], 'category_id' => $categories[$data['category']]->id] + $fields);

        /** @var array<string, array<string, string>> $texts */
        $texts = $data['texts'];
        foreach ($texts as $lang => $text) {
            $text['description'] .= ' ('.self::DEMO_MARKER.')';
            $plant->translations()->create(['lang' => $lang] + $text);
        }

        /** @var list<array{0: string, 1: string, 2: AliasKind}> $aliases */
        $aliases = $data['aliases'];
        foreach ($aliases as [$alias, $lang, $kind]) {
            $plant->aliases()->create(['alias' => $alias, 'lang' => $lang, 'kind' => $kind]);
        }

        /** @var list<array{0: CalendarActivity, 1: int, 2: int, 3?: int}> $calendar */
        $calendar = $data['calendar'];
        /** @var list<string> $notIn */
        $notIn = $data['not_in'] ?? [];
        foreach ($zones as $code => $zone) {
            if (in_array($code, $notIn, true)) {
                continue;
            }

            $shift = self::ZONES[$code]['shift'];
            foreach ($calendar as $entry) {
                $direction = $entry[3] ?? 1;
                $plant->calendars()->create([
                    'climate_zone_id' => $zone->id,
                    'activity' => $entry[0],
                    'month_from' => $this->shiftMonth($entry[1], $shift * $direction),
                    'month_to' => $this->shiftMonth($entry[2], $shift * $direction),
                ]);
            }
        }

        /** @var list<array{0: CareAction, 1: int, 2: int|null, 3: int|null}> $care */
        $care = $data['care'];
        foreach ($care as [$action, $days, $from, $to]) {
            $plant->careIntervals()->create(['action' => $action, 'interval_days' => $days, 'month_from' => $from, 'month_to' => $to]);
        }

        return $plant;
    }

    private function companions(): void
    {
        $ids = Plant::query()
            ->whereIn('scientific_name', array_merge(array_column(self::COMPANIONS, 0), array_column(self::COMPANIONS, 1)))
            ->pluck('id', 'scientific_name');

        foreach (self::COMPANIONS as [$plant, $other, $relation]) {
            if (! isset($ids[$plant], $ids[$other])) {
                continue;
            }

            Plant::query()->findOrFail($ids[$plant])->companions()->firstOrCreate(
                ['other_plant_id' => $ids[$other]],
                ['relation' => CompanionRelation::from($relation)],
            );
        }
    }

    /**
     * @param  array<string, ClimateZone>  $zones
     */
    private function tips(array $zones): void
    {
        $plant = fn (string $scientific): ?string => Plant::query()->where('scientific_name', $scientific)->value('id');
        $marker = ' ('.self::DEMO_MARKER.')';

        $tips = [
            ['Ποτίζετε νωρίς το πρωί ή αργά το απόγευμα, όχι με τον καυτό ήλιο.', 'Water early in the morning or late in the afternoon, not in the midday heat.', 6, 9, null, null],
            ['Ένα στρώμα άχυρου γύρω από τα φυτά κρατά την υγρασία του εδάφους το καλοκαίρι.', 'A layer of straw around your plants keeps the soil moist in summer.', 5, 9, null, null],
            ['Δέστε τις ντομάτες σε πασσάλους πριν βαρύνουν από τους καρπούς.', 'Stake tomatoes before the fruit makes them heavy.', 5, 7, null, $plant('Solanum lycopersicum')],
            ['Στις ορεινές περιοχές περιμένετε να περάσει ο κίνδυνος παγετού πριν τη μεταφύτευση.', 'In mountain areas, wait until the risk of frost has passed before transplanting.', 4, 5, $zones['mountain']->id, null],
            ['Φυτέψτε σκελίδες σκόρδου το φθινόπωρο για συγκομιδή στις αρχές του καλοκαιριού.', 'Plant garlic cloves in autumn for a harvest in early summer.', 10, 12, null, $plant('Allium sativum')],
        ];

        foreach ($tips as [$el, $en, $from, $to, $zone, $plantId]) {
            Tip::query()->firstOrCreate(['text_el' => $el.$marker], [
                'text_en' => $en.$marker,
                'month_from' => $from,
                'month_to' => $to,
                'climate_zone_id' => $zone,
                'plant_id' => $plantId,
                'status' => TipStatus::Published,
            ]);
        }
    }

    private function walkTo(Plant $plant, PlantStatus $status): void
    {
        $path = match ($status) {
            PlantStatus::Draft => [],
            PlantStatus::InReview => [PlantStatus::InReview],
            PlantStatus::Published => [PlantStatus::InReview, PlantStatus::Published],
            PlantStatus::Archived => [PlantStatus::InReview, PlantStatus::Published, PlantStatus::Archived],
        };

        foreach ($path as $to) {
            $this->workflow->transition($plant, $to);
        }
    }

    private function shiftMonth(int $month, int $by): int
    {
        return (($month - 1 + $by) % 12 + 12) % 12 + 1;
    }

    private function say(string $style, string $message): void
    {
        // Unset when the seeder runs outside `db:seed` (e.g. called from a test).
        /** @var Command|null $command */
        $command = $this->command;

        if ($command === null) {
            return;
        }

        $style === 'warn' ? $command->warn($message) : $command->info($message);
    }

    /**
     * Placeholder demo content. Calendars are given for the coastal lowlands and shifted per
     * zone (an optional 4th value -1 shifts the other way, e.g. autumn sowing in cold zones).
     *
     * @return list<array<string, mixed>>
     */
    private function plants(): array
    {
        return [
            [
                'scientific_name' => 'Solanum lycopersicum',
                'category' => 'vegetables',
                'status' => PlantStatus::Published,
                'fields' => [
                    'temp_min_c' => 10, 'temp_opt_c' => 24, 'temp_max_c' => 35, 'water_need' => 4,
                    'sun' => Sun::FullSun, 'soil_types' => ['loam', 'well_drained'], 'ph_min' => 6.0, 'ph_max' => 7.0,
                    'frost_hardiness' => FrostHardiness::Tender, 'propagation' => ['seed', 'transplant'],
                    'sow_depth_cm' => 0.5, 'spacing_cm' => 50, 'row_spacing_cm' => 80, 'days_to_harvest' => 80,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Ντομάτα',
                        'description' => 'Το πιο αγαπημένο λαχανικό του ελληνικού κήπου, για σαλάτες και σάλτσες.',
                        'planting' => 'Σπείρετε σε σπορεία και μεταφυτεύστε όταν περάσει ο κίνδυνος παγετού.',
                        'care' => 'Τακτικό και βαθύ πότισμα, στήριξη με πασσάλους, αφαίρεση πλάγιων βλαστών.',
                        'seed_saving' => 'Κρατήστε σπόρους από ώριμους καρπούς παραδοσιακών ποικιλιών.',
                        'tips' => 'Ποτίζετε στη ρίζα και όχι στα φύλλα.',
                    ],
                    'en' => [
                        'name' => 'Tomato',
                        'description' => 'The favourite vegetable of the Greek garden, for salads and sauces.',
                        'planting' => 'Sow in trays and transplant once the risk of frost has passed.',
                        'care' => 'Regular deep watering, staking and removing side shoots.',
                        'seed_saving' => 'Save seeds from ripe fruit of heirloom varieties.',
                        'tips' => 'Water at the roots, not on the leaves.',
                    ],
                ],
                'aliases' => [['τομάτα', 'el', AliasKind::Synonym], ['ntomata', 'el', AliasKind::Greeklish], ['domata', 'el', AliasKind::Greeklish]],
                'calendar' => [[CalendarActivity::SowIndoors, 2, 3], [CalendarActivity::Transplant, 4, 5], [CalendarActivity::Harvest, 7, 10]],
                'care' => [[CareAction::Water, 2, 6, 9], [CareAction::Water, 4, 4, 5], [CareAction::Fertilise, 21, 5, 8]],
            ],
            [
                'scientific_name' => 'Ocimum basilicum',
                'category' => 'herbs',
                'status' => PlantStatus::Published,
                'fields' => [
                    'temp_min_c' => 12, 'temp_opt_c' => 25, 'temp_max_c' => 35, 'water_need' => 3,
                    'sun' => Sun::FullSun, 'soil_types' => ['loam', 'well_drained'], 'ph_min' => 6.0, 'ph_max' => 7.5,
                    'frost_hardiness' => FrostHardiness::Tender, 'propagation' => ['seed', 'cutting'],
                    'sow_depth_cm' => 0.3, 'spacing_cm' => 25, 'row_spacing_cm' => 40, 'days_to_harvest' => 60,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Βασιλικός',
                        'description' => 'Αρωματικό φυτό με παράδοση σε κάθε ελληνική αυλή και μπαλκόνι.',
                        'planting' => 'Σπείρετε την άνοιξη σε ζεστό έδαφος ή σε γλάστρα.',
                        'care' => 'Κορυφολογείτε τακτικά για να θαμνώσει και να μην ανθίσει νωρίς.',
                        'seed_saving' => 'Αφήστε μερικά φυτά να ανθίσουν και μαζέψτε τους ξερούς σπόρους.',
                        'tips' => 'Ταιριάζει δίπλα στις ντομάτες.',
                    ],
                    'en' => [
                        'name' => 'Basil',
                        'description' => 'Aromatic herb found in every Greek courtyard and balcony.',
                        'planting' => 'Sow in spring in warm soil or in a pot.',
                        'care' => 'Pinch the tips regularly so it grows bushy and does not flower early.',
                        'seed_saving' => 'Let a few plants flower and collect the dry seeds.',
                        'tips' => 'Grows well next to tomatoes.',
                    ],
                ],
                'aliases' => [['vasilikos', 'el', AliasKind::Greeklish], ['sweet basil', 'en', AliasKind::Synonym]],
                'calendar' => [[CalendarActivity::SowIndoors, 3, 4], [CalendarActivity::SowOutdoors, 5, 6], [CalendarActivity::Harvest, 6, 10]],
                'care' => [[CareAction::Water, 2, 6, 9], [CareAction::Prune, 14, 6, 9]],
            ],
            [
                'scientific_name' => 'Capsicum annuum',
                'category' => 'vegetables',
                'status' => PlantStatus::Published,
                'fields' => [
                    'temp_min_c' => 12, 'temp_opt_c' => 25, 'temp_max_c' => 35, 'water_need' => 4,
                    'sun' => Sun::FullSun, 'soil_types' => ['loam', 'well_drained'], 'ph_min' => 6.0, 'ph_max' => 7.0,
                    'frost_hardiness' => FrostHardiness::Tender, 'propagation' => ['seed', 'transplant'],
                    'sow_depth_cm' => 0.5, 'spacing_cm' => 45, 'row_spacing_cm' => 70, 'days_to_harvest' => 90,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Πιπεριά',
                        'description' => 'Γλυκές και καυτερές πιπεριές για γεμιστά, σαλάτες και ψητά.',
                        'planting' => 'Σπείρετε σε σπορεία στα τέλη του χειμώνα και μεταφυτεύστε σε ζεστό έδαφος.',
                        'care' => 'Σταθερή υγρασία και λίπανση κατά την καρποφορία.',
                        'seed_saving' => 'Μαζέψτε σπόρους από πλήρως ώριμους, κόκκινους καρπούς.',
                        'tips' => 'Θέλει περισσότερη ζέστη από τη ντομάτα για να ξεκινήσει.',
                    ],
                    'en' => [
                        'name' => 'Pepper',
                        'description' => 'Sweet and hot peppers for stuffing, salads and grilling.',
                        'planting' => 'Sow in trays in late winter and transplant into warm soil.',
                        'care' => 'Even moisture and feeding while fruiting.',
                        'seed_saving' => 'Collect seeds from fully ripe, red fruit.',
                        'tips' => 'Needs more warmth than tomatoes to get going.',
                    ],
                ],
                'aliases' => [['piperia', 'el', AliasKind::Greeklish], ['bell pepper', 'en', AliasKind::Synonym]],
                'calendar' => [[CalendarActivity::SowIndoors, 2, 3], [CalendarActivity::Transplant, 5, 5], [CalendarActivity::Harvest, 7, 10]],
                'care' => [[CareAction::Water, 2, 6, 9], [CareAction::Fertilise, 21, 6, 8]],
            ],
            [
                'scientific_name' => 'Olea europaea',
                'category' => 'fruit_trees',
                'status' => PlantStatus::Published,
                'not_in' => ['mountain'],
                'fields' => [
                    'temp_min_c' => -7, 'temp_opt_c' => 22, 'temp_max_c' => 40, 'water_need' => 2,
                    'sun' => Sun::FullSun, 'soil_types' => ['well_drained', 'sandy', 'loam'], 'ph_min' => 6.5, 'ph_max' => 8.5,
                    'frost_hardiness' => FrostHardiness::HalfHardy, 'propagation' => ['cutting', 'grafting'],
                    'sow_depth_cm' => null, 'spacing_cm' => 600, 'row_spacing_cm' => 700, 'days_to_harvest' => null,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Ελιά',
                        'description' => 'Το δέντρο της Μεσογείου, για ελιές και λάδι, ανθεκτικό στην ξηρασία.',
                        'planting' => 'Φυτέψτε δενδρύλλιο το φθινόπωρο ή νωρίς την άνοιξη σε ηλιόλουστη θέση.',
                        'care' => 'Λίγο πότισμα μετά την εγκατάσταση, κλάδεμα στα τέλη του χειμώνα.',
                        'seed_saving' => 'Πολλαπλασιάζεται με μοσχεύματα, όχι με σπόρο.',
                        'tips' => 'Μην ποτίζετε υπερβολικά, οι ρίζες σαπίζουν σε υγρό έδαφος.',
                    ],
                    'en' => [
                        'name' => 'Olive',
                        'description' => 'The Mediterranean tree for olives and oil, drought tolerant.',
                        'planting' => 'Plant a young tree in autumn or early spring in a sunny spot.',
                        'care' => 'Little water once established, prune in late winter.',
                        'seed_saving' => 'Propagated by cuttings, not by seed.',
                        'tips' => 'Do not overwater; roots rot in wet soil.',
                    ],
                ],
                'aliases' => [['elia', 'el', AliasKind::Greeklish], ['ελαιόδεντρο', 'el', AliasKind::Synonym], ['olive tree', 'en', AliasKind::Synonym]],
                'calendar' => [[CalendarActivity::Transplant, 10, 11], [CalendarActivity::Harvest, 10, 1]],
                'care' => [[CareAction::Water, 14, 6, 8], [CareAction::Prune, 365, 2, 3]],
            ],
            [
                'scientific_name' => 'Citrus limon',
                'category' => 'fruit_trees',
                'status' => PlantStatus::Published,
                'not_in' => ['mountain'],
                'fields' => [
                    'temp_min_c' => -2, 'temp_opt_c' => 25, 'temp_max_c' => 38, 'water_need' => 3,
                    'sun' => Sun::FullSun, 'soil_types' => ['well_drained', 'loam'], 'ph_min' => 5.5, 'ph_max' => 7.0,
                    'frost_hardiness' => FrostHardiness::Tender, 'propagation' => ['grafting', 'cutting'],
                    'sow_depth_cm' => null, 'spacing_cm' => 400, 'row_spacing_cm' => 500, 'days_to_harvest' => null,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Λεμονιά',
                        'description' => 'Αειθαλές δέντρο με αρωματικά άνθη και λεμόνια σχεδόν όλο τον χρόνο.',
                        'planting' => 'Φυτέψτε την άνοιξη σε προστατευμένη, ηλιόλουστη θέση.',
                        'care' => 'Τακτικό πότισμα το καλοκαίρι, λίπανση την άνοιξη, προστασία από τον παγετό.',
                        'seed_saving' => 'Πολλαπλασιάζεται κυρίως με εμβολιασμό.',
                        'tips' => 'Σε κρύες περιοχές καλλιεργείται σε γλάστρα και μπαίνει μέσα τον χειμώνα.',
                    ],
                    'en' => [
                        'name' => 'Lemon tree',
                        'description' => 'Evergreen tree with fragrant flowers and lemons almost all year round.',
                        'planting' => 'Plant in spring in a sheltered, sunny spot.',
                        'care' => 'Regular watering in summer, feed in spring, protect from frost.',
                        'seed_saving' => 'Mostly propagated by grafting.',
                        'tips' => 'In cold areas grow it in a pot and bring it indoors in winter.',
                    ],
                ],
                'aliases' => [['lemonia', 'el', AliasKind::Greeklish], ['λεμόνι', 'el', AliasKind::LocalName], ['lemon', 'en', AliasKind::Synonym]],
                'calendar' => [[CalendarActivity::Transplant, 3, 4], [CalendarActivity::Harvest, 11, 4]],
                'care' => [[CareAction::Water, 4, 6, 9], [CareAction::Fertilise, 60, 3, 9]],
            ],
            [
                'scientific_name' => 'Lactuca sativa',
                'category' => 'vegetables',
                'status' => PlantStatus::Published,
                'fields' => [
                    'temp_min_c' => 2, 'temp_opt_c' => 16, 'temp_max_c' => 26, 'water_need' => 3,
                    'sun' => Sun::PartialShade, 'soil_types' => ['loam'], 'ph_min' => 6.0, 'ph_max' => 7.0,
                    'frost_hardiness' => FrostHardiness::HalfHardy, 'propagation' => ['seed', 'transplant'],
                    'sow_depth_cm' => 0.5, 'spacing_cm' => 25, 'row_spacing_cm' => 30, 'days_to_harvest' => 60,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Μαρούλι',
                        'description' => 'Δροσερό φυλλώδες λαχανικό για τον χειμερινό και ανοιξιάτικο κήπο.',
                        'planting' => 'Σπείρετε ή μεταφυτεύστε το φθινόπωρο και νωρίς την άνοιξη.',
                        'care' => 'Σταθερή υγρασία, σκίαση τις ζεστές μέρες.',
                        'seed_saving' => 'Αφήστε ένα φυτό να ανεβάσει ανθοφόρο στέλεχος και μαζέψτε τους σπόρους.',
                        'tips' => 'Με τη ζέστη πικρίζει και ανθίζει.',
                    ],
                    'en' => [
                        'name' => 'Lettuce',
                        'description' => 'Fresh leafy vegetable for the winter and spring garden.',
                        'planting' => 'Sow or transplant in autumn and early spring.',
                        'care' => 'Even moisture, shade on hot days.',
                        'seed_saving' => 'Let one plant bolt and collect its seeds.',
                        'tips' => 'Turns bitter and bolts in the heat.',
                    ],
                ],
                'aliases' => [['marouli', 'el', AliasKind::Greeklish], ['μαρουλάκι', 'el', AliasKind::LocalName]],
                'calendar' => [[CalendarActivity::SowOutdoors, 9, 11, -1], [CalendarActivity::SowOutdoors, 2, 3], [CalendarActivity::Harvest, 11, 5]],
                'care' => [[CareAction::Water, 3, 3, 5], [CareAction::Weed, 14, null, null]],
            ],
            [
                'scientific_name' => 'Cucurbita pepo',
                'category' => 'vegetables',
                'status' => PlantStatus::Published,
                'fields' => [
                    'temp_min_c' => 12, 'temp_opt_c' => 24, 'temp_max_c' => 35, 'water_need' => 4,
                    'sun' => Sun::FullSun, 'soil_types' => ['loam', 'well_drained'], 'ph_min' => 6.0, 'ph_max' => 7.5,
                    'frost_hardiness' => FrostHardiness::Tender, 'propagation' => ['seed'],
                    'sow_depth_cm' => 2.5, 'spacing_cm' => 90, 'row_spacing_cm' => 120, 'days_to_harvest' => 55,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Κολοκυθάκι',
                        'description' => 'Παραγωγικό καλοκαιρινό λαχανικό· λίγα φυτά αρκούν για μια οικογένεια.',
                        'planting' => 'Σπείρετε απευθείας στο χωράφι όταν ζεστάνει το έδαφος.',
                        'care' => 'Άφθονο πότισμα στη ρίζα, συχνή συγκομιδή μικρών καρπών.',
                        'seed_saving' => 'Αφήστε έναν καρπό να ωριμάσει πλήρως πριν πάρετε σπόρους.',
                        'tips' => 'Τα άνθη τρώγονται γεμιστά.',
                    ],
                    'en' => [
                        'name' => 'Courgette',
                        'description' => 'Productive summer vegetable; a few plants feed a family.',
                        'planting' => 'Sow directly outdoors once the soil is warm.',
                        'care' => 'Plenty of water at the roots, pick small fruit often.',
                        'seed_saving' => 'Let one fruit ripen fully before taking seeds.',
                        'tips' => 'The flowers are delicious stuffed.',
                    ],
                ],
                'aliases' => [['kolokythaki', 'el', AliasKind::Greeklish], ['κολοκύθι', 'el', AliasKind::Synonym], ['zucchini', 'en', AliasKind::Synonym]],
                'calendar' => [[CalendarActivity::SowOutdoors, 4, 6], [CalendarActivity::Harvest, 6, 9]],
                'care' => [[CareAction::Water, 2, 6, 9], [CareAction::Fertilise, 21, 6, 8]],
            ],
            [
                'scientific_name' => 'Salvia rosmarinus',
                'category' => 'herbs',
                'status' => PlantStatus::Published,
                'fields' => [
                    'temp_min_c' => -10, 'temp_opt_c' => 20, 'temp_max_c' => 38, 'water_need' => 1,
                    'sun' => Sun::FullSun, 'soil_types' => ['sandy', 'well_drained'], 'ph_min' => 6.0, 'ph_max' => 8.0,
                    'frost_hardiness' => FrostHardiness::Hardy, 'propagation' => ['cutting'],
                    'sow_depth_cm' => null, 'spacing_cm' => 60, 'row_spacing_cm' => 80, 'days_to_harvest' => null,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Δεντρολίβανο',
                        'description' => 'Αειθαλής αρωματικός θάμνος, σχεδόν χωρίς φροντίδα.',
                        'planting' => 'Φυτέψτε μοσχεύματα την άνοιξη ή το φθινόπωρο.',
                        'care' => 'Ελάχιστο πότισμα, ελαφρύ κλάδεμα μετά την ανθοφορία.',
                        'seed_saving' => 'Πολλαπλασιάζεται εύκολα με μοσχεύματα.',
                        'tips' => 'Αγαπά τον ήλιο και το φτωχό, στραγγερό έδαφος.',
                    ],
                    'en' => [
                        'name' => 'Rosemary',
                        'description' => 'Evergreen aromatic shrub that needs almost no care.',
                        'planting' => 'Plant cuttings in spring or autumn.',
                        'care' => 'Very little water, light pruning after flowering.',
                        'seed_saving' => 'Easily propagated from cuttings.',
                        'tips' => 'Loves sun and poor, well-drained soil.',
                    ],
                ],
                'aliases' => [['dentrolivano', 'el', AliasKind::Greeklish], ['αρισμαρί', 'el', AliasKind::LocalName], ['Rosmarinus officinalis', 'en', AliasKind::Synonym]],
                'calendar' => [[CalendarActivity::Transplant, 3, 4], [CalendarActivity::Harvest, 1, 12]],
                'care' => [[CareAction::Water, 14, 6, 8], [CareAction::Prune, 180, 5, 6]],
            ],
            [
                'scientific_name' => 'Ficus carica',
                'category' => 'fruit_trees',
                'status' => PlantStatus::InReview,
                'fields' => [
                    'temp_min_c' => -10, 'temp_opt_c' => 25, 'temp_max_c' => 40, 'water_need' => 2,
                    'sun' => Sun::FullSun, 'soil_types' => ['well_drained', 'loam'], 'ph_min' => 6.0, 'ph_max' => 8.0,
                    'frost_hardiness' => FrostHardiness::Hardy, 'propagation' => ['cutting'],
                    'sow_depth_cm' => null, 'spacing_cm' => 500, 'row_spacing_cm' => 600, 'days_to_harvest' => null,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Συκιά',
                        'description' => 'Λιτοδίαιτο δέντρο με γλυκά σύκα στα τέλη του καλοκαιριού.',
                        'planting' => 'Φυτέψτε τον χειμώνα, όταν το δέντρο είναι σε λήθαργο.',
                        'care' => 'Πότισμα τα πρώτα χρόνια, κλάδεμα για να μη ψηλώσει πολύ.',
                        'seed_saving' => 'Πολλαπλασιάζεται με μοσχεύματα.',
                        'tips' => 'Μαζέψτε τα σύκα όταν μαλακώσουν και γείρουν.',
                    ],
                    'en' => [
                        'name' => 'Fig',
                        'description' => 'Undemanding tree with sweet figs in late summer.',
                        'planting' => 'Plant in winter while the tree is dormant.',
                        'care' => 'Water in the first years, prune to keep it low.',
                        'seed_saving' => 'Propagated by cuttings.',
                        'tips' => 'Pick figs when they soften and droop.',
                    ],
                ],
                'aliases' => [['sykia', 'el', AliasKind::Greeklish], ['σύκο', 'el', AliasKind::LocalName], ['fig tree', 'en', AliasKind::Synonym]],
                'calendar' => [[CalendarActivity::Transplant, 12, 2], [CalendarActivity::Harvest, 8, 9]],
                'care' => [[CareAction::Water, 10, 6, 8], [CareAction::Prune, 365, 1, 2]],
            ],
            [
                'scientific_name' => 'Allium sativum',
                'category' => 'vegetables',
                'status' => PlantStatus::Draft,
                'fields' => [
                    'temp_min_c' => -10, 'temp_opt_c' => 15, 'temp_max_c' => 30, 'water_need' => 2,
                    'sun' => Sun::FullSun, 'soil_types' => ['loam', 'well_drained'], 'ph_min' => 6.0, 'ph_max' => 7.5,
                    'frost_hardiness' => FrostHardiness::Hardy, 'propagation' => ['clove'],
                    'sow_depth_cm' => 4.0, 'spacing_cm' => 12, 'row_spacing_cm' => 30, 'days_to_harvest' => 240,
                ],
                'texts' => [
                    'el' => [
                        'name' => 'Σκόρδο',
                        'description' => 'Εύκολη χειμωνιάτικη καλλιέργεια που αποθηκεύεται για μήνες.',
                        'planting' => 'Φυτέψτε σκελίδες με τη μύτη προς τα πάνω το φθινόπωρο.',
                        'care' => 'Λίγο πότισμα, καθαρό από ζιζάνια, σταματάτε το πότισμα πριν τη συγκομιδή.',
                        'seed_saving' => 'Κρατήστε τις μεγαλύτερες κεφαλές για φύτεμα τον επόμενο χρόνο.',
                        'tips' => 'Συγκομίζεται όταν κιτρινίσουν τα μισά φύλλα.',
                    ],
                    'en' => [
                        'name' => 'Garlic',
                        'description' => 'Easy winter crop that keeps for months.',
                        'planting' => 'Plant cloves pointed end up in autumn.',
                        'care' => 'Little water, keep weed-free, stop watering before harvest.',
                        'seed_saving' => 'Keep the largest bulbs to plant next year.',
                        'tips' => 'Harvest when half of the leaves have turned yellow.',
                    ],
                ],
                'aliases' => [['skordo', 'el', AliasKind::Greeklish]],
                'calendar' => [[CalendarActivity::SowOutdoors, 10, 12, -1], [CalendarActivity::Harvest, 6, 7]],
                'care' => [[CareAction::Weed, 21, null, null], [CareAction::Water, 10, 3, 5]],
            ],
        ];
    }
}
