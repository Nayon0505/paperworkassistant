import 'dart:typed_data';

import 'package:paperworkassistant/data/document_files/authenticated_file_cipher.dart';
import 'package:paperworkassistant/data/secure_storage/installation_key_manager.dart';

final class MemorySecureValueStore implements SecureValueStore {
  final values = <String, String>{};
  int writes = 0;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    writes++;
    values[key] = value;
  }
}

final class ThrowingFileCipher implements AuthenticatedFileCipher {
  @override
  Future<Uint8List> decrypt(Uint8List envelope, Uint8List key) {
    throw StateError('test cipher failure');
  }

  @override
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List key) {
    throw StateError('test cipher failure');
  }
}
