<?php

namespace App\Modules\Catalogue\Enums;

/** ENT-Tip.status; only published tips go into the catalogue snapshot (ARCH-003). */
enum TipStatus: string
{
    case Draft = 'draft';
    case Published = 'published';
}
