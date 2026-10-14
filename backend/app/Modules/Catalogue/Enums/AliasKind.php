<?php

namespace App\Modules\Catalogue\Enums;

/** ENT-PlantAlias.kind */
enum AliasKind: string
{
    case Synonym = 'synonym';
    case LocalName = 'local_name';
    case Greeklish = 'greeklish';
}
