import 'post_media_type.dart';

class PostMediaItem {
  final PostMediaType type;
  final String url;
  final String? thumbnailUrl;

  PostMediaItem({
    required this.type,
    required this.url,
    this.thumbnailUrl,
  });
}
