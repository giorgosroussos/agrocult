<?php

use App\Modules\Catalogue\Http\Controllers\CatalogueSnapshotController;
use Illuminate\Support\Facades\Route;

// Mounted under /api/v1 by the module provider. Public: the catalogue needs no account (SCOPE-002).

Route::prefix('catalogue')->name('catalogue.')->group(function () {
    Route::get('version', [CatalogueSnapshotController::class, 'version'])->name('version');
    Route::get('snapshots/{version}', [CatalogueSnapshotController::class, 'download'])
        ->whereNumber('version')
        ->name('snapshots.show');
});
