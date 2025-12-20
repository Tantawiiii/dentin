import 'dart:io';
import 'package:image_picker/image_picker.dart';

extension ImagePickerExtension on ImagePicker {
  Future<File?> pickImageFile({
    required ImageSource source,
    int imageQuality = 90,
  }) async {
    try {
      final XFile? file = await pickImage(
        source: source,
        imageQuality: imageQuality,
      );
      if (file != null) {
        return File(file.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<File>> pickMultipleImageFiles({int imageQuality = 90}) async {
    try {
      final List<XFile> files = await pickMultiImage(
        imageQuality: imageQuality,
      );
      if (files.isNotEmpty) {
        return files.map((f) => File(f.path)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
