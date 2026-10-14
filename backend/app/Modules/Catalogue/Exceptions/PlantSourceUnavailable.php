<?php

namespace App\Modules\Catalogue\Exceptions;

use App\Modules\Catalogue\Import\PlantSource;
use RuntimeException;

/**
 * An open plant data source (EXT-006) is not configured, timed out, could not be reached or
 * answered with an error. The message never contains request URLs, so no token can leak.
 */
class PlantSourceUnavailable extends RuntimeException
{
    public function __construct(public readonly PlantSource $source, string $reason)
    {
        parent::__construct("{$source->displayName()} is unavailable: {$reason}");
    }
}
