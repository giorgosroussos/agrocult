<?php

namespace App\Modules\Identity\Filament;

use App\Modules\Identity\Filament\Auth\Login;
use Filament\Auth\MultiFactor\App\AppAuthentication;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages\Dashboard;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets\AccountWidget;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\PreventRequestForgery;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

/**
 * The admin panel for curators and admins (SEC-005): web session sign-in,
 * gardener accounts denied, TOTP required with one-time recovery codes.
 *
 * Every module keeps its own Filament resources and pages in
 * app/Modules/<Module>/Filament/{Resources,Pages}; they are discovered here.
 */
class AdminPanelProvider extends PanelProvider
{
    public const ID = 'admin';

    public function panel(Panel $panel): Panel
    {
        $panel = $panel
            ->default()
            ->id(self::ID)
            ->path('admin')
            ->login(Login::class)
            ->authGuard('web')
            ->colors(['primary' => Color::Green])
            ->multiFactorAuthentication(
                [
                    AppAuthentication::make()
                        ->brandName((string) config('app.name'))
                        ->recoverable(),
                ],
                isRequired: true,
            )
            ->pages([Dashboard::class])
            ->widgets([AccountWidget::class])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                PreventRequestForgery::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);

        foreach (glob(app_path('Modules/*/Filament'), GLOB_ONLYDIR) ?: [] as $directory) {
            $namespace = 'App\\Modules\\'.basename(dirname($directory)).'\\Filament';

            if (is_dir($directory.'/Resources')) {
                $panel->discoverResources(in: $directory.'/Resources', for: $namespace.'\\Resources');
            }

            if (is_dir($directory.'/Pages')) {
                $panel->discoverPages(in: $directory.'/Pages', for: $namespace.'\\Pages');
            }
        }

        return $panel;
    }
}
