import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperworkassistant/data/secure_storage/installation_key_manager.dart';

import '../test_support.dart';

void main() {
  test('creates one installation key and reuses it across managers', () async {
    final store = MemorySecureValueStore();
    final firstManager = InstallationKeyManager(store, random: Random(7));

    final first = await firstManager.loadOrCreate();
    final second = await InstallationKeyManager(
      store,
      random: Random(99),
    ).loadOrCreate();

    expect(first, hasLength(InstallationKeyManager.keyLength));
    expect(second, orderedEquals(first));
    expect(store.writes, 1);
  });

  test('shares an in-flight first-start key generation', () async {
    final store = MemorySecureValueStore();
    final manager = InstallationKeyManager(store, random: Random(7));

    final keys = await Future.wait([
      manager.loadOrCreate(),
      manager.loadOrCreate(),
      manager.loadOrCreate(),
    ]);

    expect(keys[1], orderedEquals(keys[0]));
    expect(keys[2], orderedEquals(keys[0]));
    expect(store.writes, 1);
  });

  test('rejects a malformed persisted key instead of replacing it', () async {
    final store = MemorySecureValueStore();
    store.values['local_data_key_v1'] = base64UrlEncode([1, 2, 3]);

    await expectLater(
      InstallationKeyManager(store).loadOrCreate(),
      throwsA(isA<StateError>()),
    );
    expect(store.writes, 0);
  });
}
