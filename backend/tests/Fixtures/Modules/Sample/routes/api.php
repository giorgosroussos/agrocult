<?php

use Illuminate\Support\Facades\Route;

Route::get('sample/ping', fn () => ['pong' => true])->name('sample.ping');
