<?php

namespace App\Modules\Catalogue\Filament;

use BackedEnum;
use Carbon\CarbonImmutable;
use Filament\Forms\Components\Select;

/**
 * Translated select options shared by the catalogue resources.
 */
class CatalogueOptions
{
    /**
     * @param  class-string<BackedEnum>  $enum
     * @return array<string, string>
     */
    public static function enum(string $enum, string $translationGroup): array
    {
        $options = [];

        foreach ($enum::cases() as $case) {
            $options[(string) $case->value] = (string) __("catalogue::panel.{$translationGroup}.{$case->value}");
        }

        return $options;
    }

    /**
     * @return array<int, string>
     */
    public static function months(): array
    {
        $months = [];

        foreach (range(1, 12) as $month) {
            $months[$month] = CarbonImmutable::create(2000, $month, 1)
                ->locale(app()->getLocale())
                ->isoFormat('MMMM');
        }

        return $months;
    }

    public static function monthSelect(string $name, string $label): Select
    {
        return Select::make($name)
            ->label($label)
            ->options(self::months())
            ->in(range(1, 12));
    }

    /**
     * The Greek or English name of a record with name_el and name_en, following the panel language.
     */
    public static function localName(?string $nameEl, ?string $nameEn): string
    {
        return (string) (app()->getLocale() === 'el' ? ($nameEl ?: $nameEn) : ($nameEn ?: $nameEl));
    }
}
