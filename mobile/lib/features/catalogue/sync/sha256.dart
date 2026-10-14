import 'dart:io';
import 'dart:typed_data';

/// SHA-256 (FIPS 180-4), used to verify a downloaded catalogue snapshot
/// against the checksum the server announces. Small and dependency-free so
/// that no package outside the approved list is needed.
class Sha256 {
  final _state = Uint32List.fromList(_initial);
  final _block = Uint8List(64);
  final _w = Uint32List(64);
  int _blockLength = 0;
  int _messageLength = 0;
  bool _closed = false;

  /// Hex digest of a file, read in chunks.
  static Future<String> ofFile(File file) async {
    final hash = Sha256();
    await for (final chunk in file.openRead()) {
      hash.add(chunk);
    }
    return hash.hexDigest();
  }

  /// Hex digest of [bytes].
  static String ofBytes(List<int> bytes) => (Sha256()..add(bytes)).hexDigest();

  void add(List<int> bytes) {
    if (_closed) throw StateError('The digest was already computed');
    _messageLength += bytes.length;
    for (final byte in bytes) {
      _block[_blockLength++] = byte;
      if (_blockLength == 64) {
        _compress();
        _blockLength = 0;
      }
    }
  }

  String hexDigest() {
    if (!_closed) _finish();
    final buffer = StringBuffer();
    for (final word in _state) {
      buffer.write(word.toRadixString(16).padLeft(8, '0'));
    }
    return buffer.toString();
  }

  void _finish() {
    final bitLength = _messageLength * 8;
    _block[_blockLength++] = 0x80;
    if (_blockLength > 56) {
      _block.fillRange(_blockLength, 64, 0);
      _compress();
      _blockLength = 0;
    }
    _block.fillRange(_blockLength, 56, 0);
    for (var i = 0; i < 8; i++) {
      _block[63 - i] = (bitLength >> (8 * i)) & 0xff;
    }
    _compress();
    _closed = true;
  }

  void _compress() {
    final w = _w;
    for (var i = 0; i < 16; i++) {
      w[i] =
          (_block[i * 4] << 24) |
          (_block[i * 4 + 1] << 16) |
          (_block[i * 4 + 2] << 8) |
          _block[i * 4 + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & _mask;
    }

    var a = _state[0], b = _state[1], c = _state[2], d = _state[3];
    var e = _state[4], f = _state[5], g = _state[6], h = _state[7];
    for (var i = 0; i < 64; i++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ ((~e & _mask) & g);
      final t1 = (h + s1 + ch + _k[i] + w[i]) & _mask;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final t2 = (s0 + maj) & _mask;
      h = g;
      g = f;
      f = e;
      e = (d + t1) & _mask;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & _mask;
    }
    _state[0] += a;
    _state[1] += b;
    _state[2] += c;
    _state[3] += d;
    _state[4] += e;
    _state[5] += f;
    _state[6] += g;
    _state[7] += h;
  }

  static int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & _mask;

  static const _mask = 0xffffffff;

  static const _initial = [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, //
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
  ];

  static const _k = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, //
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];
}
