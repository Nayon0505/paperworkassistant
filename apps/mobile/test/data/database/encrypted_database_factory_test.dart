import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperworkassistant/data/database/app_database.dart';
import 'package:paperworkassistant/data/database/encrypted_database_factory.dart';
import 'package:paperworkassistant/data/document_files/backup_exclusion.dart';
import 'package:paperworkassistant/data/secure_storage/installation_key_manager.dart';

import '../test_support.dart';

void main() {
  test(
    'encrypted database remains readable after restart with the same key',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'paperwork-encrypted-database-',
      );
      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });
      final keyManager = InstallationKeyManager(
        MemorySecureValueStore(),
        random: Random(5),
      );
      final factory = EncryptedDatabaseFactory(
        keyManager: keyManager,
        supportDirectoryProvider: () async => directory,
        backupExclusion: const NoopBackupExclusion(),
      );
      const secretMarker = 'sensitive-database-marker';
      final createdAt = DateTime.utc(2026, 7, 26);

      var database = await factory.open();
      await database.insertDocument(
        DocumentRecord(
          id: 'document-1',
          sourceName: secretMarker,
          status: 'imported',
          recordVersion: 1,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
      await database.close();

      final databaseFile = File(
        '${directory.path}/paperwork_assistant/no_backup/documents.sqlite',
      );
      final bytes = await databaseFile.readAsBytes();
      expect(
        latin1.decode(bytes, allowInvalid: true),
        isNot(contains(secretMarker)),
      );
      expect(
        latin1.decode(bytes.take(16).toList(), allowInvalid: true),
        isNot('SQLite format 3\u0000'),
      );

      database = await factory.open();
      addTearDown(database.close);
      final persisted = await database.documentById('document-1');
      expect(persisted?.sourceName, secretMarker);
      expect(persisted?.status, 'imported');
    },
  );
}
