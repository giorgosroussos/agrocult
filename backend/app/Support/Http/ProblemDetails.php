<?php

namespace App\Support\Http;

use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Throwable;

/**
 * Renders API errors as RFC 9457 problem details (application/problem+json).
 *
 * Messages of unexpected exceptions are never exposed, so internals and
 * personal data (emails, tokens, coordinates) cannot leak into responses.
 */
final class ProblemDetails
{
    public const CONTENT_TYPE = 'application/problem+json';

    /**
     * Problem details are used for every request under /api and for any
     * request that asks for JSON.
     */
    public static function appliesTo(Request $request): bool
    {
        return $request->is('api', 'api/*') || $request->expectsJson();
    }

    public function __invoke(Throwable $e, Request $request): ?JsonResponse
    {
        if (! self::appliesTo($request) || $e instanceof HttpResponseException) {
            return null;
        }

        return match (true) {
            $e instanceof ValidationException => self::response(
                $e->status,
                $request,
                'The given data was invalid.',
                ['errors' => $e->errors()],
            ),
            $e instanceof AuthenticationException => self::response(Response::HTTP_UNAUTHORIZED, $request),
            $e instanceof HttpExceptionInterface => self::response(
                $e->getStatusCode(),
                $request,
                headers: $e->getHeaders(),
            ),
            default => self::response(Response::HTTP_INTERNAL_SERVER_ERROR, $request),
        };
    }

    /**
     * @param  array<string, mixed>  $extensions
     * @param  array<string, string|list<string>|null>  $headers
     */
    public static function response(
        int $status,
        Request $request,
        ?string $detail = null,
        array $extensions = [],
        array $headers = [],
    ): JsonResponse {
        $body = [
            'type' => 'about:blank',
            'title' => Response::$statusTexts[$status] ?? 'Error',
            'status' => $status,
        ];

        if ($detail !== null) {
            $body['detail'] = $detail;
        }

        $body['instance'] = '/'.ltrim($request->path(), '/');

        return new JsonResponse(
            array_merge($body, $extensions),
            $status,
            array_merge($headers, ['Content-Type' => self::CONTENT_TYPE]),
        );
    }
}
