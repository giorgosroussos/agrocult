<?php

namespace App\Modules\Catalogue\Filament\Resources\Plants\Schemas;

use App\Modules\Catalogue\Enums\AliasKind;
use App\Modules\Catalogue\Enums\CalendarActivity;
use App\Modules\Catalogue\Enums\CareAction;
use App\Modules\Catalogue\Enums\CompanionRelation;
use App\Modules\Catalogue\Enums\FrostHardiness;
use App\Modules\Catalogue\Enums\Sun;
use App\Modules\Catalogue\Enums\TextLanguage;
use App\Modules\Catalogue\Filament\CatalogueOptions;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Services\CataloguePhotoStore;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;
use Filament\Schemas\Schema;
use Illuminate\Database\Eloquent\Builder;
use Livewire\Features\SupportFileUploads\TemporaryUploadedFile;

/**
 * The plant form with all sections (UC-010): structured fields, texts per language,
 * aliases, calendar per climate zone, companions, care intervals, photos with credit and
 * licence, and the source and licence of imported facts (SCOPE-001).
 *
 * The status is not part of the form; it changes only through the status actions.
 */
class PlantForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema->components([
            Tabs::make('plant')
                ->persistTabInQueryString()
                ->columnSpanFull()
                ->tabs([
                    Tab::make('structure')
                        ->label(__('catalogue::panel.plants.tabs.structure'))
                        ->schema(self::structuredFields()),
                    Tab::make('texts')
                        ->label(__('catalogue::panel.plants.tabs.texts'))
                        ->schema([self::translations()]),
                    Tab::make('aliases')
                        ->label(__('catalogue::panel.plants.tabs.aliases'))
                        ->schema([self::aliases()]),
                    Tab::make('calendar')
                        ->label(__('catalogue::panel.plants.tabs.calendar'))
                        ->schema([self::calendars()]),
                    Tab::make('companions')
                        ->label(__('catalogue::panel.plants.tabs.companions'))
                        ->schema([self::companions()]),
                    Tab::make('care')
                        ->label(__('catalogue::panel.plants.tabs.care'))
                        ->schema([self::careIntervals()]),
                    Tab::make('photos')
                        ->label(__('catalogue::panel.plants.tabs.photos'))
                        ->schema([self::photos()]),
                    Tab::make('sources')
                        ->label(__('catalogue::panel.plants.tabs.sources'))
                        ->schema([self::factSources()]),
                ]),
        ]);
    }

    /**
     * @return list<mixed>
     */
    private static function structuredFields(): array
    {
        return [
            Grid::make(2)->schema([
                TextInput::make('scientific_name')
                    ->label(__('catalogue::panel.plants.fields.scientific_name'))
                    ->required()
                    ->maxLength(255)
                    ->unique(ignoreRecord: true),
                Select::make('category_id')
                    ->label(__('catalogue::panel.plants.fields.category'))
                    ->relationship('category', 'code')
                    ->getOptionLabelFromRecordUsing(fn (PlantCategory $category): string => CatalogueOptions::localName($category->name_el, $category->name_en))
                    ->searchable(['code', 'name_el', 'name_en'])
                    ->preload()
                    ->required(),
                TextInput::make('gbif_id')
                    ->label(__('catalogue::panel.plants.fields.gbif_id'))
                    ->integer()
                    ->minValue(1)
                    ->maxValue(2_147_483_647)
                    ->unique(ignoreRecord: true),
            ]),
            Grid::make(3)->schema([
                self::decimal('temp_min_c', -99.9, 99.9),
                self::decimal('temp_opt_c', -99.9, 99.9),
                self::decimal('temp_max_c', -99.9, 99.9),
                Select::make('water_need')
                    ->label(__('catalogue::panel.plants.fields.water_need'))
                    ->options(array_combine(range(1, 5), array_map('strval', range(1, 5))))
                    ->in(range(1, 5)),
                Select::make('sun')
                    ->label(__('catalogue::panel.plants.fields.sun'))
                    ->options(CatalogueOptions::enum(Sun::class, 'sun')),
                Select::make('frost_hardiness')
                    ->label(__('catalogue::panel.plants.fields.frost_hardiness'))
                    ->options(CatalogueOptions::enum(FrostHardiness::class, 'frost_hardiness')),
                self::decimal('ph_min', 0, 14),
                self::decimal('ph_max', 0, 14),
                self::decimal('sow_depth_cm', 0, 9999.9),
                TextInput::make('spacing_cm')
                    ->label(__('catalogue::panel.plants.fields.spacing_cm'))
                    ->integer()
                    ->minValue(0)
                    ->maxValue(100_000),
                TextInput::make('row_spacing_cm')
                    ->label(__('catalogue::panel.plants.fields.row_spacing_cm'))
                    ->integer()
                    ->minValue(0)
                    ->maxValue(100_000),
                TextInput::make('days_to_harvest')
                    ->label(__('catalogue::panel.plants.fields.days_to_harvest'))
                    ->integer()
                    ->minValue(0)
                    ->maxValue(100_000),
            ]),
            Grid::make(2)->schema([
                TagsInput::make('soil_types')
                    ->label(__('catalogue::panel.plants.fields.soil_types')),
                TagsInput::make('propagation')
                    ->label(__('catalogue::panel.plants.fields.propagation')),
            ]),
        ];
    }

    private static function decimal(string $name, float $min, float $max): TextInput
    {
        return TextInput::make($name)
            ->label(__("catalogue::panel.plants.fields.{$name}"))
            ->numeric()
            ->step(0.1)
            ->minValue($min)
            ->maxValue($max);
    }

    private static function translations(): Repeater
    {
        return Repeater::make('translations')
            ->hiddenLabel()
            ->relationship()
            ->itemLabel(fn (array $state): ?string => isset($state['lang']) && is_string($state['lang']) && $state['lang'] !== ''
                ? __('catalogue::panel.languages.'.$state['lang'])
                : null)
            ->addActionLabel(__('catalogue::panel.plants.translation.item'))
            ->maxItems(count(TextLanguage::cases()))
            ->defaultItems(0)
            ->schema([
                Grid::make(2)->schema([
                    Select::make('lang')
                        ->label(__('catalogue::panel.plants.translation.lang'))
                        ->options(CatalogueOptions::enum(TextLanguage::class, 'languages'))
                        ->required()
                        ->distinct(),
                    TextInput::make('name')
                        ->label(__('catalogue::panel.plants.translation.name'))
                        ->required()
                        ->maxLength(255),
                ]),
                Textarea::make('description')->label(__('catalogue::panel.plants.translation.description'))->rows(3),
                Textarea::make('planting')->label(__('catalogue::panel.plants.translation.planting'))->rows(3),
                Textarea::make('care')->label(__('catalogue::panel.plants.translation.care'))->rows(3),
                Textarea::make('seed_saving')->label(__('catalogue::panel.plants.translation.seed_saving'))->rows(3),
                Textarea::make('tips')->label(__('catalogue::panel.plants.translation.tips'))->rows(3),
            ]);
    }

    private static function aliases(): Repeater
    {
        return Repeater::make('aliases')
            ->hiddenLabel()
            ->relationship()
            ->addActionLabel(__('catalogue::panel.plants.alias.item'))
            ->defaultItems(0)
            ->columns(3)
            ->schema([
                TextInput::make('alias')
                    ->label(__('catalogue::panel.plants.alias.alias'))
                    ->required()
                    ->maxLength(255),
                Select::make('lang')
                    ->label(__('catalogue::panel.plants.alias.lang'))
                    ->options(CatalogueOptions::enum(TextLanguage::class, 'languages')),
                Select::make('kind')
                    ->label(__('catalogue::panel.plants.alias.kind'))
                    ->options(CatalogueOptions::enum(AliasKind::class, 'alias_kinds')),
            ]);
    }

    private static function calendars(): Repeater
    {
        return Repeater::make('calendars')
            ->hiddenLabel()
            ->relationship()
            ->addActionLabel(__('catalogue::panel.plants.calendar.item'))
            ->defaultItems(0)
            ->columns(4)
            ->schema([
                Select::make('climate_zone_id')
                    ->label(__('catalogue::panel.plants.calendar.climate_zone'))
                    ->options(fn (): array => ClimateZone::query()->orderBy('code')->get()
                        ->mapWithKeys(fn (ClimateZone $zone): array => [$zone->id => CatalogueOptions::localName($zone->name_el, $zone->name_en)])
                        ->all())
                    ->required(),
                Select::make('activity')
                    ->label(__('catalogue::panel.plants.calendar.activity'))
                    ->options(CatalogueOptions::enum(CalendarActivity::class, 'calendar_activities'))
                    ->required(),
                CatalogueOptions::monthSelect('month_from', __('catalogue::panel.plants.calendar.month_from'))
                    ->required(),
                CatalogueOptions::monthSelect('month_to', __('catalogue::panel.plants.calendar.month_to'))
                    ->required(),
            ]);
    }

    private static function companions(): Repeater
    {
        return Repeater::make('companions')
            ->hiddenLabel()
            ->relationship()
            ->addActionLabel(__('catalogue::panel.plants.companion.item'))
            ->defaultItems(0)
            ->columns(2)
            ->schema([
                Select::make('other_plant_id')
                    ->label(__('catalogue::panel.plants.companion.other_plant'))
                    ->options(fn (mixed $livewire): array => self::otherPlantOptions(
                        is_object($livewire) && method_exists($livewire, 'getRecord') ? $livewire->getRecord() : null,
                    ))
                    ->searchable()
                    ->required()
                    ->distinct(),
                Select::make('relation')
                    ->label(__('catalogue::panel.plants.companion.relation'))
                    ->options(CatalogueOptions::enum(CompanionRelation::class, 'companion_relations'))
                    ->required(),
            ]);
    }

    /**
     * Every other plant, so that a plant is never its own companion.
     *
     * @return array<string, string>
     */
    private static function otherPlantOptions(mixed $plant): array
    {
        return Plant::query()
            ->when($plant instanceof Plant, fn (Builder $query) => $query->whereKeyNot($plant->getKey()))
            ->orderBy('scientific_name')
            ->pluck('scientific_name', 'id')
            ->all();
    }

    private static function careIntervals(): Repeater
    {
        return Repeater::make('careIntervals')
            ->hiddenLabel()
            ->relationship()
            ->addActionLabel(__('catalogue::panel.plants.care_interval.item'))
            ->defaultItems(0)
            ->columns(4)
            ->schema([
                Select::make('action')
                    ->label(__('catalogue::panel.plants.care_interval.action'))
                    ->options(CatalogueOptions::enum(CareAction::class, 'care_actions'))
                    ->required(),
                TextInput::make('interval_days')
                    ->label(__('catalogue::panel.plants.care_interval.interval_days'))
                    ->integer()
                    ->minValue(1)
                    ->maxValue(100_000)
                    ->required(),
                CatalogueOptions::monthSelect('month_from', __('catalogue::panel.plants.care_interval.month_from')),
                CatalogueOptions::monthSelect('month_to', __('catalogue::panel.plants.care_interval.month_to')),
            ]);
    }

    private static function photos(): Repeater
    {
        $store = app(CataloguePhotoStore::class);

        return Repeater::make('photos')
            ->hiddenLabel()
            ->relationship()
            ->addActionLabel(__('catalogue::panel.plants.photo.item'))
            ->defaultItems(0)
            ->columns(2)
            ->schema([
                FileUpload::make('file_path')
                    ->label(__('catalogue::panel.plants.photo.file'))
                    ->required()
                    ->image()
                    ->disk($store->disk())
                    ->directory($store->directory())
                    ->visibility('private')
                    ->acceptedFileTypes($store->acceptedMimeTypes())
                    ->maxSize($store->maxKilobytes())
                    // A path is accepted only if it is the photo's own stored path or a photo that
                    // was stored in this request (the stored path is validated once more on save).
                    ->preventFilePathTampering(allowFilePathUsing: fn (string $file): bool => app(CataloguePhotoStore::class)->storedInThisRequest($file))
                    ->saveUploadedFileUsing(fn (TemporaryUploadedFile $file): string => app(CataloguePhotoStore::class)->store($file))
                    ->columnSpanFull(),
                TextInput::make('credit')
                    ->label(__('catalogue::panel.plants.photo.credit'))
                    ->required()
                    ->maxLength(255),
                TextInput::make('licence')
                    ->label(__('catalogue::panel.plants.photo.licence'))
                    ->required()
                    ->maxLength(255),
                TextInput::make('source_url')
                    ->label(__('catalogue::panel.plants.photo.source_url'))
                    ->url()
                    ->maxLength(2048)
                    ->columnSpanFull(),
            ]);
    }

    private static function factSources(): Repeater
    {
        return Repeater::make('factSources')
            ->hiddenLabel()
            ->relationship()
            ->addActionLabel(__('catalogue::panel.plants.source.item'))
            ->defaultItems(0)
            ->columns(3)
            ->schema([
                TextInput::make('field')
                    ->label(__('catalogue::panel.plants.source.field'))
                    ->required()
                    ->maxLength(255),
                TextInput::make('source_name')
                    ->label(__('catalogue::panel.plants.source.source_name'))
                    ->required()
                    ->maxLength(255),
                TextInput::make('licence')
                    ->label(__('catalogue::panel.plants.source.licence'))
                    ->required()
                    ->maxLength(255),
                TextInput::make('source_url')
                    ->label(__('catalogue::panel.plants.source.source_url'))
                    ->url()
                    ->maxLength(2048)
                    ->columnSpan(2),
                DateTimePicker::make('imported_at')
                    ->label(__('catalogue::panel.plants.source.imported_at')),
            ]);
    }
}
