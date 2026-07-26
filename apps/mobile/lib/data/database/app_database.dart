import 'package:drift/drift.dart';

final class DocumentRecord {
  const DocumentRecord({
    required this.id,
    required this.sourceName,
    required this.status,
    required this.recordVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String sourceName;
  final String status;
  final int recordVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class PageRecord {
  const PageRecord({
    required this.id,
    required this.documentId,
    required this.pageNumber,
    required this.encryptedFileName,
    required this.mimeType,
    this.recordVersion = 1,
  });

  final String id;
  final String documentId;
  final int pageNumber;
  final String encryptedFileName;
  final String mimeType;
  final int recordVersion;
}

final class AnalysisResultRecord {
  const AnalysisResultRecord({
    required this.id,
    required this.documentId,
    required this.summary,
    required this.category,
    this.recordVersion = 1,
  });

  final String id;
  final String documentId;
  final String summary;
  final String category;
  final int recordVersion;
}

final class DeadlineRecord {
  const DeadlineRecord({
    required this.id,
    required this.documentId,
    required this.title,
    required this.dueAt,
    required this.status,
    this.recordVersion = 1,
  });

  final String id;
  final String documentId;
  final String title;
  final DateTime dueAt;
  final String status;
  final int recordVersion;
}

final class NextActionRecord {
  const NextActionRecord({
    required this.id,
    required this.documentId,
    required this.title,
    required this.status,
    required this.sortOrder,
    this.recordVersion = 1,
  });

  final String id;
  final String documentId;
  final String title;
  final String status;
  final int sortOrder;
  final int recordVersion;
}

final class AppDatabase extends GeneratedDatabase {
  AppDatabase(super.executor);

  static const currentSchemaVersion = 1;
  static const tableNames = <String>{
    'documents',
    'pages',
    'analysis_results',
    'deadlines',
    'next_actions',
  };

  static const _schemaStatements = <String>[
    '''
      CREATE TABLE documents (
        id TEXT NOT NULL PRIMARY KEY,
        source_name TEXT NOT NULL,
        status TEXT NOT NULL,
        record_version INTEGER NOT NULL DEFAULT 1 CHECK (record_version >= 1),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''',
    '''
      CREATE TABLE pages (
        id TEXT NOT NULL PRIMARY KEY,
        document_id TEXT NOT NULL,
        page_number INTEGER NOT NULL CHECK (page_number >= 0),
        encrypted_file_name TEXT NOT NULL UNIQUE,
        mime_type TEXT NOT NULL,
        record_version INTEGER NOT NULL DEFAULT 1 CHECK (record_version >= 1),
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
        UNIQUE (document_id, page_number)
      )
    ''',
    '''
      CREATE TABLE analysis_results (
        id TEXT NOT NULL PRIMARY KEY,
        document_id TEXT NOT NULL,
        summary TEXT NOT NULL,
        category TEXT NOT NULL,
        record_version INTEGER NOT NULL DEFAULT 1 CHECK (record_version >= 1),
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
      )
    ''',
    '''
      CREATE TABLE deadlines (
        id TEXT NOT NULL PRIMARY KEY,
        document_id TEXT NOT NULL,
        title TEXT NOT NULL,
        due_at INTEGER NOT NULL,
        status TEXT NOT NULL,
        record_version INTEGER NOT NULL DEFAULT 1 CHECK (record_version >= 1),
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
      )
    ''',
    '''
      CREATE TABLE next_actions (
        id TEXT NOT NULL PRIMARY KEY,
        document_id TEXT NOT NULL,
        title TEXT NOT NULL,
        status TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        record_version INTEGER NOT NULL DEFAULT 1 CHECK (record_version >= 1),
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
      )
    ''',
    'CREATE INDEX pages_document_id ON pages(document_id)',
    '''
      CREATE INDEX analysis_results_document_id
      ON analysis_results(document_id)
    ''',
    'CREATE INDEX deadlines_document_id ON deadlines(document_id)',
    'CREATE INDEX next_actions_document_id ON next_actions(document_id)',
  ];

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  Iterable<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      for (final statement in _schemaStatements) {
        await customStatement(statement);
      }
    },
    onUpgrade: (_, from, to) async {
      throw UnsupportedError(
        'No existing user-data migration exists for schema $from -> $to.',
      );
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> initialize() async {
    await customSelect('SELECT 1 AS ready').getSingle();
  }

  Future<void> insertDocument(DocumentRecord record) async {
    await customInsert(
      '''
        INSERT INTO documents (
          id, source_name, status, record_version, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(record.id),
        Variable<String>(record.sourceName),
        Variable<String>(record.status),
        Variable<int>(record.recordVersion),
        Variable<int>(record.createdAt.toUtc().millisecondsSinceEpoch),
        Variable<int>(record.updatedAt.toUtc().millisecondsSinceEpoch),
      ],
    );
  }

  Future<void> insertPage(PageRecord record) async {
    await customInsert(
      '''
        INSERT INTO pages (
          id, document_id, page_number, encrypted_file_name, mime_type,
          record_version
        ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(record.id),
        Variable<String>(record.documentId),
        Variable<int>(record.pageNumber),
        Variable<String>(record.encryptedFileName),
        Variable<String>(record.mimeType),
        Variable<int>(record.recordVersion),
      ],
    );
  }

  Future<void> insertAnalysisResult(AnalysisResultRecord record) async {
    await customInsert(
      '''
        INSERT INTO analysis_results (
          id, document_id, summary, category, record_version
        ) VALUES (?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(record.id),
        Variable<String>(record.documentId),
        Variable<String>(record.summary),
        Variable<String>(record.category),
        Variable<int>(record.recordVersion),
      ],
    );
  }

  Future<void> insertDeadline(DeadlineRecord record) async {
    await customInsert(
      '''
        INSERT INTO deadlines (
          id, document_id, title, due_at, status, record_version
        ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(record.id),
        Variable<String>(record.documentId),
        Variable<String>(record.title),
        Variable<int>(record.dueAt.toUtc().millisecondsSinceEpoch),
        Variable<String>(record.status),
        Variable<int>(record.recordVersion),
      ],
    );
  }

  Future<void> insertNextAction(NextActionRecord record) async {
    await customInsert(
      '''
        INSERT INTO next_actions (
          id, document_id, title, status, sort_order, record_version
        ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(record.id),
        Variable<String>(record.documentId),
        Variable<String>(record.title),
        Variable<String>(record.status),
        Variable<int>(record.sortOrder),
        Variable<int>(record.recordVersion),
      ],
    );
  }

  Future<DocumentRecord?> documentById(String id) async {
    final row = await customSelect(
      '''
        SELECT id, source_name, status, record_version, created_at, updated_at
        FROM documents
        WHERE id = ?
      ''',
      variables: [Variable<String>(id)],
    ).getSingleOrNull();
    if (row == null) {
      return null;
    }

    return DocumentRecord(
      id: row.read<String>('id'),
      sourceName: row.read<String>('source_name'),
      status: row.read<String>('status'),
      recordVersion: row.read<int>('record_version'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('created_at'),
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('updated_at'),
        isUtc: true,
      ),
    );
  }

  Future<List<PageRecord>> pagesForDocument(String documentId) async {
    final rows = await customSelect(
      '''
        SELECT id, document_id, page_number, encrypted_file_name, mime_type,
               record_version
        FROM pages
        WHERE document_id = ?
        ORDER BY page_number
      ''',
      variables: [Variable<String>(documentId)],
    ).get();

    return rows
        .map(
          (row) => PageRecord(
            id: row.read<String>('id'),
            documentId: row.read<String>('document_id'),
            pageNumber: row.read<int>('page_number'),
            encryptedFileName: row.read<String>('encrypted_file_name'),
            mimeType: row.read<String>('mime_type'),
            recordVersion: row.read<int>('record_version'),
          ),
        )
        .toList(growable: false);
  }

  Future<void> updateDocumentStatus(
    String id,
    String status, {
    required DateTime updatedAt,
  }) async {
    final changed = await customUpdate(
      '''
        UPDATE documents
        SET status = ?, updated_at = ?, record_version = record_version + 1
        WHERE id = ?
      ''',
      variables: [
        Variable<String>(status),
        Variable<int>(updatedAt.toUtc().millisecondsSinceEpoch),
        Variable<String>(id),
      ],
    );
    if (changed != 1) {
      throw StateError('Document $id does not exist.');
    }
  }

  Future<void> deleteDocument(String id) async {
    await customUpdate(
      'DELETE FROM documents WHERE id = ?',
      variables: [Variable<String>(id)],
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> rowCount(String tableName) async {
    if (!tableNames.contains(tableName)) {
      throw ArgumentError.value(tableName, 'tableName', 'Unknown table.');
    }
    final row = await customSelect(
      'SELECT COUNT(*) AS row_count FROM $tableName',
    ).getSingle();
    return row.read<int>('row_count');
  }
}
