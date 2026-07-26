import 'dart:io';

import 'database/app_database.dart';
import 'document_files/document_file_store.dart';

final class LocalDocumentStore {
  const LocalDocumentStore({required this._database, required this._fileStore});

  final AppDatabase _database;
  final DocumentFileStore _fileStore;

  Future<PageRecord> addPageFromTemporaryFile({
    required String documentId,
    required String pageId,
    required int pageNumber,
    required String mimeType,
    required File plaintextFile,
    CancellationToken? cancellationToken,
  }) async {
    final encryptedFileName = await _fileStore.storeFromPlaintextFile(
      plaintextFile,
      pageId: pageId,
      cancellationToken: cancellationToken,
    );
    final page = PageRecord(
      id: pageId,
      documentId: documentId,
      pageNumber: pageNumber,
      encryptedFileName: encryptedFileName,
      mimeType: mimeType,
    );

    try {
      await _database.insertPage(page);
      return page;
    } catch (_) {
      await _fileStore.delete(encryptedFileName);
      rethrow;
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final pages = await _database.pagesForDocument(documentId);
    await _database.deleteDocument(documentId);
    for (final page in pages) {
      await _fileStore.delete(page.encryptedFileName);
    }
  }
}
