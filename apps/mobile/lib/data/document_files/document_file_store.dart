import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../secure_storage/installation_key_manager.dart';
import 'authenticated_file_cipher.dart';
import 'backup_exclusion.dart';

final class OperationCancelledException implements Exception {
  const OperationCancelledException();

  @override
  String toString() => 'The document operation was cancelled.';
}

final class CancellationToken {
  bool _isCancelled = false;

  void cancel() => _isCancelled = true;

  void throwIfCancelled() {
    if (_isCancelled) {
      throw const OperationCancelledException();
    }
  }
}

final class DocumentFileStore {
  DocumentFileStore({
    required this._rootDirectory,
    required this._keyManager,
    AuthenticatedFileCipher? cipher,
    this._backupExclusion = const PlatformBackupExclusion(),
    Future<void> Function(File file)? deleteFile,
    Random? random,
  }) : _cipher = cipher ?? AesGcmFileCipher(),
       _deleteFile = deleteFile ?? _deleteStoredFile,
       _random = random ?? Random.secure();

  final Directory _rootDirectory;
  final InstallationKeyManager _keyManager;
  final AuthenticatedFileCipher _cipher;
  final BackupExclusion _backupExclusion;
  final Future<void> Function(File file) _deleteFile;
  final Random _random;

  Future<String> storeFromPlaintextFile(
    File plaintextFile, {
    required String pageId,
    CancellationToken? cancellationToken,
  }) async {
    final token = cancellationToken ?? CancellationToken();
    File? workFile;

    try {
      token.throwIfCancelled();
      final plaintext = await plaintextFile.readAsBytes();
      token.throwIfCancelled();

      final key = await _keyManager.loadOrCreate();
      final encrypted = await _cipher.encrypt(plaintext, key);
      token.throwIfCancelled();

      await _ensureRoot();
      final safePageId = _safeFileComponent(pageId);
      final target = await _allocateTarget(safePageId);
      workFile = File('${target.path}.work');
      await workFile.writeAsBytes(encrypted, flush: true);
      token.throwIfCancelled();

      await workFile.rename(target.path);
      workFile = null;
      await _backupExclusion.protect(target.path);
      return p.basename(target.path);
    } finally {
      if (workFile != null && await workFile.exists()) {
        await workFile.delete();
      }
      if (await plaintextFile.exists()) {
        await plaintextFile.delete();
      }
    }
  }

  Future<Uint8List> read(String encryptedFileName) async {
    final file = _resolve(encryptedFileName);
    final envelope = await file.readAsBytes();
    final key = await _keyManager.loadOrCreate();
    return _cipher.decrypt(envelope, key);
  }

  Future<void> delete(String encryptedFileName) async {
    final file = _resolve(encryptedFileName);
    if (await file.exists()) {
      await _deleteFile(file);
    }
  }

  File encryptedFile(String encryptedFileName) => _resolve(encryptedFileName);

  Future<void> _ensureRoot() async {
    await _rootDirectory.create(recursive: true);
    await _backupExclusion.protect(_rootDirectory.path);
  }

  Future<File> _allocateTarget(String safePageId) async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final suffix = List.generate(
        16,
        (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      final target = File(
        p.join(_rootDirectory.path, '$safePageId-$suffix.pwa'),
      );
      if (!await target.exists() &&
          !await File('${target.path}.work').exists()) {
        return target;
      }
    }
    throw StateError('Could not allocate encrypted storage for $safePageId.');
  }

  File _resolve(String encryptedFileName) {
    final baseName = p.basename(encryptedFileName);
    if (baseName != encryptedFileName || !baseName.endsWith('.pwa')) {
      throw ArgumentError.value(
        encryptedFileName,
        'encryptedFileName',
        'Must be a stored file name.',
      );
    }
    return File(p.join(_rootDirectory.path, baseName));
  }

  String _safeFileComponent(String value) {
    if (value.isEmpty || !RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'pageId',
        'Use only letters, numbers, underscores, and hyphens.',
      );
    }
    return value;
  }
}

Future<void> _deleteStoredFile(File file) => file.delete();
