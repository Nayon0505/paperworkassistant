import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperworkassistant/data/database/app_database.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'paperwork-database-',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'schema migration 0 -> 1 creates every versioned record table',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await database.initialize();

      final version = await database
          .customSelect('PRAGMA user_version')
          .getSingle();
      final tables = await database.customSelect('''
            SELECT name
            FROM sqlite_master
            WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
          ''').get();

      expect(
        version.read<int>('user_version'),
        AppDatabase.currentSchemaVersion,
      );
      expect(
        tables.map((row) => row.read<String>('name')).toSet(),
        AppDatabase.tableNames,
      );
    },
  );

  test('records and updated status survive a database restart', () async {
    final databaseFile = File('${temporaryDirectory.path}/restart.sqlite');
    final createdAt = DateTime.utc(2026, 7, 26, 12);
    var database = AppDatabase(NativeDatabase(databaseFile));
    await database.initialize();
    await _insertCompleteDocument(database, createdAt);
    await database.updateDocumentStatus(
      'document-1',
      'analyzed',
      updatedAt: createdAt.add(const Duration(minutes: 5)),
    );
    await database.close();

    database = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(database.close);
    final document = await database.documentById('document-1');
    final pages = await database.pagesForDocument('document-1');

    expect(document, isNotNull);
    expect(document!.status, 'analyzed');
    expect(document.recordVersion, 2);
    expect(pages.single.encryptedFileName, 'page-1.pwa');
    expect(await database.rowCount('analysis_results'), 1);
    expect(await database.rowCount('deadlines'), 1);
    expect(await database.rowCount('next_actions'), 1);
  });

  test('deleting a document cascades through all related records', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.initialize();
    await _insertCompleteDocument(database, DateTime.utc(2026, 7, 26));

    await database.deleteDocument('document-1');

    for (final tableName in AppDatabase.tableNames) {
      expect(
        await database.rowCount(tableName),
        0,
        reason: '$tableName should be empty',
      );
    }
  });
}

Future<void> _insertCompleteDocument(
  AppDatabase database,
  DateTime createdAt,
) async {
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
  await database.insertPage(
    const PageRecord(
      id: 'page-1',
      documentId: 'document-1',
      pageNumber: 0,
      encryptedFileName: 'page-1.pwa',
      mimeType: 'application/pdf',
    ),
  );
  await database.insertAnalysisResult(
    const AnalysisResultRecord(
      id: 'analysis-1',
      documentId: 'document-1',
      summary: 'A private summary',
      category: 'invoice',
    ),
  );
  await database.insertDeadline(
    DeadlineRecord(
      id: 'deadline-1',
      documentId: 'document-1',
      title: 'Reply',
      dueAt: createdAt.add(const Duration(days: 14)),
      status: 'open',
    ),
  );
  await database.insertNextAction(
    const NextActionRecord(
      id: 'action-1',
      documentId: 'document-1',
      title: 'Prepare response',
      status: 'open',
      sortOrder: 0,
    ),
  );
}
