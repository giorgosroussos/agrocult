<?php

namespace App\Modules\Catalogue\Snapshot;

use Normalizer;

/**
 * Search keys of the catalogue snapshot (UC-003), computed on the server when the snapshot is built.
 *
 * A key is a normalised word: lower case, without accents or other diacritics, final sigma
 * written as σ, anything but letters and digits treated as a separator. Every Greek word also
 * gets its Greeklish spellings (e.g. ντομάτα -> ntomata, domata) and, when it starts with ντ,
 * μπ or γκ, the spelling without the nasal (ντομάτα -> τοματα).
 *
 * The app normalises the typed query with normalise() rules and matches each query word
 * as a prefix of a key, so the same rules must be applied on the device.
 */
final class SearchKeys
{
    /** Upper bound of Greeklish spellings kept per word. */
    public const MAX_VARIANTS_PER_WORD = 32;

    /** Human-readable query rules, stored in the snapshot's meta table for the app. */
    public const QUERY_RULES = 'lower case; strip diacritics (Unicode NFD, drop combining marks); '
        .'final sigma (ς) to σ; every character that is not a letter or digit is a separator; '
        .'match each query word as a prefix of a search key (FTS5: "word"*)';

    /** Greek letter pairs read as one sound; the first spelling is the most common one. */
    private const DIGRAPHS = [
        'ου' => ['ou', 'u'],
        'μπ' => ['mp', 'b'],
        'ντ' => ['nt', 'd'],
        'γκ' => ['gk', 'g'],
        'γγ' => ['gg', 'ng'],
        'τσ' => ['ts'],
        'τζ' => ['tz'],
        'αι' => ['ai', 'e'],
        'ει' => ['ei', 'i'],
        'οι' => ['oi', 'i'],
        'υι' => ['yi', 'i'],
        'αυ' => ['av', 'af', 'au'],
        'ευ' => ['ev', 'ef', 'eu'],
    ];

    private const LETTERS = [
        'α' => ['a'],
        'β' => ['v', 'b'],
        'γ' => ['g'],
        'δ' => ['d'],
        'ε' => ['e'],
        'ζ' => ['z'],
        'η' => ['i', 'h'],
        'θ' => ['th', '8'],
        'ι' => ['i'],
        'κ' => ['k'],
        'λ' => ['l'],
        'μ' => ['m'],
        'ν' => ['n'],
        'ξ' => ['x', 'ks'],
        'ο' => ['o'],
        'π' => ['p'],
        'ρ' => ['r'],
        'σ' => ['s'],
        'τ' => ['t'],
        'υ' => ['y', 'i', 'u'],
        'φ' => ['f', 'ph'],
        'χ' => ['x', 'ch', 'h'],
        'ψ' => ['ps'],
        'ω' => ['o', 'w'],
    ];

    /** Word-initial nasal clusters that are also written without the nasal (ντομάτα / τομάτα). */
    private const NASAL_PREFIXES = ['ντ' => 'τ', 'μπ' => 'π', 'γκ' => 'κ'];

    public static function normalise(string $text): string
    {
        $text = mb_strtolower($text, 'UTF-8');

        $decomposed = Normalizer::normalize($text, Normalizer::FORM_D);
        if (is_string($decomposed)) {
            $text = (string) preg_replace('/\p{Mn}+/u', '', $decomposed);
        }

        $text = str_replace('ς', 'σ', $text);
        $text = (string) preg_replace('/[^\p{L}\p{N}]+/u', ' ', $text);

        return trim($text);
    }

    /**
     * Distinct search keys of all given texts (names, aliases, scientific name ...).
     *
     * @param  iterable<string|null>  $texts
     * @return list<string>
     */
    public static function forTexts(iterable $texts): array
    {
        $keys = [];

        foreach ($texts as $text) {
            if ($text === null) {
                continue;
            }

            foreach (self::words(self::normalise($text)) as $word) {
                foreach (self::forWord($word) as $key) {
                    $keys[$key] = true;
                }
            }
        }

        return array_map('strval', array_keys($keys));
    }

    /**
     * @param  iterable<string|null>  $texts
     */
    public static function asText(iterable $texts): string
    {
        return implode(' ', self::forTexts($texts));
    }

    /**
     * @return list<string>
     */
    public static function forWord(string $word): array
    {
        $keys = [$word];

        if (preg_match('/\p{Greek}/u', $word) !== 1) {
            return $keys;
        }

        foreach (self::NASAL_PREFIXES as $prefix => $replacement) {
            if (str_starts_with($word, $prefix) && mb_strlen($word) > 2) {
                $keys[] = $replacement.mb_substr($word, 2);
            }
        }

        return array_values(array_unique(array_merge($keys, self::greeklish($word))));
    }

    /**
     * Greeklish spellings of a normalised Greek word, most common spelling first.
     *
     * @return list<string>
     */
    public static function greeklish(string $word): array
    {
        $chars = mb_str_split($word);
        $count = count($chars);
        $segments = [];

        for ($i = 0; $i < $count; $i++) {
            $pair = $chars[$i].($chars[$i + 1] ?? '');

            if (isset(self::DIGRAPHS[$pair])) {
                $segments[] = self::DIGRAPHS[$pair];
                $i++;

                continue;
            }

            $segments[] = self::LETTERS[$chars[$i]] ?? [$chars[$i]];
        }

        $variants = [''];

        foreach ($segments as $options) {
            $next = [];

            foreach ($variants as $variant) {
                foreach ($options as $option) {
                    $next[] = $variant.$option;
                }
            }

            $variants = array_slice($next, 0, self::MAX_VARIANTS_PER_WORD);
        }

        return array_values(array_unique($variants));
    }

    /**
     * @return list<string>
     */
    private static function words(string $normalised): array
    {
        return $normalised === '' ? [] : explode(' ', $normalised);
    }
}
