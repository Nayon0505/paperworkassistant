import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'data/database/app_database.dart';
import 'data/database/encrypted_database_factory.dart';
import 'data/document_files/backup_exclusion.dart';
import 'data/document_files/document_file_store.dart';
import 'data/local_document_store.dart';
import 'data/secure_storage/installation_key_manager.dart';

final class AppPersistence {
  AppPersistence._({required this.database, required this.documents});

  final AppDatabase database;
  final LocalDocumentStore documents;

  static Future<AppPersistence> initialize({
    SecureValueStore? secureValueStore,
    SupportDirectoryProvider? supportDirectoryProvider,
    BackupExclusion backupExclusion = const PlatformBackupExclusion(),
    Random? random,
  }) async {
    final directoryProvider =
        supportDirectoryProvider ?? getApplicationSupportDirectory;
    final supportDirectory = await directoryProvider();
    final keyManager = InstallationKeyManager(
      secureValueStore ?? FlutterSecureValueStore(),
      random: random,
    );
    final database = await EncryptedDatabaseFactory(
      keyManager: keyManager,
      supportDirectoryProvider: () async => supportDirectory,
      backupExclusion: backupExclusion,
    ).open();
    final fileStore = DocumentFileStore(
      rootDirectory: Directory(
        p.join(
          supportDirectory.path,
          'paperwork_assistant',
          'no_backup',
          'document_pages',
        ),
      ),
      keyManager: keyManager,
      backupExclusion: backupExclusion,
    );
    try {
      await fileStore.reconcilePendingFiles(database.isEncryptedFileReferenced);
    } catch (_) {
      await database.close();
      rethrow;
    }

    return AppPersistence._(
      database: database,
      documents: LocalDocumentStore(database: database, fileStore: fileStore),
    );
  }

  Future<void> close() => database.close();
}
