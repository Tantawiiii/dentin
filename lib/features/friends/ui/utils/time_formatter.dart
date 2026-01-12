import '../../../../core/constant/app_texts.dart';

class TimeFormatter {
  static String formatTime(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return AppTexts.justNow;
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}${AppTexts.minutes} ${AppTexts.ago}';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}${AppTexts.hours} ${AppTexts.ago}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}${AppTexts.days} ${AppTexts.ago}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}

