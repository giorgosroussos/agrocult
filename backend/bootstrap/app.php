<?php

use App\Support\Http\ProblemDetails;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // API guests get a 401 problem document, never a redirect to a login page.
        $middleware->redirectGuestsTo(
            fn (Request $request) => ProblemDetails::appliesTo($request) || ! Route::has('login') ? null : route('login'),
        );
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // API errors as RFC 9457 problem details; module API routes live under /api/v1.
        $exceptions->shouldRenderJsonWhen(ProblemDetails::appliesTo(...));
        $exceptions->render(new ProblemDetails);
    })->create();
