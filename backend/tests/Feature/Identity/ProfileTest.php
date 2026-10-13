<?php

use App\Modules\Identity\Enums\Role;
use App\Modules\Identity\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Gate;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->me = User::factory()->create(['email' => 'me@example.com', 'language' => 'el']);
    $this->other = User::factory()->create(['email' => 'other@example.com', 'language' => 'el']);
});

it('requires an authenticated account', function () {
    $this->getJson('/api/v1/me')->assertUnauthorized()->assertHeader('Content-Type', 'application/problem+json');
    $this->patchJson('/api/v1/me', ['language' => 'en'])->assertUnauthorized();
    // Also without an Accept header (no login redirect).
    $this->get('/api/v1/me')->assertUnauthorized();
});

it('shows and changes the language and notification preferences of the own account', function () {
    Sanctum::actingAs($this->me);

    $this->getJson('/api/v1/me')->assertOk()
        ->assertJsonPath('data.email', 'me@example.com')
        ->assertJsonPath('data.notification_prefs', ['summary' => true, 'frost' => true, 'heatwave' => true]);

    $this->patchJson('/api/v1/me', ['language' => 'en', 'notification_prefs' => ['frost' => false]])
        ->assertOk()
        ->assertJsonPath('data.language', 'en')
        ->assertJsonPath('data.notification_prefs', ['summary' => true, 'frost' => false, 'heatwave' => true]);

    $me = $this->me->fresh();
    expect($me->language->value)->toBe('en')
        ->and($me->notificationPreferences()['frost'])->toBeFalse();
});

it('rejects unknown notification types and languages', function () {
    Sanctum::actingAs($this->me);

    $this->patchJson('/api/v1/me', ['notification_prefs' => ['marketing' => true]])->assertStatus(422);
    $this->patchJson('/api/v1/me', ['notification_prefs' => ['frost' => 'maybe']])->assertStatus(422);
    $this->patchJson('/api/v1/me', ['language' => 'fr'])->assertStatus(422);

    expect($this->me->fresh()->language->value)->toBe('el');
});

it('denies a gardener access to another account and changes nothing (OWN-007)', function () {
    Sanctum::actingAs($this->me);
    $before = $this->other->fresh()->getAttributes();

    // No endpoint addresses another user.
    $this->getJson("/api/v1/users/{$this->other->id}")->assertNotFound();
    $this->patchJson("/api/v1/users/{$this->other->id}", ['language' => 'en'])->assertNotFound();
    $this->deleteJson("/api/v1/users/{$this->other->id}")->assertNotFound();
    $this->getJson("/api/v1/me/{$this->other->id}")->assertNotFound();

    // Fields that point at another account are ignored.
    $this->patchJson('/api/v1/me', [
        'id' => $this->other->id,
        'email' => 'other@example.com',
        'role' => 'admin',
        'language' => 'en',
    ])->assertOk()->assertJsonPath('data.id', $this->me->id);

    expect($this->other->fresh()->getAttributes())->toBe($before);
    $me = $this->me->fresh();
    expect($me->email)->toBe('me@example.com')
        ->and($me->role)->toBe(Role::Gardener);

    // The policy grants nothing on another account.
    foreach (['view', 'update', 'delete'] as $ability) {
        expect(Gate::forUser($this->me)->denies($ability, $this->other))->toBeTrue()
            ->and(Gate::forUser($this->me)->allows($ability, $this->me))->toBeTrue();
    }
});
