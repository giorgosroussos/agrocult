<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * CMP-Catalogue entities (design/model/data.yaml) and the audit trail on plants.
 * Enum attributes are stored as strings; the model casts hold the allowed values.
 */
return new class extends Migration
{
    public function up(): void
    {
        // ENT-PlantCategory (DATA-004: curator-managed, never hard-coded).
        Schema::create('plant_categories', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 255)->unique();
            $table->string('name_el', 255);
            $table->string('name_en', 255);
            $table->uuid('parent_id')->nullable()->index();
            $table->integer('sort_order')->nullable();
        });

        // Self reference, added once the primary key exists.
        Schema::table('plant_categories', function (Blueprint $table) {
            $table->foreign('parent_id')->references('id')->on('plant_categories')->restrictOnDelete();
        });

        // ENT-ClimateZone (DATA-001).
        Schema::create('climate_zones', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 255)->unique();
            $table->string('name_el', 255);
            $table->string('name_en', 255);
            $table->text('description')->nullable();
            $table->jsonb('rules');
        });

        // ENT-Plant.
        Schema::create('plants', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('scientific_name', 255)->unique();
            $table->integer('gbif_id')->nullable()->unique();
            $table->foreignUuid('category_id')->constrained('plant_categories')->restrictOnDelete();
            $table->decimal('temp_min_c', 4, 1)->nullable();
            $table->decimal('temp_opt_c', 4, 1)->nullable();
            $table->decimal('temp_max_c', 4, 1)->nullable();
            $table->integer('water_need')->nullable();
            $table->string('sun')->nullable();
            $table->jsonb('soil_types')->nullable();
            $table->decimal('ph_min', 3, 1)->nullable();
            $table->decimal('ph_max', 3, 1)->nullable();
            $table->string('frost_hardiness')->nullable();
            $table->jsonb('propagation')->nullable();
            $table->decimal('sow_depth_cm', 5, 1)->nullable();
            $table->integer('spacing_cm')->nullable();
            $table->integer('row_spacing_cm')->nullable();
            $table->integer('days_to_harvest')->nullable();
            $table->string('status')->default('draft')->index();
            $table->foreignUuid('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestampTz('reviewed_at')->nullable();
            $table->timestampTz('published_at')->nullable();
            $table->timestampTz('updated_at')->nullable();
        });

        // ENT-PlantTranslation: one row per language.
        Schema::create('plant_translations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('plant_id')->constrained('plants')->cascadeOnDelete();
            $table->string('lang');
            $table->string('name', 255);
            $table->text('description')->nullable();
            $table->text('planting')->nullable();
            $table->text('care')->nullable();
            $table->text('seed_saving')->nullable();
            $table->text('tips')->nullable();
            $table->unique(['plant_id', 'lang']);
        });

        // ENT-PlantAlias.
        Schema::create('plant_aliases', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('plant_id')->constrained('plants')->cascadeOnDelete();
            $table->string('lang')->nullable();
            $table->string('alias', 255);
            $table->string('kind')->nullable();
            $table->index('plant_id');
        });

        // ENT-PlantCalendar.
        Schema::create('plant_calendars', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('plant_id')->constrained('plants')->cascadeOnDelete();
            $table->foreignUuid('climate_zone_id')->constrained('climate_zones')->restrictOnDelete();
            $table->string('activity');
            $table->integer('month_from');
            $table->integer('month_to');
            $table->index(['plant_id', 'climate_zone_id']);
        });

        // ENT-Companion.
        Schema::create('companions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('plant_id')->constrained('plants')->cascadeOnDelete();
            $table->foreignUuid('other_plant_id')->constrained('plants')->cascadeOnDelete();
            $table->string('relation');
            $table->unique(['plant_id', 'other_plant_id']);
        });

        // ENT-CareInterval (DEC-004).
        Schema::create('care_intervals', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('plant_id')->constrained('plants')->cascadeOnDelete();
            $table->string('action');
            $table->integer('interval_days');
            $table->integer('month_from')->nullable();
            $table->integer('month_to')->nullable();
            $table->index('plant_id');
        });

        // ENT-PlantPhoto: file_path is a path on the Laravel filesystem.
        Schema::create('plant_photos', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('plant_id')->constrained('plants')->cascadeOnDelete();
            $table->string('file_path', 255);
            $table->string('credit', 255);
            $table->string('licence', 255);
            $table->string('source_url', 2048)->nullable();
            $table->index('plant_id');
        });

        // ENT-FactSource (SCOPE-001).
        Schema::create('fact_sources', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('plant_id')->constrained('plants')->cascadeOnDelete();
            $table->string('field', 255);
            $table->string('source_name', 255);
            $table->string('source_url', 2048)->nullable();
            $table->string('licence', 255);
            $table->timestampTz('imported_at')->nullable();
            $table->index('plant_id');
        });

        // ENT-Tip.
        Schema::create('tips', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->text('text_el');
            $table->text('text_en');
            $table->integer('month_from')->nullable();
            $table->integer('month_to')->nullable();
            $table->foreignUuid('climate_zone_id')->nullable()->constrained('climate_zones')->restrictOnDelete();
            $table->foreignUuid('plant_id')->nullable()->constrained('plants')->cascadeOnDelete();
            $table->string('status')->nullable()->default('draft')->index();
        });

        // ENT-Settlement.
        Schema::create('settlements', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name_el', 255);
            $table->string('name_en', 255)->nullable();
            $table->string('region', 255)->nullable();
            $table->decimal('lat', 9, 6);
            $table->decimal('lon', 9, 6);
        });

        // Audit trail on catalogue plant changes (ENT-Plant audit: true, DATA-006).
        // Kept when the plant is deleted, so plant_id has no foreign key.
        Schema::create('plant_audits', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('plant_id')->index();
            $table->foreignUuid('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('event');
            $table->jsonb('changes');
            $table->timestampTz('created_at');
        });

        // Value ranges from the data model (months 1-12, water need 1-5).
        $checks = [
            'plants' => ['plants_water_need_range' => 'water_need IS NULL OR water_need BETWEEN 1 AND 5'],
            'plant_calendars' => ['plant_calendars_months_range' => 'month_from BETWEEN 1 AND 12 AND month_to BETWEEN 1 AND 12'],
            'care_intervals' => [
                'care_intervals_months_range' => '(month_from IS NULL OR month_from BETWEEN 1 AND 12) AND (month_to IS NULL OR month_to BETWEEN 1 AND 12)',
                'care_intervals_interval_positive' => 'interval_days > 0',
            ],
            'tips' => ['tips_months_range' => '(month_from IS NULL OR month_from BETWEEN 1 AND 12) AND (month_to IS NULL OR month_to BETWEEN 1 AND 12)'],
            'companions' => ['companions_distinct_plants' => 'plant_id <> other_plant_id'],
        ];

        foreach ($checks as $table => $constraints) {
            foreach ($constraints as $name => $condition) {
                DB::statement("ALTER TABLE {$table} ADD CONSTRAINT {$name} CHECK ({$condition})");
            }
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('plant_audits');
        Schema::dropIfExists('settlements');
        Schema::dropIfExists('tips');
        Schema::dropIfExists('fact_sources');
        Schema::dropIfExists('plant_photos');
        Schema::dropIfExists('care_intervals');
        Schema::dropIfExists('companions');
        Schema::dropIfExists('plant_calendars');
        Schema::dropIfExists('plant_aliases');
        Schema::dropIfExists('plant_translations');
        Schema::dropIfExists('plants');
        Schema::dropIfExists('climate_zones');
        Schema::dropIfExists('plant_categories');
    }
};
