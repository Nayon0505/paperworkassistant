import 'dart:io';

import 'package:flutter/services.dart';

abstract interface class BackupExclusion {
  Future<void> protect(String path);
}

final class PlatformBackupExclusion implements BackupExclusion {
  const PlatformBackupExclusion();

  static const _channel = MethodChannel(
    'de.nayon.paperworkassistant/storage_protection',
  );

  @override
  Future<void> protect(String path) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('protect', {'path': path});
    }
    // Android excludes the complete private app container through manifest
    // and data-extraction rules. No per-file API is required there.
  }
}

final class NoopBackupExclusion implements BackupExclusion {
  const NoopBackupExclusion();

  @override
  Future<void> protect(String path) async {}
}
