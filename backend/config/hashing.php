<?php

return [

    /*
    | Passwords are hashed with argon2id (SEC-001). The driver is fixed on
    | purpose; only the cost parameters come from the environment.
    */

    'driver' => 'argon2id',

    'argon' => [
        'memory' => (int) env('ARGON_MEMORY', 65536),
        'threads' => (int) env('ARGON_THREADS', 1),
        'time' => (int) env('ARGON_TIME', 4),
        'verify' => (bool) env('HASH_VERIFY', true),
    ],

    'rehash_on_login' => true,

];
