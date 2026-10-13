<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Validation\ValidationException;

beforeEach(function () {
    Route::prefix('api/v1/_test')->middleware('api')->group(function () {
        Route::get('boom', fn () => throw new RuntimeException('secret user@example.com 37.98,23.72'));
        Route::get('invalid', fn () => throw ValidationException::withMessages(['email' => 'The email field is required.']));
        Route::get('forbidden', fn () => abort(403));
        Route::get('throttled', fn () => abort(429, '', ['Retry-After' => '60']));
        Route::get('ok', fn () => ['ok' => true]);
    });
});

it('returns an RFC 9457 problem details document for an unknown API route', function () {
    $response = $this->get('/api/v1/does-not-exist');

    $response->assertNotFound()
        ->assertHeader('Content-Type', 'application/problem+json')
        ->assertExactJson([
            'type' => 'about:blank',
            'title' => 'Not Found',
            'status' => 404,
            'instance' => '/api/v1/does-not-exist',
        ]);
});

it('returns problem details for an unknown API route even without a JSON Accept header', function () {
    $this->get('/api/v1/nope', ['Accept' => 'text/html'])
        ->assertNotFound()
        ->assertHeader('Content-Type', 'application/problem+json')
        ->assertJsonPath('status', 404);
});

it('returns problem details for a wrong method on an API route', function () {
    $this->postJson('/api/v1/_test/ok')
        ->assertStatus(405)
        ->assertHeader('Content-Type', 'application/problem+json')
        ->assertJsonPath('title', 'Method Not Allowed');
});

it('returns validation errors as a problem details extension', function () {
    $this->getJson('/api/v1/_test/invalid')
        ->assertUnprocessable()
        ->assertHeader('Content-Type', 'application/problem+json')
        ->assertJsonPath('status', 422)
        ->assertJsonPath('errors.email.0', 'The email field is required.');
});

it('keeps HTTP exception status and headers', function () {
    $this->getJson('/api/v1/_test/forbidden')
        ->assertForbidden()
        ->assertJsonPath('title', 'Forbidden');

    $this->getJson('/api/v1/_test/throttled')
        ->assertStatus(429)
        ->assertHeader('Retry-After', '60')
        ->assertHeader('Content-Type', 'application/problem+json');
});

it('never exposes the message of an unexpected exception', function () {
    config(['app.debug' => true]);

    $response = $this->getJson('/api/v1/_test/boom');

    $response->assertStatus(500)
        ->assertHeader('Content-Type', 'application/problem+json')
        ->assertExactJson([
            'type' => 'about:blank',
            'title' => 'Internal Server Error',
            'status' => 500,
            'instance' => '/api/v1/_test/boom',
        ]);
    expect($response->getContent())
        ->not->toContain('user@example.com')
        ->not->toContain('37.98');
});

it('does not put the query string into the instance member', function () {
    $this->getJson('/api/v1/missing?email=user@example.com')
        ->assertNotFound()
        ->assertJsonPath('instance', '/api/v1/missing');
});

it('leaves successful API responses untouched', function () {
    $this->getJson('/api/v1/_test/ok')
        ->assertOk()
        ->assertHeader('Content-Type', 'application/json')
        ->assertExactJson(['ok' => true]);
});
