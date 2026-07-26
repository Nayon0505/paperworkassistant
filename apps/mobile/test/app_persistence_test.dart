import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperworkassistant/app_persistence.dart';
import 'package:paperworkassistant/data/database/app_database.dart';
import 'package:paperworkassistant/data/document_files/backup_exclusion.dart';
import 'package:paperworkassistant/data/document_files/document_file_store.dart';
import 'package:paperworkassistant/data/secure_storage/installation_key_manager.dart';

import 'data/test_support.dart';

void main() {
  test(
    'production bootstrap creates first-launch storage and reuses it on restart',
    () async {
      final supportDirectory = await Directory.systemTemp.createTemp(
        'paperwork-app-persistence-',
      );
      addTearDown(() async {
        if (await supportDirectory.exists()) {
          await supportDirectory.delete(recursive: true);
        }
      });
      final secureStore = MemorySecureValueStore();
      final createdAt = DateTime.utc(2026, 7, 26);

      var persistence = await AppPersistence.initialize(
        secureValueStore: secureStore,
        supportDirectoryProvider: () async => supportDirectory,
        backupExclusion: const NoopBackupExclusion(),
        random: Random(7),
      );
      await persistence.database.insertDocument(
        DocumentRecord(
          id: 'restart-document',
          sourceName: 'restart.pdf',
          status: 'imported',
          recordVersion: 1,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
      await persistence.close();

      final databaseFile = File(
        '${supportDirectory.path}/paperwork_assistant/no_backup/documents.sqlite',
      );
      expect(await databaseFile.exists(), isTrue);
      expect(secureStore.writes, 1);

      persistence = await AppPersistence.initialize(
        secureValueStore: secureStore,
        supportDirectoryProvider: () async => supportDirectory,
        backupExclusion: const NoopBackupExclusion(),
        random: Random(99),
      );
      addTearDown(persistence.close);

      final restored = await persistence.database.documentById(
        'restart-document',
      );
      expect(restored?.status, 'imported');
      expect(secureStore.writes, 1);
    },
  );

  test('startup removes an abandoned encrypted-file transition', () async {
    final supportDirectory = await Directory.systemTemp.createTemp(
      'paperwork-pending-recovery-',
    );
    addTearDown(() async {
      if (await supportDirectory.exists()) {
        await supportDirectory.delete(recursive: true);
      }
    });
    final secureStore = MemorySecureValueStore();
    final documentDirectory = Directory(
      '${supportDirectory.path}/paperwork_assistant/no_backup/document_pages',
    );
    final interruptedFileStore = DocumentFileStore(
      rootDirectory: documentDirectory,
      keyManager: InstallationKeyManager(secureStore, random: Random(21)),
      backupExclusion: const NoopBackupExclusion(),
      random: Random(22),
    );
    final plaintext = File('${supportDirectory.path}/abandoned.tmp');
    await plaintext.writeAsString('abandoned ciphertext');
    final abandonedName = await interruptedFileStore.storeFromPlaintextFile(
      plaintext,
      pageId: 'abandoned-page',
    );
    final abandonedFile = interruptedFileStore.encryptedFile(abandonedName);

    expect(await abandonedFile.exists(), isTrue);
    expect(await File('${abandonedFile.path}.pending').exists(), isTrue);

    final persistence = await AppPersistence.initialize(
      secureValueStore: secureStore,
      supportDirectoryProvider: () async => supportDirectory,
      backupExclusion: const NoopBackupExclusion(),
      random: Random(23),
    );
    addTearDown(persistence.close);

    expect(await abandonedFile.exists(), isFalse);
    expect(await File('${abandonedFile.path}.pending').exists(), isFalse);
  });

  test('startup keeps a committed file with a pending marker', () async {
    final supportDirectory = await Directory.systemTemp.createTemp(
      'paperwork-committed-recovery-',
    );
    addTearDown(() async {
      if (await supportDirectory.exists()) {
        await supportDirectory.delete(recursive: true);
      }
    });
    final secureStore = MemorySecureValueStore();
    final createdAt = DateTime.utc(2026, 7, 26);
    var persistence = await AppPersistence.initialize(
      secureValueStore: secureStore,
      supportDirectoryProvider: () async => supportDirectory,
      backupExclusion: const NoopBackupExclusion(),
      random: Random(31),
    );
    await persistence.database.insertDocument(
      DocumentRecord(
        id: 'committed-document',
        sourceName: 'committed.pdf',
        status: 'imported',
        recordVersion: 1,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
    final documentDirectory = Directory(
      '${supportDirectory.path}/paperwork_assistant/no_backup/document_pages',
    );
    final interruptedFileStore = DocumentFileStore(
      rootDirectory: documentDirectory,
      keyManager: InstallationKeyManager(secureStore, random: Random(32)),
      backupExclusion: const NoopBackupExclusion(),
      random: Random(33),
    );
    final plaintext = File('${supportDirectory.path}/committed.tmp');
    await plaintext.writeAsString('committed ciphertext');
    final committedName = await interruptedFileStore.storeFromPlaintextFile(
      plaintext,
      pageId: 'committed-page',
    );
    final committedFile = interruptedFileStore.encryptedFile(committedName);
    await persistence.database.insertPage(
      PageRecord(
        id: 'committed-page',
        documentId: 'committed-document',
        pageNumber: 0,
        encryptedFileName: committedName,
        mimeType: 'application/pdf',
      ),
    );
    await persistence.close();

    expect(await committedFile.exists(), isTrue);
    expect(await File('${committedFile.path}.pending').exists(), isTrue);

    persistence = await AppPersistence.initialize(
      secureValueStore: secureStore,
      supportDirectoryProvider: () async => supportDirectory,
      backupExclusion: const NoopBackupExclusion(),
      random: Random(34),
    );
    addTearDown(persistence.close);

    expect(await committedFile.exists(), isTrue);
    expect(await File('${committedFile.path}.pending').exists(), isFalse);
    expect(
      await interruptedFileStore.read(committedName),
      orderedEquals('committed ciphertext'.codeUnits),
    );
  });
}
