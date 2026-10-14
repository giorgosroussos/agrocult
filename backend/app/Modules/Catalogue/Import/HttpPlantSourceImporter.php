<?php

namespace App\Modules\Catalogue\Import;

use App\Modules\Catalogue\Exceptions\PlantSourceUnavailable;
use Carbon\CarbonImmutable;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Support\Facades\Http;

/**
 * PlantSourceImporter over HTTP: GBIF species match, Wikidata SPARQL, the OpenFarm crops
 * rescue (CC0 JSON dump) and the Trefle API. Endpoints, token and licences come from
 * config('catalogue.import'); every call is limited to the configured timeout (30 s).
 *
 * Only facts are taken (identifiers, names, numbers, companions); descriptions and other
 * source texts are never copied (EXT-006).
 */
class HttpPlantSourceImporter implements PlantSourceImporter
{
    public function import(PlantSource $source, string $scientificName): DraftFacts
    {
        if (! $source->isConfigured()) {
            throw new PlantSourceUnavailable($source, 'it is not configured');
        }

        return match ($source) {
            PlantSource::Gbif => $this->gbif($scientificName),
            PlantSource::Wikidata => $this->wikidata($scientificName),
            PlantSource::OpenFarm => $this->openFarm($scientificName),
            PlantSource::Trefle => $this->trefle($scientificName),
        };
    }

    private function gbif(string $name): DraftFacts
    {
        $source = PlantSource::Gbif;
        $json = $this->getJson($source, $source->url().'/species/match', ['name' => $name, 'strict' => 'true']);

        if ($json === null || ($json['matchType'] ?? null) !== 'EXACT') {
            return DraftFacts::none($source, $name);
        }

        $key = $json['acceptedUsageKey'] ?? $json['usageKey'] ?? null;
        if (! is_int($key) && ! (is_string($key) && ctype_digit($key))) {
            return DraftFacts::none($source, $name);
        }

        $key = (int) $key;

        return $this->facts($source, $name, [new Fact('gbif_id', $key)], $source->url().'/species/'.$key);
    }

    private function wikidata(string $name): DraftFacts
    {
        $source = PlantSource::Wikidata;
        $literal = addcslashes($name, "\\\"\n\r");
        $query = <<<SPARQL
            SELECT ?item ?gbif ?label ?kind WHERE {
              ?item wdt:P225 "{$literal}" .
              OPTIONAL { ?item wdt:P846 ?gbif . }
              OPTIONAL {
                { ?item rdfs:label ?label . BIND("name" AS ?kind) }
                UNION
                { ?item skos:altLabel ?label . BIND("alias" AS ?kind) }
                FILTER(LANG(?label) IN ("el", "en"))
              }
            } LIMIT 500
            SPARQL;

        $json = $this->getJson($source, $source->url(), ['query' => $query, 'format' => 'json'], 'application/sparql-results+json');
        $bindings = $json['results']['bindings'] ?? null;

        if (! is_array($bindings) || $bindings === []) {
            return DraftFacts::none($source, $name);
        }

        $item = $this->string($bindings[0]['item']['value'] ?? null);
        $facts = [];

        foreach ($bindings as $binding) {
            if (! is_array($binding) || $this->string($binding['item']['value'] ?? null) !== $item) {
                continue;
            }

            $gbif = $this->string($binding['gbif']['value'] ?? null);
            if ($gbif !== null && ctype_digit($gbif)) {
                $facts['gbif_id'] = new Fact('gbif_id', (int) $gbif);
            }

            $label = $this->string($binding['label']['value'] ?? null);
            $lang = $this->string($binding['label']['xml:lang'] ?? null);
            $kind = $this->string($binding['kind']['value'] ?? null);

            if ($label === null || $lang === null || $kind === null || mb_strtolower($label) === mb_strtolower($name)) {
                continue;
            }

            $field = ($kind === 'name' ? 'name.' : 'alias.').$lang;
            $facts[$field.'|'.mb_strtolower($label)] = new Fact($field, $label);
        }

        return $this->facts($source, $name, array_values($facts), $item);
    }

    private function openFarm(string $name): DraftFacts
    {
        $source = PlantSource::OpenFarm;
        $json = $this->getJson($source, $source->url(), []);
        $records = array_is_list($json ?? []) ? $json : ($json['crops'] ?? $json['data'] ?? null);

        if (! is_array($records)) {
            return DraftFacts::none($source, $name);
        }

        /** @var array<string, string> $binomialBySlug */
        $binomialBySlug = [];
        $record = null;

        foreach ($records as $candidate) {
            if (! is_array($candidate)) {
                continue;
            }

            $slug = $this->string($candidate['slug'] ?? null);
            $binomial = $this->string($candidate['binomialName'] ?? null);

            if ($slug !== null && $binomial !== null) {
                $binomialBySlug[$slug] = $binomial;
            }

            if ($record === null && $binomial !== null && mb_strtolower($binomial) === mb_strtolower($name)) {
                $record = $candidate;
            }
        }

        if ($record === null) {
            return DraftFacts::none($source, $name);
        }

        $facts = [];

        if (($commonName = $this->string($record['name'] ?? null)) !== null) {
            $facts[] = new Fact('name.en', $commonName);
        }

        if (($rowSpacing = $this->number($record['rowSpacingCm'] ?? null)) !== null && $rowSpacing > 0) {
            $facts[] = new Fact('row_spacing_cm', (int) round($rowSpacing));
        }

        $sun = match (mb_strtolower((string) $this->string($record['sun'] ?? null))) {
            'full sun' => 'full_sun',
            'partial sun', 'partial shade', 'part sun', 'part shade' => 'partial_shade',
            'shade', 'full shade' => 'shade',
            default => null,
        };
        if ($sun !== null) {
            $facts[] = new Fact('sun', $sun);
        }

        foreach ((array) ($record['companions'] ?? []) as $slug) {
            if (is_string($slug) && isset($binomialBySlug[$slug]) && mb_strtolower($binomialBySlug[$slug]) !== mb_strtolower($name)) {
                $facts[] = new Fact('companion', $binomialBySlug[$slug]);
            }
        }

        $origin = is_array($record['source'] ?? null) ? $record['source'] : [];

        return new DraftFacts(
            $source,
            $name,
            $facts,
            $this->string($origin['license'] ?? null) ?? $source->licence(),
            $this->string($origin['waybackUrl'] ?? null, 2048) ?? $source->url(),
            CarbonImmutable::now('UTC'),
        );
    }

    private function trefle(string $name): DraftFacts
    {
        $source = PlantSource::Trefle;
        $token = ['token' => $source->config('token', '')];
        $search = $this->getJson($source, $source->url().'/api/v1/species/search', ['q' => $name] + $token);

        $match = null;
        foreach ((array) ($search['data'] ?? []) as $candidate) {
            if (is_array($candidate) && mb_strtolower((string) $this->string($candidate['scientific_name'] ?? null)) === mb_strtolower($name)) {
                $match = $candidate;
                break;
            }
        }

        $id = $match['id'] ?? null;
        if (! is_int($id)) {
            return DraftFacts::none($source, $name);
        }

        $species = $this->getJson($source, $source->url().'/api/v1/species/'.$id, $token);
        $data = $species['data'] ?? null;
        if (! is_array($data)) {
            return DraftFacts::none($source, $name);
        }

        $growth = is_array($data['growth'] ?? null) ? $data['growth'] : [];
        $facts = [];

        if (($commonName = $this->string($data['common_name'] ?? null)) !== null) {
            $facts[] = new Fact('name.en', $commonName);
        }

        $numbers = [
            'ph_min' => [$growth['ph_minimum'] ?? null, 1],
            'ph_max' => [$growth['ph_maximum'] ?? null, 1],
            'temp_min_c' => [$growth['minimum_temperature']['deg_c'] ?? null, 1],
            'temp_max_c' => [$growth['maximum_temperature']['deg_c'] ?? null, 1],
            'days_to_harvest' => [$growth['days_to_harvest'] ?? null, 0],
            'row_spacing_cm' => [$growth['row_spacing']['cm'] ?? null, 0],
        ];

        foreach ($numbers as $field => [$raw, $precision]) {
            if (($value = $this->number($raw)) !== null) {
                $facts[] = new Fact($field, $precision === 0 ? (int) round($value) : round($value, $precision));
            }
        }

        $slug = $this->string($data['slug'] ?? null) ?? (string) $id;

        // The token is a query parameter of the request only, never part of the recorded URL.
        return $this->facts($source, $name, $facts, $source->url().'/api/v1/species/'.$slug);
    }

    /**
     * @param  list<Fact>  $facts
     */
    private function facts(PlantSource $source, string $name, array $facts, ?string $sourceUrl): DraftFacts
    {
        return new DraftFacts($source, $name, $facts, $source->licence(), $sourceUrl, CarbonImmutable::now('UTC'));
    }

    /**
     * @param  array<string, string>  $query
     * @return array<mixed>|null null when the source answers 404
     *
     * @throws PlantSourceUnavailable
     */
    private function getJson(PlantSource $source, string $url, array $query, string $accept = 'application/json'): ?array
    {
        try {
            $response = $this->request()->accept($accept)->get($url, $query);
        } catch (ConnectionException) {
            throw new PlantSourceUnavailable($source, 'no answer within the time limit or the connection failed');
        }

        if ($response->notFound()) {
            return null;
        }

        if (! $response->successful()) {
            throw new PlantSourceUnavailable($source, "it answered with HTTP {$response->status()}");
        }

        $json = $response->json();

        if (! is_array($json)) {
            throw new PlantSourceUnavailable($source, 'it answered with an unexpected response');
        }

        return $json;
    }

    private function request(): PendingRequest
    {
        $timeout = (int) config('catalogue.import.timeout', 30);

        return Http::timeout($timeout)
            ->connectTimeout($timeout)
            ->withUserAgent((string) config('catalogue.import.user_agent'));
    }

    private function string(mixed $value, int $maxLength = 255): ?string
    {
        if (! is_string($value)) {
            return null;
        }

        $value = trim($value);

        return $value === '' ? null : mb_substr($value, 0, $maxLength);
    }

    private function number(mixed $value): ?float
    {
        return is_int($value) || is_float($value) || (is_string($value) && is_numeric($value)) ? (float) $value : null;
    }
}
