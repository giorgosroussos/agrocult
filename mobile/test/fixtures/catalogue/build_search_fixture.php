<?php

/**
 * Builds test/fixtures/catalogue/search_fixture.sqlite for the search and plant card tests
 * (P2-T6) with the backend's own SnapshotWriter and SearchKeys, so the search keys are
 * exactly what the server computes. Rows are what SnapshotExporter exports for published
 * plants (no database or Laravel needed).
 *
 * Run from the repository root with PHP 8.3 (pdo_sqlite, intl), e.g. in the Sail image:
 *   php mobile/test/fixtures/catalogue/build_search_fixture.php
 */

declare(strict_types=1);

$root = dirname(__DIR__, 4);
require $root.'/backend/app/Modules/Catalogue/Snapshot/SearchKeys.php';
require $root.'/backend/app/Modules/Catalogue/Snapshot/SnapshotWriter.php';

use App\Modules\Catalogue\Snapshot\SearchKeys;
use App\Modules\Catalogue\Snapshot\SnapshotWriter;

$target = __DIR__.'/search_fixture.sqlite';
if (file_exists($target)) {
    unlink($target);
}

$id = fn (int $n): string => sprintf('00000000-0000-7000-8000-%012d', $n);
$at = '2026-10-01T10:00:00Z';

$vegetables = $id(1);
$herbs = $id(2);
$leafy = $id(3);
$coastal = $id(11);
$mountain = $id(12);

$tomato = $id(101);
$garlic = $id(102);
$basil = $id(103);
$mint = $id(104);
$oregano = $id(105);
$lettuce = $id(106);

$translations = [
    [$tomato, 'el', 'Ντομάτα', 'Η ντομάτα είναι το πιο αγαπημένο λαχανικό του κήπου.', 'Μεταφύτευση όταν περάσει ο κίνδυνος παγετού.', 'Πότισμα στη ρίζα, όχι στα φύλλα.', 'Κρατήστε σπόρους από ώριμους καρπούς.', 'Κορυφολόγηση στα 6 τσαμπιά.'],
    [$tomato, 'en', 'Tomato', 'The tomato is the favourite vegetable of the garden.', 'Transplant once the risk of frost has passed.', 'Water at the root, not on the leaves.', 'Keep seeds from ripe fruit.', 'Top the plant after six trusses.'],
    [$garlic, 'el', 'Σκόρδο', 'Το σκόρδο φυτεύεται το φθινόπωρο.', 'Σκελίδες σε βάθος 5 εκατοστών.', 'Λίγο νερό.', null, null],
    [$garlic, 'en', 'Garlic', 'Garlic is planted in autumn.', 'Cloves 5 cm deep.', 'Little water.', null, null],
    [$basil, 'el', 'Βασιλικός', 'Ο βασιλικός της αυλής.', 'Σπορά σε γλάστρα.', 'Συχνό πότισμα.', 'Αφήστε λίγα φυτά να ανθίσουν.', null],
    [$basil, 'en', 'Basil', 'The basil of the yard.', 'Sow in a pot.', 'Water often.', 'Let a few plants flower.', null],
    [$mint, 'el', 'Δυόσμος', 'Ο δυόσμος απλώνεται γρήγορα.', null, null, null, null],
    [$mint, 'en', 'Spearmint', 'Spearmint spreads fast.', null, null, null, null],
    // Only Greek text: the English UI falls back to it, marked as not translated.
    [$oregano, 'el', 'Ρίγανη', 'Η ρίγανη των βουνών.', 'Μοσχεύματα την άνοιξη.', 'Δεν θέλει σχεδόν πότισμα.', 'Μαζέψτε τους σπόρους το καλοκαίρι.', 'Κόψτε την όταν ανθίσει.'],
    [$lettuce, 'el', 'Μαρούλι', 'Το μαρούλι του χειμώνα.', null, null, null, null],
    [$lettuce, 'en', 'Lettuce', 'Winter lettuce.', null, null, null, null],
];

$aliases = [
    [$mint, 'el', 'Ηδύοσμος', 'synonym'],
    [$tomato, 'el', 'Ντοματιά', 'local_name'],
];

$plantRows = [
    // id, scientific name, category, extra fields
    [$tomato, 'Solanum lycopersicum', $vegetables, [
        'temp_min_c' => 10.0, 'temp_opt_c' => 24.0, 'temp_max_c' => 35.0, 'water_need' => 4,
        'sun' => 'full_sun', 'soil_types' => '["loam","clay"]', 'ph_min' => 6.0, 'ph_max' => 6.8,
        'frost_hardiness' => 'tender', 'propagation' => '["seed"]', 'sow_depth_cm' => 0.5,
        'spacing_cm' => 50, 'row_spacing_cm' => 80, 'days_to_harvest' => 80, 'gbif_id' => 2930137,
    ]],
    [$garlic, 'Allium sativum', $vegetables, ['frost_hardiness' => 'hardy', 'water_need' => 2]],
    [$basil, 'Ocimum basilicum', $herbs, ['sun' => 'full_sun']],
    [$mint, 'Mentha spicata', $herbs, []],
    [$oregano, 'Origanum vulgare', $herbs, ['sun' => 'full_sun', 'water_need' => 1]],
    [$lettuce, 'Lactuca sativa', $leafy, []],
];

$plants = [];
foreach ($plantRows as [$plantId, $scientific, $category, $extra]) {
    $texts = array_merge(
        array_map(fn (array $t): string => $t[2], array_values(array_filter($translations, fn (array $t): bool => $t[0] === $plantId))),
        array_map(fn (array $a): string => $a[2], array_values(array_filter($aliases, fn (array $a): bool => $a[0] === $plantId))),
        [$scientific],
    );
    $plants[] = $extra + [
        'id' => $plantId,
        'scientific_name' => $scientific,
        'gbif_id' => null,
        'category_id' => $category,
        'temp_min_c' => null, 'temp_opt_c' => null, 'temp_max_c' => null, 'water_need' => null,
        'sun' => null, 'soil_types' => null, 'ph_min' => null, 'ph_max' => null,
        'frost_hardiness' => null, 'propagation' => null, 'sow_depth_cm' => null,
        'spacing_cm' => null, 'row_spacing_cm' => null, 'days_to_harvest' => null,
        'published_at' => $at, 'updated_at' => $at,
        'search_keys' => SearchKeys::asText($texts),
    ];
}

$n = 1000;
$next = function () use (&$n, $id): string {
    return $id(++$n);
};

$calendars = [
    [$tomato, $coastal, 'sow_indoors', 2, 3],
    [$tomato, $coastal, 'transplant', 4, 5],
    [$tomato, $coastal, 'harvest', 6, 9],
    [$tomato, $mountain, 'sow_indoors', 3, 4],
    [$tomato, $mountain, 'transplant', 5, 6],
    [$tomato, $mountain, 'harvest', 7, 9],
    // Across the new year.
    [$garlic, $coastal, 'sow_outdoors', 10, 1],
    [$garlic, $coastal, 'harvest', 5, 6],
    [$garlic, $mountain, 'sow_outdoors', 2, 3],
    [$garlic, $mountain, 'harvest', 7, 8],
    [$basil, $coastal, 'sow_outdoors', 4, 6],
    [$lettuce, $coastal, 'harvest', 11, 2],
];

$tables = [
    'categories' => [
        ['id' => $vegetables, 'code' => 'vegetables', 'name_el' => 'Λαχανικά', 'name_en' => 'Vegetables', 'parent_id' => null, 'sort_order' => 1],
        ['id' => $herbs, 'code' => 'herbs', 'name_el' => 'Αρωματικά', 'name_en' => 'Herbs', 'parent_id' => null, 'sort_order' => 2],
        ['id' => $leafy, 'code' => 'leafy', 'name_el' => 'Φυλλώδη', 'name_en' => 'Leafy greens', 'parent_id' => $vegetables, 'sort_order' => 3],
    ],
    'climate_zones' => [
        ['id' => $coastal, 'code' => 'coastal', 'name_el' => 'Παράκτια', 'name_en' => 'Coastal', 'description' => null, 'rules' => '[]'],
        ['id' => $mountain, 'code' => 'mountain', 'name_el' => 'Ορεινή', 'name_en' => 'Mountain', 'description' => null, 'rules' => '[]'],
    ],
    'plants' => $plants,
    'plant_translations' => array_map(fn (array $t): array => [
        'id' => $next(), 'plant_id' => $t[0], 'lang' => $t[1], 'name' => $t[2], 'description' => $t[3],
        'planting' => $t[4] ?? null, 'care' => $t[5] ?? null, 'seed_saving' => $t[6] ?? null, 'tips' => $t[7] ?? null,
    ], $translations),
    'plant_aliases' => array_map(fn (array $a): array => [
        'id' => $next(), 'plant_id' => $a[0], 'lang' => $a[1], 'alias' => $a[2], 'kind' => $a[3],
    ], $aliases),
    'plant_calendars' => array_map(fn (array $c): array => [
        'id' => $next(), 'plant_id' => $c[0], 'climate_zone_id' => $c[1], 'activity' => $c[2],
        'month_from' => $c[3], 'month_to' => $c[4],
    ], $calendars),
    'companions' => [
        ['id' => $next(), 'plant_id' => $tomato, 'other_plant_id' => $basil, 'relation' => 'good'],
        ['id' => $next(), 'plant_id' => $tomato, 'other_plant_id' => $garlic, 'relation' => 'bad'],
    ],
    'care_intervals' => [
        ['id' => $next(), 'plant_id' => $tomato, 'action' => 'water', 'interval_days' => 3, 'month_from' => 5, 'month_to' => 9],
        ['id' => $next(), 'plant_id' => $tomato, 'action' => 'fertilise', 'interval_days' => 14, 'month_from' => null, 'month_to' => null],
    ],
    'plant_photos' => [],
    'fact_sources' => [
        ['id' => $next(), 'plant_id' => $tomato, 'field' => 'temp_min_c', 'source_name' => 'Wikidata', 'source_url' => 'https://www.wikidata.org/wiki/Q23501', 'licence' => 'CC0', 'imported_at' => $at],
    ],
    'tips' => [
        ['id' => $next(), 'text_el' => 'Η ντομάτα θέλει στήριγμα.', 'text_en' => 'Tomatoes need a stake.', 'month_from' => null, 'month_to' => null, 'climate_zone_id' => null, 'plant_id' => $tomato],
        ['id' => $next(), 'text_el' => 'Γενική συμβουλή.', 'text_en' => 'A general tip.', 'month_from' => null, 'month_to' => null, 'climate_zone_id' => null, 'plant_id' => null],
    ],
    'settlements' => [],
];

(new SnapshotWriter)->write($target, $tables, ['version' => '7', 'built_at' => $at]);

echo "wrote {$target}\n";
