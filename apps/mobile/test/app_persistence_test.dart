import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperworkassistant/app_persistence.dart';
import 'package:paperworkassistant/data/database/app_database.dart';
import 'package:paperworkassistant/data/document_files/backup_exclusion.dart';

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
}
