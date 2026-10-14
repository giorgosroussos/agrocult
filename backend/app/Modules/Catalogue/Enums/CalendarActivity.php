<?php

namespace App\Modules\Catalogue\Enums;

/** ENT-PlantCalendar.activity */
enum CalendarActivity: string
{
    case SowIndoors = 'sow_indoors';
    case SowOutdoors = 'sow_outdoors';
    case Transplant = 'transplant';
    case Harvest = 'harvest';
}
