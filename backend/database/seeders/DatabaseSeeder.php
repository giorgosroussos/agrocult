<?php

namespace Database\Seeders;

use App\Modules\Catalogue\Database\Seeders\CatalogueDemoSeeder;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database. Modules add their own seeders here.
     * Model events stay on: publishing demo plants queues the catalogue snapshot build.
     */
    public function run(): void
    {
        // Development-only demo catalogue (P2-T7); refuses to write in production.
        $this->call(CatalogueDemoSeeder::class);
    }
}
