<?php

namespace App\Modules\Weather\Exceptions;

use RuntimeException;

/**
 * The weather service (EXT-002) failed, timed out or returned an unusable answer.
 *
 * The message names only the operation and the reason; it never carries the request URL or
 * coordinates, and the HTTP client exception is not chained, so nothing personal reaches the
 * logs (SEC-002).
 */
class WeatherUnavailable extends RuntimeException
{
    public static function because(string $operation, string $reason): self
    {
        return new self("Weather service unavailable during {$operation}: {$reason}");
    }
}
