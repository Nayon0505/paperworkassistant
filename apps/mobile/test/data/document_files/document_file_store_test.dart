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

  test('attempts plaintext cleanup when work-file cleanup fails', () async {
    final plaintext = File('${temporaryDirectory.path}/import.tmp');
    await plaintext.writeAsString('must disappear');
    final token = CancellationToken();
    final attemptedCleanup = <String>[];
    final failingCleanupStore = DocumentFileStore(
      rootDirectory: Directory('${temporaryDirectory.path}/documents'),
      keyManager: InstallationKeyManager(
        MemorySecureValueStore(),
        random: Random(4),
      ),
      backupExclusion: const NoopBackupExclusion(),
      writeWorkFile: (file, bytes) async {
        await file.writeAsBytes(bytes, flush: true);
        token.cancel();
      },
      deleteTemporaryFile: (file) async {
        attemptedCleanup.add(file.path);
        if (file.path.endsWith('.work')) {
          throw FileSystemException(
            'simulated work cleanup failure',
            file.path,
          );
        }
        await file.delete();
      },
    );

    await expectLater(
      failingCleanupStore.storeFromPlaintextFile(
        plaintext,
        pageId: 'page-1',
        cancellationToken: token,
      ),
      throwsA(isA<OperationCancelledException>()),
    );

    expect(attemptedCleanup, hasLength(2));
    expect(attemptedCleanup.first, endsWith('.work'));
    expect(attemptedCleanup.last, plaintext.path);
    expect(await plaintext.exists(), isFalse);
    final documentsDirectory = Directory(
      '${temporaryDirectory.path}/documents',
    );
    expect(
      documentsDirectory.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.work'),
      ),
      hasLength(1),
    );
    expect(
      documentsDirectory.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.pwa.pending'),
      ),
      hasLength(1),
    );

    final recoveryStore = DocumentFileStore(
      rootDirectory: documentsDirectory,
      keyManager: InstallationKeyManager(
        MemorySecureValueStore(),
        random: Random(4),
      ),
      backupExclusion: const NoopBackupExclusion(),
    );
    await recoveryStore.reconcilePendingFiles((_) async => false);

    expect(documentsDirectory.listSync(), isEmpty);
  });
}
