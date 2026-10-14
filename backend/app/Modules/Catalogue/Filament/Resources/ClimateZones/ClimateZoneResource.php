<?php

namespace App\Modules\Catalogue\Filament\Resources\ClimateZones;

use App\Modules\Catalogue\Filament\Resources\ClimateZones\Pages\CreateClimateZone;
use App\Modules\Catalogue\Filament\Resources\ClimateZones\Pages\EditClimateZone;
use App\Modules\Catalogue\Filament\Resources\ClimateZones\Pages\ListClimateZones;
use App\Modules\Catalogue\Models\ClimateZone;
use BackedEnum;
use Closure;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

/**
 * ENT-ClimateZone: the named climate zones of Greece and their rules (DATA-001).
 */
class ClimateZoneResource extends Resource
{
    protected static ?string $model = ClimateZone::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedGlobeEuropeAfrica;

    protected static ?int $navigationSort = 30;

    protected static ?string $recordTitleAttribute = 'code';

    public static function getModelLabel(): string
    {
        return __('catalogue::panel.climate_zones.model_label');
    }

    public static function getPluralModelLabel(): string
    {
        return __('catalogue::panel.climate_zones.plural_model_label');
    }

    public static function getNavigationGroup(): string
    {
        return __('catalogue::panel.navigation_group');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('code')
                ->label(__('catalogue::panel.climate_zones.fields.code'))
                ->required()
                ->maxLength(255)
                ->alphaDash()
                ->unique(ignoreRecord: true),
            TextInput::make('name_el')
                ->label(__('catalogue::panel.climate_zones.fields.name_el'))
                ->required()
                ->maxLength(255),
            TextInput::make('name_en')
                ->label(__('catalogue::panel.climate_zones.fields.name_en'))
                ->required()
                ->maxLength(255),
            Textarea::make('description')
                ->label(__('catalogue::panel.climate_zones.fields.description'))
                ->rows(3)
                ->columnSpanFull(),
            Textarea::make('rules')
                ->label(__('catalogue::panel.climate_zones.fields.rules'))
                ->required()
                ->rows(8)
                ->default('{}')
                ->formatStateUsing(fn (mixed $state): string => is_array($state)
                    ? (string) json_encode((object) $state, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)
                    : (string) ($state ?? '{}'))
                ->rule(fn (): Closure => function (string $attribute, mixed $value, Closure $fail): void {
                    if (! self::isJsonObject($value)) {
                        $fail(__('catalogue::panel.climate_zones.invalid_rules'));
                    }
                })
                ->dehydrateStateUsing(fn (mixed $state): array => (array) json_decode((string) $state, true))
                ->columnSpanFull(),
        ]);
    }

    public static function isJsonObject(mixed $value): bool
    {
        if (! is_string($value) || ! json_validate($value)) {
            return false;
        }

        return str_starts_with(ltrim($value), '{');
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('code')
                    ->label(__('catalogue::panel.climate_zones.fields.code'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('name_el')
                    ->label(__('catalogue::panel.climate_zones.fields.name_el'))
                    ->searchable(),
                TextColumn::make('name_en')
                    ->label(__('catalogue::panel.climate_zones.fields.name_en'))
                    ->searchable(),
            ])
            ->defaultSort('code')
            ->recordActions([
                EditAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListClimateZones::route('/'),
            'create' => CreateClimateZone::route('/create'),
            'edit' => EditClimateZone::route('/{record}/edit'),
        ];
    }
}
