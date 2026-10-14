<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ENT-WeatherCell: grid cell of about 10 km; climate metrics computed once (DATA-009).
        // The metrics and the zone stay null until the provider answered (INT-002).
        Schema::create('weather_cells', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->decimal('lat', 7, 4);
            $table->decimal('lon', 7, 4);
            $table->integer('elevation_m')->nullable();
            $table->decimal('winter_min_mean_c', 5, 2)->nullable();
            $table->integer('last_frost_doy')->nullable();
            $table->integer('first_frost_doy')->nullable();
            // A deleted zone leaves the cell without one until the re-assignment that follows.
            $table->foreignUuid('climate_zone_id')->nullable()->constrained('climate_zones')->nullOnDelete();
            $table->unique(['lat', 'lon']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('weather_cells');
    }
};
