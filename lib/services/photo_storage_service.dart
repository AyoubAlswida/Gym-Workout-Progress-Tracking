import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies picked images into the app's documents directory so they survive
/// even if the original (cache/gallery temp) is cleared. The base-directory
/// provider is injectable so tests can point at a temp dir instead of
/// mocking path_provider.
class PhotoStorageService {
  final Future<Directory> Function() _baseDirProvider;

  PhotoStorageService({Future<Directory> Function()? baseDirProvider})
      : _baseDirProvider =
            baseDirProvider ?? getApplicationDocumentsDirectory;

  Future<Directory> _photosDir() async {
    final base = await _baseDirProvider();
    final dir = Directory(p.join(base.path, 'progress_photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies [sourcePath] into managed storage and returns the new path.
  Future<String> persistPhoto(String sourcePath) async {
    final dir = await _photosDir();
    final ext = p.extension(sourcePath).isEmpty
        ? '.jpg'
        : p.extension(sourcePath);
    final dest =
        p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}$ext');
    await File(sourcePath).copy(dest);
    return dest;
  }

  /// Best-effort delete; a missing file is not an error.
  Future<void> deletePhotoFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      // Already gone or locked; nothing to recover.
    }
  }
}
