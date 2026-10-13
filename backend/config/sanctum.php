<?php

return [

    /*
    | The API is used only by the mobile app with bearer tokens (one token
    | per device, SEC-001). There is no stateful (cookie) authentication.
    */

    'stateful' => [],

    'guard' => [],

    'expiration' => env('SANCTUM_TOKEN_EXPIRATION'),

    'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),

    'middleware' => [],

];
