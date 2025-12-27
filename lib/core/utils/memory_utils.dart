import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Memory management utilities
class MemoryUtils {
  MemoryUtils._();

  /// Clear image cache to free memory
  static Future<void> clearImageCache() async {
    if (kDebugMode) {
      print('🧹 Clearing image cache...');
    }
    imageCache.clear();
    imageCache.clearLiveImages();
    if (kDebugMode) {
      print('✅ Image cache cleared');
    }
  }

  /// Get approximate memory usage (for debugging)
  static void logMemoryUsage() {
    if (kDebugMode) {
      final imageCacheSize = imageCache.currentSizeBytes;
      final imageCacheCount = imageCache.currentSize;
      print(
        '📊 Image Cache: $imageCacheCount images, ${_formatBytes(imageCacheSize)}',
      );
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Dispose file safely
  static void disposeFile(File? file) {
    try {
      // Files don't need explicit disposal in Dart
      // But we can clear references
      file = null;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error disposing file: $e');
      }
    }
  }
}
