<?php

namespace App\Modules\Catalogue\Filament\Resources\Tips;

use App\Modules\Catalogue\Enums\TipStatus;
use App\Modules\Catalogue\Filament\CatalogueOptions;
use App\Modules\Catalogue\Filament\Resources\Tips\Pages\CreateTip;
use App\Modules\Catalogue\Filament\Resources\Tips\Pages\EditTip;
use App\Modules\Catalogue\Filament\Resources\Tips\Pages\ListTips;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Tip;
use BackedEnum;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

/**
 * ENT-Tip: short tips for the home screen; only published tips go to devices (ARCH-003).
 */
class TipResource extends Resource
{
    protected static ?string $model = Tip::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedLightBulb;

    protected static ?int $navigationSort = 40;

    public static function getModelLabel(): string
    {
        return __('catalogue::panel.tips.model_label');
    }

    public static function getPluralModelLabel(): string
    {
        return __('catalogue::panel.tips.plural_model_label');
    }

    public static function getNavigationGroup(): string
    {
        return __('catalogue::panel.navigation_group');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Textarea::make('text_el')
                ->label(__('catalogue::panel.tips.fields.text_el'))
                ->required()
                ->rows(3)
                ->columnSpanFull(),
            Textarea::make('text_en')
                ->label(__('catalogue::panel.tips.fields.text_en'))
                ->required()
                ->rows(3)
                ->columnSpanFull(),
            CatalogueOptions::monthSelect('month_from', __('catalogue::panel.tips.fields.month_from')),
            CatalogueOptions::monthSelect('month_to', __('catalogue::panel.tips.fields.month_to')),
            Select::make('climate_zone_id')
                ->label(__('catalogue::panel.tips.fields.climate_zone'))
                ->relationship('climateZone', 'code')
                ->getOptionLabelFromRecordUsing(fn (ClimateZone $zone): string => CatalogueOptions::localName($zone->name_el, $zone->name_en))
                ->preload(),
            Select::make('plant_id')
                ->label(__('catalogue::panel.tips.fields.plant'))
                ->relationship('plant', 'scientific_name')
                ->searchable(),
            Select::make('status')
                ->label(__('catalogue::panel.tips.fields.status'))
                ->options(CatalogueOptions::enum(TipStatus::class, 'tip_statuses'))
                ->required()
                ->default(TipStatus::Draft->value),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('text_el')
                    ->label(__('catalogue::panel.tips.fields.text_el'))
                    ->limit(60)
                    ->searchable(),
                TextColumn::make('text_en')
                    ->label(__('catalogue::panel.tips.fields.text_en'))
                    ->limit(60)
                    ->searchable(),
                TextColumn::make('climateZone.code')
                    ->label(__('catalogue::panel.tips.fields.climate_zone')),
                TextColumn::make('plant.scientific_name')
                    ->label(__('catalogue::panel.tips.fields.plant')),
                TextColumn::make('status')
                    ->label(__('catalogue::panel.tips.fields.status'))
                    ->badge()
                    ->formatStateUsing(fn (TipStatus $state): string => __('catalogue::panel.tip_statuses.'.$state->value))
                    ->color(fn (TipStatus $state): string => $state === TipStatus::Published ? 'success' : 'gray'),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label(__('catalogue::panel.tips.fields.status'))
                    ->options(CatalogueOptions::enum(TipStatus::class, 'tip_statuses')),
            ])
            ->recordActions([
                EditAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListTips::route('/'),
            'create' => CreateTip::route('/create'),
            'edit' => EditTip::route('/{record}/edit'),
        ];
    }
}
