import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Thin platform-I/O wrapper around the (testable) BackupService strings.
class BackupFileService {
  /// Opens a save dialog and writes [content]. Returns true when saved,
  /// false when the user cancelled.
  Future<bool> saveTextFile(String content, String fileName) async {
    final bytes = Uint8List.fromList(utf8.encode(content));
    // On Android the picker writes the bytes itself (SAF); on desktop it
    // returns a path for us to write.
    final path = await FilePicker.platform.saveFile(
      fileName: fileName,
      bytes: bytes,
    );
    if (path == null) return false;
    if (!Platform.isAndroid && !Platform.isIOS) {
      await File(path).writeAsBytes(bytes);
    }
    return true;
  }

  /// Opens a file picker and returns the chosen file's text, or null when
  /// the user cancelled.
  Future<String?> pickTextFile({List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    final file = result?.files.firstOrNull;
    if (file == null) return null;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    return utf8.decode(bytes);
  }
}
