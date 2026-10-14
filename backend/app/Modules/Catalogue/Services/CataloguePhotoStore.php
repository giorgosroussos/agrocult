<?php

namespace App\Modules\Catalogue\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Intervention\Image\ImageManager;
use InvalidArgumentException;

/**
 * Stores catalogue photos uploaded in the admin panel.
 *
 * SEC-003: only JPEG, PNG or WebP up to 5 MB are accepted, and every photo is decoded and
 * re-encoded so that no EXIF metadata (including GPS) reaches the storage.
 */
class CataloguePhotoStore
{
    /** @var list<string> paths stored by this instance (one instance per request) */
    private array $storedPaths = [];

    private const EXTENSIONS = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
    ];

    /**
     * @return string the path of the stored photo on the catalogue photo disk
     *
     * @throws InvalidArgumentException when the file is not an accepted image
     */
    public function store(UploadedFile $file): string
    {
        $mimeType = (string) $file->getMimeType();

        if (! in_array($mimeType, $this->acceptedMimeTypes(), true) || ! isset(self::EXTENSIONS[$mimeType])) {
            throw new InvalidArgumentException('Only JPEG, PNG or WebP photos are accepted.');
        }

        if ($file->getSize() === false || $file->getSize() > $this->maxKilobytes() * 1024) {
            throw new InvalidArgumentException('A photo may be at most '.$this->maxKilobytes().' KB.');
        }

        $encoded = ImageManager::gd(autoOrientation: true, strip: true)
            ->read((string) $file->getRealPath())
            ->encodeByMediaType($mimeType);

        $path = trim((string) config('catalogue.photos.directory'), '/').'/'.Str::uuid7().'.'.self::EXTENSIONS[$mimeType];

        Storage::disk($this->disk())->put($path, (string) $encoded, 'private');

        $this->storedPaths[] = $path;

        return $path;
    }

    public function storedInThisRequest(string $path): bool
    {
        return in_array($path, $this->storedPaths, true);
    }

    public function delete(string $path): void
    {
        Storage::disk($this->disk())->delete($path);
    }

    public function disk(): string
    {
        return (string) config('catalogue.photos.disk');
    }

    public function directory(): string
    {
        return trim((string) config('catalogue.photos.directory'), '/');
    }

    public function maxKilobytes(): int
    {
        return (int) config('catalogue.photos.max_kilobytes');
    }

    /**
     * @return list<string>
     */
    public function acceptedMimeTypes(): array
    {
        /** @var list<string> $types */
        $types = config('catalogue.photos.mime_types');

        return $types;
    }
}
