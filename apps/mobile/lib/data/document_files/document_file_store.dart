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
    Future<void> Function(File file)? deleteTemporaryFile,
    Future<void> Function(File file, Uint8List bytes)? writeWorkFile,
    Random? random,
  }) : _cipher = cipher ?? AesGcmFileCipher(),
       _deleteFile = deleteFile ?? _deleteStoredFile,
       _deleteTemporaryFile = deleteTemporaryFile ?? _deleteStoredFile,
       _writeWorkFile = writeWorkFile ?? _writeStoredFile,
       _random = random ?? Random.secure();

  final Directory _rootDirectory;
  final InstallationKeyManager _keyManager;
  final AuthenticatedFileCipher _cipher;
  final BackupExclusion _backupExclusion;
  final Future<void> Function(File file) _deleteFile;
  final Future<void> Function(File file) _deleteTemporaryFile;
  final Future<void> Function(File file, Uint8List bytes) _writeWorkFile;
  final Random _random;

  Future<String> storeFromPlaintextFile(
    File plaintextFile, {
    required String pageId,
    CancellationToken? cancellationToken,
  }) async {
    final token = cancellationToken ?? CancellationToken();
    File? workFile;
    Object? operationError;
    StackTrace? operationStackTrace;
    String? encryptedFileName;

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
      final pendingMarker = _pendingMarker(target);
      await pendingMarker.writeAsString('', flush: true);
      await _backupExclusion.protect(pendingMarker.path);
      workFile = File('${target.path}.work');
      await _writeWorkFile(workFile, encrypted);
      token.throwIfCancelled();

      await workFile.rename(target.path);
      workFile = null;
      await _backupExclusion.protect(target.path);
      encryptedFileName = p.basename(target.path);
    } catch (error, stackTrace) {
      operationError = error;
      operationStackTrace = stackTrace;
    }

    final cleanupFailure = await _cleanupTemporaryFiles(
      workFile,
      plaintextFile,
    );
    if (operationError != null) {
      Error.throwWithStackTrace(operationError, operationStackTrace!);
    }
    if (cleanupFailure != null) {
      Error.throwWithStackTrace(
        cleanupFailure.error,
        cleanupFailure.stackTrace,
      );
    }
    return encryptedFileName!;
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
    final pendingMarker = _pendingMarker(file);
    if (await pendingMarker.exists()) {
      await pendingMarker.delete();
    }
  }

  File encryptedFile(String encryptedFileName) => _resolve(encryptedFileName);

  Future<void> markCommitted(String encryptedFileName) async {
    final pendingMarker = _pendingMarker(_resolve(encryptedFileName));
    if (await pendingMarker.exists()) {
      await pendingMarker.delete();
    }
  }

  Future<void> reconcilePendingFiles(
    Future<bool> Function(String encryptedFileName) isReferenced,
  ) async {
    if (!await _rootDirectory.exists()) {
      return;
    }

    Object? firstFailure;
    StackTrace? firstFailureStackTrace;
    final pendingMarkers = await _rootDirectory
        .list()
        .where(
          (entity) =>
              entity is File &&
              p.basename(entity.path).endsWith('.pwa.pending'),
        )
        .cast<File>()
        .toList();
    for (final pendingMarker in pendingMarkers) {
      try {
        final encryptedFileName = p.basename(
          pendingMarker.path.substring(
            0,
            pendingMarker.path.length - '.pending'.length,
          ),
        );
        final target = _resolve(encryptedFileName);
        if (await isReferenced(encryptedFileName)) {
          await pendingMarker.delete();
          continue;
        }

        Object? cleanupError;
        StackTrace? cleanupStackTrace;
        for (final entry in <(File, Future<void> Function(File))>[
          (target, _deleteFile),
          (File('${target.path}.work'), _deleteTemporaryFile),
        ]) {
          try {
            if (await entry.$1.exists()) {
              await entry.$2(entry.$1);
            }
          } catch (error, stackTrace) {
            cleanupError ??= error;
            cleanupStackTrace ??= stackTrace;
          }
        }
        if (cleanupError != null) {
          Error.throwWithStackTrace(cleanupError, cleanupStackTrace!);
        }
        await pendingMarker.delete();
      } catch (error, stackTrace) {
        firstFailure ??= error;
        firstFailureStackTrace ??= stackTrace;
      }
    }
    if (firstFailure != null) {
      Error.throwWithStackTrace(firstFailure, firstFailureStackTrace!);
    }
  }

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
          !await File('${target.path}.work').exists() &&
          !await _pendingMarker(target).exists()) {
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

  File _pendingMarker(File encryptedFile) =>
      File('${encryptedFile.path}.pending');

  Future<_CapturedFailure?> _cleanupTemporaryFiles(
    File? workFile,
    File plaintextFile,
  ) async {
    _CapturedFailure? firstFailure;
    for (final file in <File?>[workFile, plaintextFile]) {
      if (file == null) {
        continue;
      }
      try {
        if (await file.exists()) {
          await _deleteTemporaryFile(file);
        }
      } catch (error, stackTrace) {
        firstFailure ??= _CapturedFailure(error, stackTrace);
      }
    }
    return firstFailure;
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

Future<void> _writeStoredFile(File file, Uint8List bytes) async {
  await file.writeAsBytes(bytes, flush: true);
}

final class _CapturedFailure {
  const _CapturedFailure(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}
