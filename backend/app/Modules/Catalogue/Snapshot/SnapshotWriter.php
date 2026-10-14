<?php

namespace App\Modules\Catalogue\Snapshot;

use PDO;
use PDOStatement;
use RuntimeException;

/**
 * Writes an exported catalogue into a new SQLite database file (the snapshot shipped to devices).
 *
 * The schema is the contract with the app's local catalogue (CMP-AppCatalogue): plain tables
 * mirroring the published catalogue plus two FTS5 tables over the precomputed search keys.
 * PRAGMA user_version and meta.schema_version carry SCHEMA_VERSION; it changes only when
 * the schema changes incompatibly.
 */
class SnapshotWriter
{
    public const SCHEMA_VERSION = 1;

    private const SCHEMA = [
        'CREATE TABLE meta (key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL)',
        'CREATE TABLE categories (id TEXT PRIMARY KEY NOT NULL, code TEXT NOT NULL UNIQUE, name_el TEXT NOT NULL, '
            .'name_en TEXT NOT NULL, parent_id TEXT, sort_order INTEGER)',
        'CREATE TABLE climate_zones (id TEXT PRIMARY KEY NOT NULL, code TEXT NOT NULL UNIQUE, name_el TEXT NOT NULL, '
            .'name_en TEXT NOT NULL, description TEXT, rules TEXT NOT NULL)',
        'CREATE TABLE plants (id TEXT PRIMARY KEY NOT NULL, scientific_name TEXT NOT NULL UNIQUE, gbif_id INTEGER, '
            .'category_id TEXT NOT NULL, temp_min_c REAL, temp_opt_c REAL, temp_max_c REAL, water_need INTEGER, '
            .'sun TEXT, soil_types TEXT, ph_min REAL, ph_max REAL, frost_hardiness TEXT, propagation TEXT, '
            .'sow_depth_cm REAL, spacing_cm INTEGER, row_spacing_cm INTEGER, days_to_harvest INTEGER, '
            .'published_at TEXT, updated_at TEXT, search_keys TEXT NOT NULL)',
        'CREATE INDEX plants_category_id ON plants (category_id)',
        'CREATE TABLE plant_translations (id TEXT PRIMARY KEY NOT NULL, plant_id TEXT NOT NULL, lang TEXT NOT NULL, '
            .'name TEXT NOT NULL, description TEXT, planting TEXT, care TEXT, seed_saving TEXT, tips TEXT, '
            .'UNIQUE (plant_id, lang))',
        'CREATE TABLE plant_aliases (id TEXT PRIMARY KEY NOT NULL, plant_id TEXT NOT NULL, lang TEXT, '
            .'alias TEXT NOT NULL, kind TEXT)',
        'CREATE INDEX plant_aliases_plant_id ON plant_aliases (plant_id)',
        'CREATE TABLE plant_calendars (id TEXT PRIMARY KEY NOT NULL, plant_id TEXT NOT NULL, '
            .'climate_zone_id TEXT NOT NULL, activity TEXT NOT NULL, month_from INTEGER NOT NULL, month_to INTEGER NOT NULL)',
        'CREATE INDEX plant_calendars_zone ON plant_calendars (climate_zone_id, activity)',
        'CREATE INDEX plant_calendars_plant_id ON plant_calendars (plant_id)',
        'CREATE TABLE companions (id TEXT PRIMARY KEY NOT NULL, plant_id TEXT NOT NULL, other_plant_id TEXT NOT NULL, '
            .'relation TEXT NOT NULL)',
        'CREATE INDEX companions_plant_id ON companions (plant_id)',
        'CREATE TABLE care_intervals (id TEXT PRIMARY KEY NOT NULL, plant_id TEXT NOT NULL, action TEXT NOT NULL, '
            .'interval_days INTEGER NOT NULL, month_from INTEGER, month_to INTEGER)',
        'CREATE INDEX care_intervals_plant_id ON care_intervals (plant_id)',
        'CREATE TABLE plant_photos (id TEXT PRIMARY KEY NOT NULL, plant_id TEXT NOT NULL, credit TEXT NOT NULL, '
            .'licence TEXT NOT NULL, source_url TEXT)',
        'CREATE INDEX plant_photos_plant_id ON plant_photos (plant_id)',
        'CREATE TABLE fact_sources (id TEXT PRIMARY KEY NOT NULL, plant_id TEXT NOT NULL, field TEXT NOT NULL, '
            .'source_name TEXT NOT NULL, source_url TEXT, licence TEXT NOT NULL, imported_at TEXT)',
        'CREATE INDEX fact_sources_plant_id ON fact_sources (plant_id)',
        'CREATE TABLE tips (id TEXT PRIMARY KEY NOT NULL, text_el TEXT NOT NULL, text_en TEXT NOT NULL, '
            .'month_from INTEGER, month_to INTEGER, climate_zone_id TEXT, plant_id TEXT)',
        'CREATE TABLE settlements (id TEXT PRIMARY KEY NOT NULL, name_el TEXT NOT NULL, name_en TEXT, region TEXT, '
            .'lat REAL NOT NULL, lon REAL NOT NULL, search_keys TEXT NOT NULL)',
        "CREATE VIRTUAL TABLE plant_search USING fts5(plant_id UNINDEXED, search_keys, tokenize = 'unicode61 remove_diacritics 2')",
        "CREATE VIRTUAL TABLE settlement_search USING fts5(settlement_id UNINDEXED, search_keys, tokenize = 'unicode61 remove_diacritics 2')",
    ];

    /** @var array<string, PDOStatement> prepared inserts of the snapshot being written */
    private array $statements = [];

    /**
     * @param  array<string, list<array<string, mixed>>>  $tables  table name => rows (from SnapshotExporter)
     * @param  array<string, string>  $meta
     */
    public function write(string $path, array $tables, array $meta): void
    {
        if (file_exists($path) && filesize($path) > 0) {
            throw new RuntimeException('The snapshot file must be new.');
        }

        $db = new PDO('sqlite:'.$path, options: [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

        try {
            $db->exec('PRAGMA journal_mode = DELETE');
            $db->beginTransaction();

            foreach (self::SCHEMA as $statement) {
                $db->exec($statement);
            }

            $meta = ['schema_version' => (string) self::SCHEMA_VERSION, 'search_query_rules' => SearchKeys::QUERY_RULES] + $meta;
            foreach ($meta as $key => $value) {
                $this->insert($db, 'meta', ['key' => $key, 'value' => $value]);
            }

            foreach ($tables as $table => $rows) {
                foreach ($rows as $row) {
                    $this->insert($db, $table, $row);
                }
            }

            foreach ($tables['plants'] ?? [] as $plant) {
                $this->insert($db, 'plant_search', ['plant_id' => $plant['id'], 'search_keys' => $plant['search_keys']]);
            }

            foreach ($tables['settlements'] ?? [] as $settlement) {
                $this->insert($db, 'settlement_search', [
                    'settlement_id' => $settlement['id'],
                    'search_keys' => $settlement['search_keys'],
                ]);
            }

            $this->statements = [];
            $db->commit();
            $db->exec('PRAGMA user_version = '.self::SCHEMA_VERSION);
            $db->exec('VACUUM');
        } finally {
            $this->statements = [];
            unset($db);
        }
    }

    /**
     * @param  array<string, mixed>  $row
     */
    private function insert(PDO $db, string $table, array $row): void
    {
        $columns = array_keys($row);
        $key = $table.'|'.implode(',', $columns);

        $this->statements[$key] ??= $db->prepare(sprintf(
            'INSERT INTO %s (%s) VALUES (%s)',
            $table,
            implode(', ', $columns),
            implode(', ', array_fill(0, count($columns), '?')),
        ));

        $this->statements[$key]->execute(array_values($row));
    }
}
