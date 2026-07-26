import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperworkassistant/data/database/app_database.dart';
import 'package:paperworkassistant/data/document_files/backup_exclusion.dart';
import 'package:paperworkassistant/data/document_files/document_file_store.dart';
import 'package:paperworkassistant/data/local_document_store.dart';
import 'package:paperworkassistant/data/secure_storage/installation_key_manager.dart';

import 'test_support.dart';

void main() {
  test(
    'document deletion removes related rows and encrypted originals',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'paperwork-local-store-',
      );
      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database.initialize();
      final fileStore = DocumentFileStore(
        rootDirectory: Directory('${directory.path}/documents'),
        keyManager: InstallationKeyManager(
          MemorySecureValueStore(),
          random: Random(8),
        ),
        backupExclusion: const NoopBackupExclusion(),
      );
      final store = LocalDocumentStore(
        database: database,
        fileStore: fileStore,
      );
      final createdAt = DateTime.utc(2026, 7, 26);
      await database.insertDocument(
        DocumentRecord(
          id: 'document-1',
          sourceName: 'letter.pdf',
          status: 'imported',
          recordVersion: 1,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
      final plaintextFile = File('${directory.path}/import.tmp');
      await plaintextFile.writeAsString('original page');
      final page = await store.addPageFromTemporaryFile(
        documentId: 'document-1',
        pageId: 'page-1',
        pageNumber: 0,
        mimeType: 'application/pdf',
        plaintextFile: plaintextFile,
      );
      await database.insertAnalysisResult(
        const AnalysisResultRecord(
          id: 'analysis-1',
          documentId: 'document-1',
          summary: 'summary',
          category: 'letter',
        ),
      );
      await database.insertDeadline(
        DeadlineRecord(
          id: 'deadline-1',
          documentId: 'document-1',
          title: 'Reply',
          dueAt: createdAt.add(const Duration(days: 7)),
          status: 'open',
        ),
      );
      await database.insertNextAction(
        const NextActionRecord(
          id: 'action-1',
          documentId: 'document-1',
          title: 'Respond',
          status: 'open',
          sortOrder: 0,
        ),
      );
      final encryptedFile = fileStore.encryptedFile(page.encryptedFileName);
      expect(await encryptedFile.exists(), isTrue);

      await store.deleteDocument('document-1');

      for (final tableName in AppDatabase.tableNames) {
        expect(await database.rowCount(tableName), 0);
      }
      expect(await encryptedFile.exists(), isFalse);
    },
  );
}
