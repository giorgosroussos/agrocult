<?php

namespace App\Modules\Catalogue\Enums;

/** ENT-Plant.frost_hardiness; tender plants trigger frost alerts. */
enum FrostHardiness: string
{
    case Tender = 'tender';
    case HalfHardy = 'half_hardy';
    case Hardy = 'hardy';
}
