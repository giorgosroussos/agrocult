<?php

namespace App\Modules\Catalogue\Snapshot;

use Carbon\CarbonImmutable;

/**
 * One built catalogue snapshot: its version, where it is stored and how to verify it.
 */
final readonly class SnapshotInfo
{
    public function __construct(
        public int $version,
        public string $path,
        public string $sha256,
        public int $size,
        public CarbonImmutable $builtAt,
        public string $contentHash,
        public int $schemaVersion,
    ) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public static function fromArray(array $data): ?self
    {
        foreach (['version', 'path', 'sha256', 'size', 'built_at', 'content_hash', 'schema_version'] as $key) {
            if (! isset($data[$key]) || ! is_scalar($data[$key])) {
                return null;
            }
        }

        return new self(
            (int) $data['version'],
            (string) $data['path'],
            (string) $data['sha256'],
            (int) $data['size'],
            CarbonImmutable::parse((string) $data['built_at'])->utc(),
            (string) $data['content_hash'],
            (int) $data['schema_version'],
        );
    }

    /**
     * @return array<string, int|string>
     */
    public function toArray(): array
    {
        return [
            'version' => $this->version,
            'path' => $this->path,
            'sha256' => $this->sha256,
            'size' => $this->size,
            'built_at' => $this->builtAt->toIso8601ZuluString(),
            'content_hash' => $this->contentHash,
            'schema_version' => $this->schemaVersion,
        ];
    }
}
