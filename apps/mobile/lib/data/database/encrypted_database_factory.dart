import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../document_files/backup_exclusion.dart';
import '../secure_storage/installation_key_manager.dart';
import 'app_database.dart';

typedef SupportDirectoryProvider = Future<Directory> Function();

final class EncryptedDatabaseFactory {
  EncryptedDatabaseFactory({
    required this._keyManager,
    SupportDirectoryProvider? supportDirectoryProvider,
    this._backupExclusion = const PlatformBackupExclusion(),
  }) : _supportDirectoryProvider =
           supportDirectoryProvider ?? getApplicationSupportDirectory;

  final InstallationKeyManager _keyManager;
  final SupportDirectoryProvider _supportDirectoryProvider;
  final BackupExclusion _backupExclusion;

  Future<AppDatabase> open() async {
    final key = await _keyManager.loadOrCreate();
    final supportDirectory = await _supportDirectoryProvider();
    final databaseDirectory = Directory(
      p.join(supportDirectory.path, 'paperwork_assistant', 'no_backup'),
    );
    await databaseDirectory.create(recursive: true);
    await _backupExclusion.protect(databaseDirectory.path);

    final databaseFile = File(
      p.join(databaseDirectory.path, 'documents.sqlite'),
    );
    final database = AppDatabase(
      NativeDatabase.createInBackground(
        databaseFile,
        setup: (rawDatabase) => _configureEncryption(rawDatabase, key),
      ),
    );

    try {
      await database.initialize();
      await _backupExclusion.protect(databaseFile.path);
      return database;
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  static void _configureEncryption(Database rawDatabase, Uint8List key) {
    final cipherSupport = rawDatabase.select('PRAGMA cipher;');
    if (cipherSupport.isEmpty) {
      throw StateError(
        'Encrypted SQLite support is unavailable in this application build.',
      );
    }

    final hexKey = key
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    rawDatabase.execute('PRAGMA key = "x\'$hexKey\'";');
    rawDatabase.execute('PRAGMA cipher_memory_security = ON;');

    // A wrong key must fail before Drift is allowed to inspect or migrate the
    // schema.
    rawDatabase.select('SELECT count(*) FROM sqlite_master;');
  }
}
