<?php

namespace App\Modules\Catalogue\Filament\Resources\PlantCategories;

use App\Modules\Catalogue\Filament\CatalogueOptions;
use App\Modules\Catalogue\Filament\Resources\PlantCategories\Pages\CreatePlantCategory;
use App\Modules\Catalogue\Filament\Resources\PlantCategories\Pages\EditPlantCategory;
use App\Modules\Catalogue\Filament\Resources\PlantCategories\Pages\ListPlantCategories;
use App\Modules\Catalogue\Models\PlantCategory;
use BackedEnum;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

/**
 * ENT-PlantCategory: curator-managed categories with an optional parent (DATA-004).
 */
class PlantCategoryResource extends Resource
{
    protected static ?string $model = PlantCategory::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedTag;

    protected static ?int $navigationSort = 20;

    protected static ?string $recordTitleAttribute = 'code';

    public static function getModelLabel(): string
    {
        return __('catalogue::panel.categories.model_label');
    }

    public static function getPluralModelLabel(): string
    {
        return __('catalogue::panel.categories.plural_model_label');
    }

    public static function getNavigationGroup(): string
    {
        return __('catalogue::panel.navigation_group');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('code')
                ->label(__('catalogue::panel.categories.fields.code'))
                ->required()
                ->maxLength(255)
                ->alphaDash()
                ->unique(ignoreRecord: true),
            TextInput::make('name_el')
                ->label(__('catalogue::panel.categories.fields.name_el'))
                ->required()
                ->maxLength(255),
            TextInput::make('name_en')
                ->label(__('catalogue::panel.categories.fields.name_en'))
                ->required()
                ->maxLength(255),
            Select::make('parent_id')
                ->label(__('catalogue::panel.categories.fields.parent'))
                ->relationship(
                    'parent',
                    'code',
                    modifyQueryUsing: fn (Builder $query, ?Model $record) => $record === null
                        ? $query
                        : $query->whereKeyNot(self::selfAndDescendantIds($record)),
                )
                ->getOptionLabelFromRecordUsing(fn (PlantCategory $category): string => CatalogueOptions::localName($category->name_el, $category->name_en))
                ->searchable(['code', 'name_el', 'name_en'])
                ->preload()
                ->notIn(fn (?Model $record): array => $record === null ? [] : self::selfAndDescendantIds($record)),
            TextInput::make('sort_order')
                ->label(__('catalogue::panel.categories.fields.sort_order'))
                ->integer()
                ->minValue(0)
                ->maxValue(1_000_000)
                ->default(0),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('code')
                    ->label(__('catalogue::panel.categories.fields.code'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('name_el')
                    ->label(__('catalogue::panel.categories.fields.name_el'))
                    ->searchable(),
                TextColumn::make('name_en')
                    ->label(__('catalogue::panel.categories.fields.name_en'))
                    ->searchable(),
                TextColumn::make('parent.code')
                    ->label(__('catalogue::panel.categories.fields.parent')),
                TextColumn::make('plants_count')
                    ->label(__('catalogue::panel.categories.fields.plants_count'))
                    ->counts('plants'),
                TextColumn::make('sort_order')
                    ->label(__('catalogue::panel.categories.fields.sort_order'))
                    ->sortable(),
            ])
            ->defaultSort('sort_order')
            ->recordActions([
                EditAction::make(),
            ]);
    }

    /**
     * A category cannot become its own parent or the child of one of its sub-categories.
     *
     * @return list<string>
     */
    public static function selfAndDescendantIds(Model $record): array
    {
        $ids = [(string) $record->getKey()];
        $frontier = $ids;

        while ($frontier !== []) {
            $frontier = PlantCategory::query()
                ->whereIn('parent_id', $frontier)
                ->whereKeyNot($ids)
                ->pluck('id')
                ->map(fn ($id): string => (string) $id)
                ->all();
            $ids = [...$ids, ...$frontier];
        }

        return $ids;
    }

    public static function getPages(): array
    {
        return [
            'index' => ListPlantCategories::route('/'),
            'create' => CreatePlantCategory::route('/create'),
            'edit' => EditPlantCategory::route('/{record}/edit'),
        ];
    }
}
