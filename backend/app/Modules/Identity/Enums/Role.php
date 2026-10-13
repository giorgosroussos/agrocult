<?php

namespace App\Modules\Identity\Enums;

enum Role: string
{
    case Gardener = 'gardener';
    case Curator = 'curator';
    case Admin = 'admin';
}
