<?php

use App\Modules\Identity\Models\PushToken;
use App\Modules\Identity\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Gate;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->me = User::factory()->create();
    $this->other = User::factory()->create();
    $this->othersToken = PushToken::factory()->for($this->other)->create(['token' => 'fcm-of-other']);
});

it('requires an authenticated account', function () {
    $this->getJson('/api/v1/me/push-tokens')->assertUnauthorized();
    $this->postJson('/api/v1/me/push-tokens', ['token' => 'x', 'platform' => 'android'])->assertUnauthorized();
    $this->deleteJson("/api/v1/me/push-tokens/{$this->othersToken->id}")->assertUnauthorized();

    expect(PushToken::query()->count())->toBe(1);
});

it('registers, refreshes, lists and removes the own push token', function () {
    Sanctum::actingAs($this->me);

    $id = $this->postJson('/api/v1/me/push-tokens', ['token' => 'fcm-mine', 'platform' => 'android'])
        ->assertCreated()
        ->assertJsonPath('data.token', 'fcm-mine')
        ->json('data.id');

    $this->postJson('/api/v1/me/push-tokens', ['token' => 'fcm-mine', 'platform' => 'ios'])
        ->assertOk()
        ->assertJsonPath('data.id', $id)
        ->assertJsonPath('data.platform', 'ios');

    $this->getJson('/api/v1/me/push-tokens')->assertOk()
        ->assertJsonCount(1, 'data')
        ->assertJsonPath('data.0.id', $id)
        ->assertJsonPath('meta.total', 1);

    $this->deleteJson("/api/v1/me/push-tokens/{$id}")->assertNoContent();
    expect($this->me->pushTokens()->count())->toBe(0);
});

it('rejects an unknown platform', function () {
    Sanctum::actingAs($this->me);

    $this->postJson('/api/v1/me/push-tokens', ['token' => 'fcm-mine', 'platform' => 'windows'])->assertStatus(422);
    expect($this->me->pushTokens()->count())->toBe(0);
});

it('denies a gardener access to push tokens of another user and changes nothing (OWN-005)', function () {
    Sanctum::actingAs($this->me);
    $before = $this->othersToken->fresh()->getAttributes();

    // Not listed.
    $this->getJson('/api/v1/me/push-tokens')->assertOk()->assertJsonCount(0, 'data');

    // Not removable.
    $this->deleteJson("/api/v1/me/push-tokens/{$this->othersToken->id}")
        ->assertForbidden()
        ->assertHeader('Content-Type', 'application/problem+json');

    // Not taken over by registering the same token value.
    $this->postJson('/api/v1/me/push-tokens', ['token' => 'fcm-of-other', 'platform' => 'ios'])
        ->assertForbidden();

    // Not removed through sign-out either.
    $this->me->createToken('device-a');
    app('auth')->forgetGuards();
    $plain = $this->me->createToken('device-b')->plainTextToken;
    $this->withToken($plain)->postJson('/api/v1/auth/sign-out', ['push_token' => 'fcm-of-other'])->assertNoContent();

    expect($this->othersToken->fresh()->getAttributes())->toBe($before)
        ->and($this->me->pushTokens()->count())->toBe(0)
        ->and(Gate::forUser($this->me)->denies('view', $this->othersToken))->toBeTrue()
        ->and(Gate::forUser($this->me)->denies('delete', $this->othersToken))->toBeTrue();
});

it('removes the push token of the device on sign-out', function () {
    PushToken::factory()->for($this->me)->create(['token' => 'fcm-mine']);
    $plain = $this->me->createToken('device-a')->plainTextToken;

    $this->withToken($plain)->postJson('/api/v1/auth/sign-out', ['push_token' => 'fcm-mine'])->assertNoContent();

    expect($this->me->pushTokens()->count())->toBe(0);
});
