<?php

use Illuminate\Support\Facades\DB;

it('answers the health check on /up with 200', function () {
    $this->get('/up')->assertOk();
});

it('reaches PostgreSQL 18', function () {
    expect(DB::connection()->getDriverName())->toBe('pgsql');

    $version = (string) DB::selectOne('show server_version')->server_version;

    expect((int) explode('.', $version)[0])->toBe(18);
});
