import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

abstract interface class AuthenticatedFileCipher {
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List key);

  Future<Uint8List> decrypt(Uint8List envelope, Uint8List key);
}

final class AesGcmFileCipher implements AuthenticatedFileCipher {
  AesGcmFileCipher({AesGcm? algorithm})
    : _algorithm = algorithm ?? AesGcm.with256bits();

  static const _magic = <int>[0x50, 0x57, 0x41, 0x01]; // "PWA" + format v1
  static const _nonceLength = 12;
  static const _macLength = 16;
  static const _headerLength = 4;

  final AesGcm _algorithm;

  @override
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List key) async {
    _validateKey(key);
    final nonce = _algorithm.newNonce();
    final box = await _algorithm.encrypt(
      plaintext,
      secretKey: SecretKey(key),
      nonce: nonce,
    );

    return Uint8List.fromList([
      ..._magic,
      ...box.nonce,
      ...box.mac.bytes,
      ...box.cipherText,
    ]);
  }

  @override
  Future<Uint8List> decrypt(Uint8List envelope, Uint8List key) async {
    _validateKey(key);
    final minimumLength = _headerLength + _nonceLength + _macLength;
    if (envelope.length < minimumLength ||
        !_hasExpectedMagic(envelope.sublist(0, _headerLength))) {
      throw const FormatException('Unsupported encrypted document format.');
    }

    final nonceStart = _headerLength;
    final macStart = nonceStart + _nonceLength;
    final cipherTextStart = macStart + _macLength;
    final box = SecretBox(
      envelope.sublist(cipherTextStart),
      nonce: envelope.sublist(nonceStart, macStart),
      mac: Mac(envelope.sublist(macStart, cipherTextStart)),
    );
    final plaintext = await _algorithm.decrypt(box, secretKey: SecretKey(key));
    return Uint8List.fromList(plaintext);
  }

  bool _hasExpectedMagic(List<int> candidate) {
    if (candidate.length != _magic.length) {
      return false;
    }
    for (var index = 0; index < _magic.length; index++) {
      if (candidate[index] != _magic[index]) {
        return false;
      }
    }
    return true;
  }

  void _validateKey(Uint8List key) {
    if (key.length != 32) {
      throw ArgumentError.value(key.length, 'key', 'Must be 32 bytes.');
    }
  }
}
