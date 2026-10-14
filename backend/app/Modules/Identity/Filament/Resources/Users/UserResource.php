<?php

namespace App\Modules\Identity\Filament\Resources\Users;

use App\Modules\Identity\Filament\Resources\Users\Pages\ListUsers;
use App\Modules\Identity\Models\User;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Gate;

/**
 * Panel accounts overview for the admin (SEC-005): shows whether an account
 * has TOTP set up and lets the admin reset another account's MFA.
 * Gardens and other user data are not reachable from here.
 */
class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static ?string $recordTitleAttribute = 'email';

    public static function getModelLabel(): string
    {
        return __('identity::panel.users.model_label');
    }

    public static function getPluralModelLabel(): string
    {
        return __('identity::panel.users.plural_model_label');
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('email')
                    ->label(__('identity::panel.users.columns.email'))
                    ->searchable(),
                TextColumn::make('role')
                    ->label(__('identity::panel.users.columns.role'))
                    ->formatStateUsing(fn ($state): string => __('identity::panel.roles.'.$state->value)),
                IconColumn::make('mfa')
                    ->label(__('identity::panel.users.columns.mfa'))
                    ->boolean()
                    ->state(fn (User $record): bool => $record->hasMultiFactorAuthentication()),
                TextColumn::make('created_at')
                    ->label(__('identity::panel.users.columns.created_at'))
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->recordActions([
                self::resetMultiFactorAuthenticationAction(),
            ]);
    }

    public static function resetMultiFactorAuthenticationAction(): Action
    {
        return Action::make('resetMultiFactorAuthentication')
            ->label(__('identity::panel.users.reset_mfa.label'))
            ->icon(Heroicon::OutlinedKey)
            ->color('danger')
            ->requiresConfirmation()
            ->modalDescription(__('identity::panel.users.reset_mfa.description'))
            ->visible(fn (User $record): bool => $record->hasMultiFactorAuthentication())
            ->authorize(fn (User $record): bool => Gate::allows('resetMultiFactorAuthentication', $record))
            ->action(function (User $record): void {
                Gate::authorize('resetMultiFactorAuthentication', $record);

                $record->resetMultiFactorAuthentication();

                Notification::make()
                    ->title(__('identity::panel.users.reset_mfa.done'))
                    ->success()
                    ->send();
            });
    }

    public static function getPages(): array
    {
        return [
            'index' => ListUsers::route('/'),
        ];
    }
}
