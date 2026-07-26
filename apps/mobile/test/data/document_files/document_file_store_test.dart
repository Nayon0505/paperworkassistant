import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperworkassistant/data/document_files/backup_exclusion.dart';
import 'package:paperworkassistant/data/document_files/document_file_store.dart';
import 'package:paperworkassistant/data/secure_storage/installation_key_manager.dart';

import '../test_support.dart';

void main() {
  late Directory temporaryDirectory;
  late DocumentFileStore fileStore;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'paperwork-file-store-',
    );
    fileStore = DocumentFileStore(
      rootDirectory: Directory('${temporaryDirectory.path}/documents'),
      keyManager: InstallationKeyManager(
        MemorySecureValueStore(),
        random: Random(3),
      ),
      backupExclusion: const NoopBackupExclusion(),
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('stores only authenticated ciphertext and deletes plaintext', () async {
    final plaintext = File('${temporaryDirectory.path}/import.tmp');
    final content = utf8.encode('confidential original page');
    await plaintext.writeAsBytes(content);

    final encryptedName = await fileStore.storeFromPlaintextFile(
      plaintext,
      pageId: 'page-1',
    );

    expect(await plaintext.exists(), isFalse);
    expect(await fileStore.read(encryptedName), orderedEquals(content));
    final encrypted = await fileStore
        .encryptedFile(encryptedName)
        .readAsBytes();
    expect(
      utf8.decode(encrypted, allowMalformed: true),
      isNot(contains('confidential')),
    );
  });

  test('deletes plaintext and work files after encryption failure', () async {
    final plaintext = File('${temporaryDirectory.path}/import.tmp');
    await plaintext.writeAsString('must disappear');
    final failingStore = DocumentFileStore(
      rootDirectory: Directory('${temporaryDirectory.path}/documents'),
      keyManager: InstallationKeyManager(
        MemorySecureValueStore(),
        random: Random(3),
      ),
      cipher: ThrowingFileCipher(),
      backupExclusion: const NoopBackupExclusion(),
    );

    await expectLater(
      failingStore.storeFromPlaintextFile(plaintext, pageId: 'page-1'),
      throwsStateError,
    );

    expect(await plaintext.exists(), isFalse);
    final documentsDirectory = Directory(
      '${temporaryDirectory.path}/documents',
    );
    expect(
      documentsDirectory.existsSync()
          ? documentsDirectory.listSync()
          : <FileSystemEntity>[],
      isEmpty,
    );
  });

  test('deletes plaintext after cancellation', () async {
    final plaintext = File('${temporaryDirectory.path}/import.tmp');
    await plaintext.writeAsString('must disappear');
    final token = CancellationToken()..cancel();

    await expectLater(
      fileStore.storeFromPlaintextFile(
        plaintext,
        pageId: 'page-1',
        cancellationToken: token,
      ),
      throwsA(isA<OperationCancelledException>()),
    );

    expect(await plaintext.exists(), isFalse);
  });
}
