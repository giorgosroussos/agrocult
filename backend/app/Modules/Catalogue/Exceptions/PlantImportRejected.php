<?php

namespace App\Modules\Catalogue\Exceptions;

use DomainException;

/**
 * An import cannot write to the catalogue (e.g. the plant is not a draft, or a new plant has
 * no valid category). Nothing is written.
 */
class PlantImportRejected extends DomainException {}
