<?php

namespace App\Modules\Catalogue\Services;

use App\Modules\Catalogue\Snapshot\SnapshotExporter;
use App\Modules\Catalogue\Snapshot\SnapshotInfo;
use App\Modules\Catalogue\Snapshot\SnapshotWriter;
use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Storage;
use RuntimeException;

/**
 * Public service for the versioned catalogue snapshot shipped to devices (ARCH-003, FLOW-003).
 *
 * rebuild() exports the published catalogue; when its content differs from the current
 * snapshot it writes a new SQLite file v<N+1>.sqlite and only then switches current.json to
 * it, so readers see either the old or the new snapshot. Equal content keeps the version.
 * The last `catalogue.snapshot.keep` versions stay downloadable.
 */
class CatalogueSnapshots
{
    private const MANIFEST = 'current.json';

    private const LOCK = 'catalogue:snapshot:build';

    public function __construct(
        private readonly SnapshotExporter $exporter,
        private readonly SnapshotWriter $writer,
    ) {}

    public function current(): ?SnapshotInfo
    {
        $manifest = $this->disk()->get($this->path(self::MANIFEST));

        if (! is_string($manifest)) {
            return null;
        }

        $data = json_decode($manifest, true);

        return is_array($data) ? SnapshotInfo::fromArray($data) : null;
    }

    /** Storage path of a snapshot version that can still be downloaded, or null. */
    public function pathOf(int $version): ?string
    {
        $path = $this->path($this->fileName($version));

        return $version > 0 && $this->disk()->exists($path) ? $path : null;
    }

    public function disk(): Filesystem
    {
        return Storage::disk((string) config('catalogue.snapshot.disk'));
    }

    /**
     * Builds a new snapshot when the published catalogue changed and returns the current one.
     */
    public function rebuild(): SnapshotInfo
    {
        return Cache::lock(self::LOCK, 300)->block(120, function (): SnapshotInfo {
            $tables = $this->exporter->export();
            $contentHash = hash('sha256', SnapshotWriter::SCHEMA_VERSION.json_encode(
                $tables,
                JSON_UNESCAPED_UNICODE | JSON_PRESERVE_ZERO_FRACTION | JSON_THROW_ON_ERROR,
            ));

            $current = $this->current();

            if ($current !== null && $current->contentHash === $contentHash && $this->pathOf($current->version) !== null) {
                return $current;
            }

            return $this->write($tables, $contentHash, ($current->version ?? 0) + 1);
        });
    }

    /**
     * @param  array<string, list<array<string, mixed>>>  $tables
     */
    private function write(array $tables, string $contentHash, int $version): SnapshotInfo
    {
        $builtAt = now()->toImmutable()->utc();
        $file = tempnam(sys_get_temp_dir(), 'catalogue-snapshot-');

        if ($file === false) {
            throw new RuntimeException('Could not create a temporary snapshot file.');
        }

        try {
            $this->writer->write($file, $tables, [
                'version' => (string) $version,
                'built_at' => $builtAt->toIso8601ZuluString(),
            ]);

            clearstatcache(true, $file);
            $path = $this->path($this->fileName($version));
            $stream = fopen($file, 'rb');

            if ($stream === false || ! $this->disk()->writeStream($path, $stream)) {
                throw new RuntimeException('Could not store the catalogue snapshot.');
            }

            if (is_resource($stream)) {
                fclose($stream);
            }

            $info = new SnapshotInfo(
                $version,
                $path,
                (string) hash_file('sha256', $file),
                (int) filesize($file),
                $builtAt,
                $contentHash,
                SnapshotWriter::SCHEMA_VERSION,
            );

            // The switch: devices only learn about the new version once its file is stored.
            if (! $this->disk()->put($this->path(self::MANIFEST), (string) json_encode($info->toArray(), JSON_PRETTY_PRINT))) {
                $this->disk()->delete($path);

                throw new RuntimeException('Could not publish the catalogue snapshot.');
            }
        } finally {
            if (is_file($file)) {
                unlink($file);
            }
        }

        $this->prune($version);

        return $info;
    }

    /** Deletes snapshot files older than the last `catalogue.snapshot.keep` versions. */
    private function prune(int $current): void
    {
        $keep = max(1, (int) config('catalogue.snapshot.keep'));

        foreach ($this->disk()->files($this->path('')) as $file) {
            if (preg_match('/^v(\d+)\.sqlite$/', basename($file), $match) === 1 && (int) $match[1] <= $current - $keep) {
                $this->disk()->delete($file);
            }
        }
    }

    private function fileName(int $version): string
    {
        return 'v'.$version.'.sqlite';
    }

    private function path(string $name): string
    {
        return trim((string) config('catalogue.snapshot.directory'), '/').'/'.$name;
    }
}
