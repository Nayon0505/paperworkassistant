import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}

final class FlutterSecureValueStore implements SecureValueStore {
  FlutterSecureValueStore({
    this._storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        storageNamespace: 'paperwork_assistant_installation',
        enforceBiometrics: false,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        synchronizable: false,
      ),
    ),
  });

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

final class InstallationKeyManager {
  InstallationKeyManager(this._store, {Random? random})
    : _random = random ?? Random.secure();

  static const keyLength = 32;
  static const _storageKey = 'local_data_key_v1';

  final SecureValueStore _store;
  final Random _random;
  Future<Uint8List>? _pendingKey;

  Future<Uint8List> loadOrCreate() =>
      _pendingKey ??= _loadOrCreate().whenComplete(() => _pendingKey = null);

  Future<Uint8List> _loadOrCreate() async {
    final stored = await _store.read(_storageKey);
    if (stored != null) {
      return _decodeAndValidate(stored);
    }

    final generated = Uint8List.fromList(
      List<int>.generate(keyLength, (_) => _random.nextInt(256)),
    );
    await _store.write(_storageKey, base64UrlEncode(generated));

    // Read back the platform-protected value so callers never proceed after a
    // storage implementation silently failed to persist it.
    final persisted = await _store.read(_storageKey);
    if (persisted == null) {
      throw StateError('The installation key could not be persisted.');
    }
    return _decodeAndValidate(persisted);
  }

  Uint8List _decodeAndValidate(String encoded) {
    late final Uint8List decoded;
    try {
      decoded = base64Url.decode(encoded);
    } on FormatException {
      throw StateError('The persisted installation key is malformed.');
    }

    if (decoded.length != keyLength) {
      throw StateError('The persisted installation key has an invalid length.');
    }
    return Uint8List.fromList(decoded);
  }
}
