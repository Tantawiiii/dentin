import 'dart:io';
import 'package:file_picker/file_picker.dart';

extension FilePickerExtension on FilePicker {
  Future<File?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        dialogTitle: dialogTitle,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
