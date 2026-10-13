<?php

use App\Modules\Identity\Http\Controllers\AuthController;
use App\Modules\Identity\Http\Controllers\EmailVerificationController;
use App\Modules\Identity\Http\Controllers\PasswordResetController;
use App\Modules\Identity\Http\Controllers\ProfileController;
use App\Modules\Identity\Http\Controllers\PushTokenController;
use Illuminate\Support\Facades\Route;

// Mounted under /api/v1 by the module provider.

Route::prefix('auth')->name('identity.')->group(function () {
    Route::middleware('throttle:identity-email')->group(function () {
        Route::post('sign-up', [AuthController::class, 'signUp'])->name('sign-up');
        Route::post('email/verification-notification', [EmailVerificationController::class, 'resend'])
            ->name('email.resend');
        Route::post('password/forgot', [PasswordResetController::class, 'forgot'])->name('password.forgot');
    });

    Route::get('email/verify/{user}/{hash}', [EmailVerificationController::class, 'verify'])
        ->whereUuid('user')
        ->middleware(['signed', 'throttle:identity-email'])
        ->name('email.verify');

    Route::post('sign-in', [AuthController::class, 'signIn'])
        ->middleware('throttle:identity-sign-in')
        ->name('sign-in');

    Route::post('password/reset', [PasswordResetController::class, 'reset'])
        ->middleware('throttle:identity-sign-in')
        ->name('password.reset');

    Route::post('sign-out', [AuthController::class, 'signOut'])
        ->middleware('auth:sanctum')
        ->name('sign-out');
});

Route::middleware('auth:sanctum')->prefix('me')->name('identity.me.')->group(function () {
    Route::get('/', [ProfileController::class, 'show'])->name('show');
    Route::patch('/', [ProfileController::class, 'update'])->name('update');

    Route::get('push-tokens', [PushTokenController::class, 'index'])->name('push-tokens.index');
    Route::post('push-tokens', [PushTokenController::class, 'store'])->name('push-tokens.store');
    Route::delete('push-tokens/{pushToken}', [PushTokenController::class, 'destroy'])
        ->whereUuid('pushToken')
        ->name('push-tokens.destroy');
});
