<?php

namespace App\Modules\Catalogue\Import;

/**
 * The open plant data sources of EXT-006. Name, endpoint and licence of each come from
 * config('catalogue.import.sources').
 */
enum PlantSource: string
{
    case Gbif = 'gbif';
    case Wikidata = 'wikidata';
    case OpenFarm = 'openfarm';
    case Trefle = 'trefle';

    public function displayName(): string
    {
        return $this->config('name', $this->value);
    }

    public function url(): string
    {
        return rtrim($this->config('url', ''), '/');
    }

    public function licence(): string
    {
        return $this->config('licence', '');
    }

    /**
     * Trefle needs a token; the other sources are open.
     */
    public function isConfigured(): bool
    {
        if ($this->url() === '' || $this->licence() === '') {
            return false;
        }

        return $this !== self::Trefle || $this->config('token', '') !== '';
    }

    /**
     * @return list<self>
     */
    public static function configured(): array
    {
        return array_values(array_filter(self::cases(), fn (self $source): bool => $source->isConfigured()));
    }

    public function config(string $key, string $default): string
    {
        $value = config("catalogue.import.sources.{$this->value}.{$key}");

        return is_scalar($value) ? (string) $value : $default;
    }
}
