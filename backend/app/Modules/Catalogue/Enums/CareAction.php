<?php

namespace App\Modules\Catalogue\Enums;

/** ENT-CareInterval.action */
enum CareAction: string
{
    case Water = 'water';
    case Fertilise = 'fertilise';
    case Prune = 'prune';
    case Weed = 'weed';
    case Spray = 'spray';
    case Other = 'other';
}
