<?php

namespace App\Modules\Catalogue\Enums;

/** ENT-Plant.sun */
enum Sun: string
{
    case FullSun = 'full_sun';
    case PartialShade = 'partial_shade';
    case Shade = 'shade';
}
