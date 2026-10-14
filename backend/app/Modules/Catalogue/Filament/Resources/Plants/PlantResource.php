<?php

namespace App\Modules\Catalogue\Filament\Resources\Plants;

use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Enums\TextLanguage;
use App\Modules\Catalogue\Filament\CatalogueOptions;
use App\Modules\Catalogue\Filament\Resources\Plants\Pages\CreatePlant;
use App\Modules\Catalogue\Filament\Resources\Plants\Pages\EditPlant;
use App\Modules\Catalogue\Filament\Resources\Plants\Pages\ListPlants;
use App\Modules\Catalogue\Filament\Resources\Plants\Schemas\PlantForm;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Models\PlantTranslation;
use BackedEnum;
use Filament\Actions\EditAction;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

/**
 * ENT-Plant curation (UC-010): all sections of a plant, review and publishing.
 */
class PlantResource extends Resource
{
    protected static ?string $model = Plant::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedSparkles;

    protected static ?int $navigationSort = 10;

    protected static ?string $recordTitleAttribute = 'scientific_name';

    public static function getModelLabel(): string
    {
        return __('catalogue::panel.plants.model_label');
    }

    public static function getPluralModelLabel(): string
    {
        return __('catalogue::panel.plants.plural_model_label');
    }

    public static function getNavigationGroup(): string
    {
        return __('catalogue::panel.navigation_group');
    }

    public static function form(Schema $schema): Schema
    {
        return PlantForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query) => $query->with(['category', 'translations']))
            ->columns([
                TextColumn::make('scientific_name')
                    ->label(__('catalogue::panel.plants.fields.scientific_name'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('name')
                    ->label(__('catalogue::panel.plants.fields.name'))
                    ->state(fn (Plant $record): ?string => self::localName($record)),
                TextColumn::make('category_id')
                    ->label(__('catalogue::panel.plants.fields.category'))
                    ->formatStateUsing(fn (Plant $record): string => $record->category instanceof PlantCategory
                        ? CatalogueOptions::localName($record->category->name_el, $record->category->name_en)
                        : ''),
                TextColumn::make('status')
                    ->label(__('catalogue::panel.plants.fields.status'))
                    ->badge()
                    ->formatStateUsing(fn (PlantStatus $state): string => self::statusLabel($state))
                    ->color(fn (PlantStatus $state): string => match ($state) {
                        PlantStatus::Draft => 'gray',
                        PlantStatus::InReview => 'warning',
                        PlantStatus::Published => 'success',
                        PlantStatus::Archived => 'danger',
                    }),
                TextColumn::make('updated_at')
                    ->label(__('catalogue::panel.plants.fields.updated_at'))
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('scientific_name')
            ->filters([
                SelectFilter::make('status')
                    ->label(__('catalogue::panel.plants.fields.status'))
                    ->options(CatalogueOptions::enum(PlantStatus::class, 'statuses')),
                SelectFilter::make('category_id')
                    ->label(__('catalogue::panel.plants.fields.category'))
                    ->relationship('category', 'code')
                    ->getOptionLabelFromRecordUsing(fn (PlantCategory $category): string => CatalogueOptions::localName($category->name_el, $category->name_en)),
            ])
            ->recordActions([
                EditAction::make(),
            ]);
    }

    public static function statusLabel(PlantStatus $status): string
    {
        return __('catalogue::panel.statuses.'.$status->value);
    }

    /**
     * The plant's name in the panel language, else in Greek.
     */
    private static function localName(Plant $plant): ?string
    {
        $names = $plant->translations->mapWithKeys(fn (PlantTranslation $translation): array => [$translation->lang->value => $translation->name]);

        return $names[app()->getLocale()] ?? $names[TextLanguage::El->value] ?? null;
    }

    public static function getPages(): array
    {
        return [
            'index' => ListPlants::route('/'),
            'create' => CreatePlant::route('/create'),
            'edit' => EditPlant::route('/{record}/edit'),
        ];
    }
}
