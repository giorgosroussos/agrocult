<?php

use App\Modules\Catalogue\Enums\AliasKind;
use App\Modules\Catalogue\Enums\CalendarActivity;
use App\Modules\Catalogue\Enums\CareAction;
use App\Modules\Catalogue\Enums\CompanionRelation;
use App\Modules\Catalogue\Enums\PlantStatus;
use App\Modules\Catalogue\Enums\Sun;
use App\Modules\Catalogue\Enums\TextLanguage;
use App\Modules\Catalogue\Enums\TipStatus;
use App\Modules\Catalogue\Filament\Resources\ClimateZones\Pages\CreateClimateZone;
use App\Modules\Catalogue\Filament\Resources\ClimateZones\Pages\EditClimateZone;
use App\Modules\Catalogue\Filament\Resources\PlantCategories\Pages\CreatePlantCategory;
use App\Modules\Catalogue\Filament\Resources\PlantCategories\Pages\EditPlantCategory;
use App\Modules\Catalogue\Filament\Resources\Plants\Pages\CreatePlant;
use App\Modules\Catalogue\Filament\Resources\Plants\Pages\EditPlant;
use App\Modules\Catalogue\Filament\Resources\Plants\Pages\ListPlants;
use App\Modules\Catalogue\Filament\Resources\Tips\Pages\CreateTip;
use App\Modules\Catalogue\Filament\Resources\Tips\Pages\ListTips;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Models\PlantPhoto;
use App\Modules\Catalogue\Models\Tip;
use App\Modules\Identity\Enums\Role;
use App\Modules\Identity\Filament\AdminPanelProvider;
use App\Modules\Identity\Models\User;
use Filament\Facades\Filament;
use Filament\Forms\Components\Repeater;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Livewire\Livewire;

uses(RefreshDatabase::class);

beforeEach(function () {
    Filament::setCurrentPanel(Filament::getPanel(AdminPanelProvider::ID));
    Storage::fake((string) config('catalogue.photos.disk'));
});

/**
 * A curator or admin with TOTP set up, signed in to the panel.
 */
function signInCurator(Role $role = Role::Curator): User
{
    $totp = Filament::getPanel(AdminPanelProvider::ID)->getMultiFactorAuthenticationProviders()['app'];
    $user = User::factory()->role($role)->withAppAuthentication($totp->generateSecret())->create();
    test()->actingAs($user);

    return $user;
}

/**
 * A JPEG whose EXIF block carries a GPS marker.
 */
function jpegWithExif(string $marker): string
{
    $image = imagecreatetruecolor(40, 30);
    imagefill($image, 0, 0, (int) imagecolorallocate($image, 200, 60, 40));
    ob_start();
    imagejpeg($image);
    $jpeg = (string) ob_get_clean();

    $tiff = "MM\x00\x2A\x00\x00\x00\x08"."\x00\x00"."\x00\x00\x00\x00".$marker;
    $app1 = "\xFF\xE1".pack('n', strlen("Exif\x00\x00".$tiff) + 2)."Exif\x00\x00".$tiff;

    return substr($jpeg, 0, 2).$app1.substr($jpeg, 2);
}

const CATALOGUE_PANEL_URLS = [
    '/admin/plants',
    '/admin/plants/create',
    '/admin/plant-categories',
    '/admin/plant-categories/create',
    '/admin/climate-zones',
    '/admin/climate-zones/create',
    '/admin/tips',
    '/admin/tips/create',
];

// --- Access (UC-010, SEC-005) ---

it('denies a gardener account every catalogue page of the admin panel (UC-010)', function () {
    $gardener = User::factory()->create();
    $plant = Plant::factory()->create();
    $this->actingAs($gardener);

    foreach ([...CATALOGUE_PANEL_URLS, "/admin/plants/{$plant->id}/edit"] as $url) {
        $this->get($url)->assertForbidden();
    }

    expect($gardener->can('viewAny', Plant::class))->toBeFalse()
        ->and($gardener->can('update', $plant))->toBeFalse()
        ->and($gardener->can('create', PlantCategory::class))->toBeFalse()
        ->and($gardener->can('viewAny', Tip::class))->toBeFalse();

    Livewire::test(ListPlants::class)->assertForbidden();
    Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])->assertForbidden();
});

it('sends a visitor without a session to the panel sign-in', function () {
    $this->get('/admin/plants')->assertRedirect('/admin/login');
});

it('lets a curator and an admin open every catalogue page', function (Role $role) {
    signInCurator($role);
    $plant = Plant::factory()->create();

    foreach ([...CATALOGUE_PANEL_URLS, "/admin/plants/{$plant->id}/edit"] as $url) {
        $this->get($url)->assertOk();
    }
})->with([Role::Curator, Role::Admin]);

// --- Plants with all sections ---

it('creates a draft plant with all its sections from the panel', function () {
    signInCurator();
    Repeater::fake();
    $category = PlantCategory::factory()->create();
    $zone = ClimateZone::factory()->create();
    $basil = Plant::factory()->create(['scientific_name' => 'Ocimum basilicum']);

    Livewire::test(CreatePlant::class)
        ->fillForm([
            'scientific_name' => 'Solanum lycopersicum',
            'category_id' => $category->id,
            'gbif_id' => 2930137,
            'temp_min_c' => 10,
            'temp_opt_c' => 24.5,
            'water_need' => 4,
            'sun' => Sun::FullSun->value,
            'soil_types' => ['loam'],
            'translations' => [
                ['lang' => 'el', 'name' => 'Ντομάτα', 'care' => 'Τακτικό πότισμα'],
                ['lang' => 'en', 'name' => 'Tomato'],
            ],
            'aliases' => [['alias' => 'ntomata', 'lang' => 'el', 'kind' => AliasKind::Greeklish->value]],
            'calendars' => [['climate_zone_id' => $zone->id, 'activity' => CalendarActivity::SowIndoors->value, 'month_from' => 2, 'month_to' => 3]],
            'companions' => [['other_plant_id' => $basil->id, 'relation' => CompanionRelation::Good->value]],
            'careIntervals' => [['action' => CareAction::Water->value, 'interval_days' => 3, 'month_from' => 5, 'month_to' => 9]],
            'factSources' => [['field' => 'temp_opt_c', 'source_name' => 'GBIF', 'licence' => 'CC0', 'source_url' => 'https://www.gbif.org/species/2930137']],
        ])
        ->call('create')
        ->assertHasNoFormErrors();

    $plant = Plant::query()->where('scientific_name', 'Solanum lycopersicum')->firstOrFail();

    expect($plant->status)->toBe(PlantStatus::Draft)
        ->and($plant->category_id)->toBe($category->id)
        ->and($plant->translations()->pluck('name', 'lang')->all())->toEqual(['el' => 'Ντομάτα', 'en' => 'Tomato'])
        ->and($plant->aliases()->first()?->alias)->toBe('ntomata')
        ->and($plant->calendars()->first()?->climate_zone_id)->toBe($zone->id)
        ->and($plant->companions()->first()?->other_plant_id)->toBe($basil->id)
        ->and($plant->careIntervals()->first()?->interval_days)->toBe(3)
        ->and($plant->factSources()->first()?->only(['source_name', 'licence']))->toBe(['source_name' => 'GBIF', 'licence' => 'CC0'])
        ->and(Plant::published()->whereKey($plant->id)->exists())->toBeFalse();
});

it('does not save a plant without a scientific name or category', function (string $missing) {
    signInCurator();
    $data = ['scientific_name' => 'Allium sativum', 'category_id' => PlantCategory::factory()->create()->id];
    unset($data[$missing]);

    Livewire::test(CreatePlant::class)
        ->fillForm($data)
        ->call('create')
        ->assertHasFormErrors([$missing => 'required']);

    expect(Plant::query()->count())->toBe(0);
})->with(['scientific_name', 'category_id']);

it('requires the source name and licence of every recorded fact (SCOPE-001)', function () {
    signInCurator();
    Repeater::fake();

    Livewire::test(CreatePlant::class)
        ->fillForm([
            'scientific_name' => 'Allium sativum',
            'category_id' => PlantCategory::factory()->create()->id,
            'factSources' => [['field' => 'sow_depth_cm', 'source_name' => '', 'licence' => '']],
        ])
        ->call('create')
        ->assertHasFormErrors(['factSources.0.source_name' => 'required', 'factSources.0.licence' => 'required']);

    expect(Plant::query()->count())->toBe(0);
});

it('rejects values outside the data model in the plant form', function (string $field, mixed $value) {
    signInCurator();
    Repeater::fake();

    Livewire::test(CreatePlant::class)
        ->fillForm(array_merge(
            ['scientific_name' => 'Allium sativum', 'category_id' => PlantCategory::factory()->create()->id],
            $field === 'translations' ? ['translations' => $value] : [$field => $value],
        ))
        ->call('create')
        ->assertHasFormErrors();

    expect(Plant::query()->count())->toBe(0);
})->with([
    'water need above 5' => ['water_need', 6],
    'unknown sun value' => ['sun', 'moonlight'],
    'pH above 14' => ['ph_min', 15],
    'two texts in the same language' => ['translations', [['lang' => 'el', 'name' => 'Σκόρδο'], ['lang' => 'el', 'name' => 'Σκόρδο 2']]],
    'a text in a third language' => ['translations', [['lang' => 'de', 'name' => 'Knoblauch']]],
]);

it('does not offer a plant as its own companion', function () {
    signInCurator();
    Repeater::fake();
    $plant = Plant::factory()->create();

    Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->fillForm(['companions' => [['other_plant_id' => $plant->id, 'relation' => CompanionRelation::Bad->value]]])
        ->call('save')
        ->assertHasFormErrors(['companions.0.other_plant_id']);

    expect($plant->companions()->count())->toBe(0);
});

it('does not change the status when the plant form is saved', function () {
    signInCurator();
    $plant = Plant::factory()->create();

    Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->fillForm(['scientific_name' => 'Allium cepa', 'status' => PlantStatus::Published->value])
        ->call('save')
        ->assertHasNoFormErrors();

    expect($plant->fresh()->scientific_name)->toBe('Allium cepa')
        ->and($plant->fresh()->status)->toBe(PlantStatus::Draft);
});

// --- Review and publishing (UC-010, ENT-Plant state model) ---

it('submits a plant for review, then marks it reviewed and publishes it (UC-010)', function () {
    $curator = signInCurator();
    $plant = Plant::factory()->create();

    Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->callAction('submitForReview')
        ->assertNotified();
    expect($plant->fresh()->status)->toBe(PlantStatus::InReview);

    Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->callAction('publish')
        ->assertNotified();

    $plant->refresh();
    expect($plant->status)->toBe(PlantStatus::Published)
        ->and($plant->reviewed_by)->toBe($curator->id)
        ->and($plant->reviewed_at)->not->toBeNull()
        ->and($plant->published_at)->not->toBeNull()
        ->and(Plant::published()->pluck('id')->all())->toBe([$plant->id]);
});

it('includes a plant published in the panel in the catalogue for devices and leaves drafts out (UC-010)', function () {
    signInCurator();
    $draft = Plant::factory()->create();
    $inReview = Plant::factory()->inReview()->create();
    $published = Plant::factory()->published()->create();

    Livewire::test(EditPlant::class, ['record' => $inReview->getRouteKey()])->callAction('publish');

    expect(Plant::published()->pluck('id')->sort()->values()->all())
        ->toBe(collect([$inReview->id, $published->id])->sort()->values()->all())
        ->and(Plant::published()->whereKey($draft->id)->exists())->toBeFalse();
});

it('does not publish a plant without a scientific name and leaves its status unchanged (UC-010)', function () {
    signInCurator();
    $plant = Plant::factory()->inReview()->create();
    DB::table('plants')->where('id', $plant->id)->update(['scientific_name' => '   ']);

    Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->assertSee('Missing before publishing: Scientific name')
        ->callAction('publish')
        ->assertNotified('The plant cannot be published. Missing: Scientific name');

    $plant->refresh();
    expect($plant->status)->toBe(PlantStatus::InReview)
        ->and($plant->published_at)->toBeNull()
        ->and(Plant::published()->count())->toBe(0);
});

it('offers only the transitions of the state model', function (Closure $make, array $visible) {
    signInCurator();
    $plant = $make();
    $page = Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()]);

    foreach (['submitForReview', 'publish', 'returnToDraft', 'archive'] as $action) {
        in_array($action, $visible, true) ? $page->assertActionVisible($action) : $page->assertActionHidden($action);
    }
})->with([
    'draft' => [fn () => Plant::factory()->create(), ['submitForReview']],
    'in review' => [fn () => Plant::factory()->inReview()->create(), ['publish', 'returnToDraft']],
    'published' => [fn () => Plant::factory()->published()->create(), ['returnToDraft', 'archive']],
    'archived' => [fn () => Plant::factory()->archived()->create(), []],
]);

it('rejects a transition not in the state model and leaves the state unchanged (ENT-Plant)', function (Closure $make, string $action) {
    signInCurator();
    $plant = $make();
    $before = $plant->fresh()->status;

    Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->assertActionHidden($action)
        // A forged request that mounts the hidden action anyway.
        ->call('mountAction', $action)
        ->call('callMountedAction');

    expect($plant->fresh()->status)->toBe($before)
        ->and(Plant::published()->whereKey($plant->id)->exists())->toBe($before === PlantStatus::Published);
})->with([
    'draft -> published' => [fn () => Plant::factory()->create(), 'publish'],
    'draft -> archived' => [fn () => Plant::factory()->create(), 'archive'],
    'draft -> draft' => [fn () => Plant::factory()->create(), 'returnToDraft'],
    'in_review -> archived' => [fn () => Plant::factory()->inReview()->create(), 'archive'],
    'published -> in_review' => [fn () => Plant::factory()->published()->create(), 'submitForReview'],
    'archived -> draft' => [fn () => Plant::factory()->archived()->create(), 'returnToDraft'],
    'archived -> published' => [fn () => Plant::factory()->archived()->create(), 'publish'],
]);

it('rejects a transition that became invalid after the page was opened and leaves the state unchanged (ENT-Plant)', function () {
    signInCurator();
    $plant = Plant::factory()->inReview()->create();
    $page = Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->mountAction('publish')
        ->assertActionMounted('publish');

    // Another curator returns the plant to draft while the confirmation is open.
    DB::table('plants')->where('id', $plant->id)->update(['status' => PlantStatus::Draft->value]);

    $page->callMountedAction();

    expect($plant->fresh()->status)->toBe(PlantStatus::Draft)
        ->and($plant->fresh()->published_at)->toBeNull();
});

// --- Photos (SEC-003) ---

it('stores a catalogue photo with credit and licence in private storage without EXIF metadata (SEC-003)', function () {
    signInCurator();
    Repeater::fake();
    $plant = Plant::factory()->create();
    $upload = UploadedFile::fake()->createWithContent('tomato.jpg', jpegWithExif('GPS-37.9838N-23.7275E'));

    Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->fillForm(['photos' => [['file_path' => [$upload], 'credit' => 'A. Photographer', 'licence' => 'CC BY 4.0']]])
        ->call('save')
        ->assertHasNoFormErrors();

    $photo = PlantPhoto::query()->where('plant_id', $plant->id)->firstOrFail();
    $disk = Storage::disk((string) config('catalogue.photos.disk'));
    $stored = (string) $disk->get($photo->file_path);

    expect($photo->credit)->toBe('A. Photographer')
        ->and($photo->licence)->toBe('CC BY 4.0')
        ->and($photo->file_path)->toStartWith('catalogue/photos/')
        ->and($disk->getVisibility($photo->file_path))->toBe('private')
        ->and(getimagesizefromstring($stored)['mime'] ?? null)->toBe('image/jpeg')
        ->and(str_contains($stored, 'GPS-37.9838N'))->toBeFalse()
        ->and(str_contains($stored, "Exif\x00\x00"))->toBeFalse();
});

it('rejects a photo that is not JPEG, PNG or WebP or is larger than 5 MB (SEC-003)', function (Closure $file, string $error) {
    signInCurator();
    Repeater::fake();
    $plant = Plant::factory()->create();

    $page = Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->fillForm(['photos' => [['file_path' => [$file()], 'credit' => 'A. Photographer', 'licence' => 'CC BY 4.0']]])
        ->call('save')
        ->assertHasFormErrors(['photos.0.file_path']);

    expect($page->errors()->first('data.photos.0.file_path'))->toContain($error)
        ->and(PlantPhoto::query()->count())->toBe(0)
        ->and(Storage::disk((string) config('catalogue.photos.disk'))->allFiles('catalogue'))->toBe([]);
})->with([
    'gif' => [fn () => UploadedFile::fake()->image('plant.gif'), 'must be a file of type: image/jpeg, image/png, image/webp'],
    'pdf' => [fn () => UploadedFile::fake()->create('plant.pdf', 10, 'application/pdf'), 'must be a file of type: image/jpeg, image/png, image/webp'],
    'over 5 MB' => [fn () => UploadedFile::fake()->image('plant.jpg')->size(5121), 'must not be greater than 5120 kilobytes'],
]);

it('does not let a photo point at another file on the disk', function () {
    signInCurator();
    Repeater::fake();
    $plant = Plant::factory()->create();
    Storage::disk((string) config('catalogue.photos.disk'))->put('gardens/someone/private.jpg', 'x');

    Livewire::test(EditPlant::class, ['record' => $plant->getRouteKey()])
        ->fillForm(['photos' => [['file_path' => ['gardens/someone/private.jpg'], 'credit' => 'X', 'licence' => 'CC0']]])
        ->call('save')
        ->assertHasFormErrors(['photos.0.file_path']);

    expect(PlantPhoto::query()->count())->toBe(0);
});

// --- Categories, climate zones and tips ---

it('manages categories as curator data with an optional parent (DATA-004)', function () {
    signInCurator();
    $parent = PlantCategory::factory()->create(['code' => 'vegetables']);

    Livewire::test(CreatePlantCategory::class)
        ->fillForm(['code' => 'fruiting_vegetables', 'name_el' => 'Καρποφόρα λαχανικά', 'name_en' => 'Fruiting vegetables', 'parent_id' => $parent->id, 'sort_order' => 2])
        ->call('create')
        ->assertHasNoFormErrors();

    expect(PlantCategory::query()->where('code', 'fruiting_vegetables')->first()?->parent_id)->toBe($parent->id);
});

it('does not let a category become its own parent or the child of its sub-category', function () {
    signInCurator();
    $parent = PlantCategory::factory()->create();
    $child = PlantCategory::factory()->create(['parent_id' => $parent->id]);

    foreach ([$parent->id, $child->id] as $newParent) {
        Livewire::test(EditPlantCategory::class, ['record' => $parent->getRouteKey()])
            ->fillForm(['parent_id' => $newParent])
            ->call('save')
            ->assertHasFormErrors(['parent_id']);
    }

    expect($parent->fresh()->parent_id)->toBeNull();
});

it('does not delete a category that plants still use', function () {
    signInCurator();
    $used = PlantCategory::factory()->create();
    Plant::factory()->create(['category_id' => $used->id]);
    $unused = PlantCategory::factory()->create();

    Livewire::test(EditPlantCategory::class, ['record' => $used->getRouteKey()])->assertActionHidden('delete');
    Livewire::test(EditPlantCategory::class, ['record' => $unused->getRouteKey()])->callAction('delete');

    expect(PlantCategory::query()->whereKey($used->id)->exists())->toBeTrue()
        ->and(PlantCategory::query()->whereKey($unused->id)->exists())->toBeFalse();
});

it('creates a climate zone with JSON rules and rejects rules that are not a JSON object', function () {
    signInCurator();

    Livewire::test(CreateClimateZone::class)
        ->fillForm(['code' => 'coastal_south', 'name_el' => 'Νότια παράκτια', 'name_en' => 'Southern coastal', 'rules' => '{"min_temp_jan": {"gte": 8}}'])
        ->call('create')
        ->assertHasNoFormErrors();

    expect(ClimateZone::query()->where('code', 'coastal_south')->first()?->rules)->toBe(['min_temp_jan' => ['gte' => 8]]);

    foreach (['not json', '[1, 2]', '"text"'] as $rules) {
        Livewire::test(CreateClimateZone::class)
            ->fillForm(['code' => 'mountain', 'name_el' => 'Ορεινή', 'name_en' => 'Mountain', 'rules' => $rules])
            ->call('create')
            ->assertHasFormErrors(['rules']);
    }

    expect(ClimateZone::query()->where('code', 'mountain')->exists())->toBeFalse();
});

it('does not delete a climate zone that a plant calendar uses', function () {
    signInCurator();
    Repeater::fake();
    $zone = ClimateZone::factory()->create();
    $plant = Plant::factory()->create();
    $plant->calendars()->create(['climate_zone_id' => $zone->id, 'activity' => CalendarActivity::Harvest, 'month_from' => 7, 'month_to' => 9]);

    Livewire::test(EditClimateZone::class, ['record' => $zone->getRouteKey()])->assertActionHidden('delete');

    expect(ClimateZone::query()->whereKey($zone->id)->exists())->toBeTrue();
});

it('creates tips and keeps draft tips out of the catalogue for devices', function () {
    signInCurator();
    $zone = ClimateZone::factory()->create();

    foreach ([TipStatus::Draft, TipStatus::Published] as $status) {
        Livewire::test(CreateTip::class)
            ->fillForm(['text_el' => "Συμβουλή {$status->value}", 'text_en' => "Tip {$status->value}", 'month_from' => 10, 'month_to' => 11, 'climate_zone_id' => $zone->id, 'status' => $status->value])
            ->call('create')
            ->assertHasNoFormErrors();
    }

    expect(Tip::query()->count())->toBe(2)
        ->and(Tip::published()->pluck('text_en')->all())->toBe(['Tip published']);

    Livewire::test(ListTips::class)->assertCanSeeTableRecords(Tip::all());
});

it('lists plants with their status for curators', function () {
    signInCurator();
    $plants = collect([Plant::factory()->create(), Plant::factory()->published()->create()]);
    $plants->first()->translations()->create(['lang' => TextLanguage::El, 'name' => 'Σκόρδο']);

    Livewire::test(ListPlants::class)
        ->assertCanSeeTableRecords($plants)
        ->assertSee('Σκόρδο')
        ->assertSee('Published');
});
