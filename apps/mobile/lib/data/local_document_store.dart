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
      try {
        await _fileStore.markCommitted(encryptedFileName);
      } catch (_) {
        // The pending marker is safe to retain: startup reconciliation checks
        // the committed database row before removing it.
      }
      return page;
    } catch (error, stackTrace) {
      try {
        await _fileStore.delete(encryptedFileName);
      } catch (_) {
        // The pending marker remains durable for startup reconciliation.
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final pages = await _database.pagesForDocument(documentId);
    Object? firstFailure;
    StackTrace? firstFailureStackTrace;
    for (final page in pages) {
      try {
        await _fileStore.delete(page.encryptedFileName);
      } catch (error, stackTrace) {
        firstFailure ??= error;
        firstFailureStackTrace ??= stackTrace;
      }
    }
    if (firstFailure != null) {
      Error.throwWithStackTrace(firstFailure, firstFailureStackTrace!);
    }
    await _database.deleteDocument(documentId);
  }
}
