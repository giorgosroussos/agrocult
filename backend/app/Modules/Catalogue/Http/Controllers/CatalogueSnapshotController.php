<?php

namespace App\Modules\Catalogue\Http\Controllers;

use App\Modules\Catalogue\Services\CatalogueSnapshots;
use App\Support\Http\ProblemDetails;
use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Filesystem\FilesystemAdapter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * FLOW-003 device sync: the app asks for the current version on start and downloads the
 * whole snapshot when it changed. Public, no account needed (SCOPE-002: catalogue search
 * works without sign-in).
 */
class CatalogueSnapshotController
{
    public const CONTENT_TYPE = 'application/vnd.sqlite3';

    public function __construct(private readonly CatalogueSnapshots $snapshots) {}

    public function version(Request $request): JsonResponse
    {
        $current = $this->snapshots->current();

        if ($current === null) {
            return ProblemDetails::response(Response::HTTP_NOT_FOUND, $request, 'No catalogue snapshot has been published yet.');
        }

        return new JsonResponse([
            'version' => $current->version,
            'schema_version' => $current->schemaVersion,
            'built_at' => $current->builtAt->toIso8601ZuluString(),
            'size' => $current->size,
            'sha256' => $current->sha256,
            'download_url' => route('catalogue.snapshots.show', ['version' => $current->version]),
        ], Response::HTTP_OK, ['Cache-Control' => 'no-cache']);
    }

    public function download(Request $request, int $version): StreamedResponse|JsonResponse
    {
        $path = $this->snapshots->pathOf($version);

        if ($path === null) {
            return ProblemDetails::response(Response::HTTP_NOT_FOUND, $request, 'This catalogue snapshot version is not available.');
        }

        // A version's content never changes, so it may be cached for good.
        return $this->adapter($this->snapshots->disk())->download($path, 'catalogue-v'.$version.'.sqlite', [
            'Content-Type' => self::CONTENT_TYPE,
            'Cache-Control' => 'public, max-age=31536000, immutable',
            'X-Catalogue-Version' => (string) $version,
        ]);
    }

    private function adapter(Filesystem $disk): FilesystemAdapter
    {
        assert($disk instanceof FilesystemAdapter);

        return $disk;
    }
}
