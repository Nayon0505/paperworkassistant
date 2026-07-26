import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperworkassistant/data/document_files/authenticated_file_cipher.dart';

void main() {
  final key = Uint8List.fromList(List<int>.generate(32, (index) => index));
  final plaintext = Uint8List.fromList(
    utf8.encode('private original page content'),
  );

  test('AES-GCM envelope round-trips without plaintext at rest', () async {
    final cipher = AesGcmFileCipher();

    final encrypted = await cipher.encrypt(plaintext, key);
    final decrypted = await cipher.decrypt(encrypted, key);

    expect(decrypted, orderedEquals(plaintext));
    expect(_contains(encrypted, plaintext), isFalse);
  });

  test('AES-GCM rejects modified ciphertext', () async {
    final cipher = AesGcmFileCipher();
    final encrypted = await cipher.encrypt(plaintext, key);
    encrypted[encrypted.length - 1] ^= 0x01;

    await expectLater(
      cipher.decrypt(encrypted, key),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });
}

bool _contains(List<int> bytes, List<int> needle) {
  for (var start = 0; start <= bytes.length - needle.length; start++) {
    var matches = true;
    for (var offset = 0; offset < needle.length; offset++) {
      if (bytes[start + offset] != needle[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) {
      return true;
    }
  }
  return false;
}
