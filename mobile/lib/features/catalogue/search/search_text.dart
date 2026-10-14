/// Normalisation of a typed search query (UC-003).
///
/// Applies the query rules the server used when it built the search keys of
/// the snapshot (`SearchKeys::QUERY_RULES`, also stored in the snapshot's
/// meta table): lower case, no diacritics, final sigma written as σ, every
/// character that is not a letter or digit is a separator. Each query word
/// then matches as a prefix of a search key.
library;

/// Accented letters and their base letter. Covers Greek (tonos, dialytika)
/// and the Latin letters used in plant and settlement names; the FTS
/// tokenizer also strips Latin diacritics, but not Greek ones.
const _baseLetters = {
  'ά': 'α',
  'έ': 'ε',
  'ή': 'η',
  'ί': 'ι',
  'ό': 'ο',
  'ύ': 'υ',
  'ώ': 'ω',
  'ϊ': 'ι',
  'ϋ': 'υ',
  'ΐ': 'ι',
  'ΰ': 'υ',
  'ς': 'σ',
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
};

final _combiningMarks = RegExp(r'\p{M}+', unicode: true);
final _separators = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

/// The normalised words of [text], in order; empty when there is nothing to
/// search for.
List<String> searchWords(String text) {
  final lower = text.toLowerCase().replaceAll(_combiningMarks, '');
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_baseLetters[char] ?? char);
  }
  return buffer
      .toString()
      .split(_separators)
      .where((word) => word.isNotEmpty)
      .toList();
}

/// The FTS5 match expression for [text]: every word as a prefix
/// (`"word"*`), all words required; null when [text] has no words.
String? ftsMatchExpression(String text) {
  final words = searchWords(text);
  if (words.isEmpty) return null;
  // Words contain only letters and digits, so quoting needs no escaping.
  return words.map((word) => '"$word"*').join(' ');
}
