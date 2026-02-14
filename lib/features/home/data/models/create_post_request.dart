class CreatePostRequest {
  final String? content;
  final int? image;
  final int? video;
  final List<int> gallery;
  final int isAdRequest;

  CreatePostRequest({
    this.content,
    this.image,
    this.video,
    required this.gallery,
    required this.isAdRequest,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'gallery': gallery,
      'is_ad_request': isAdRequest,
    };
    if (content != null && content!.isNotEmpty) {
      map['content'] = content;
    }
    if (image != null) {
      map['image'] = image;
    }
    if (video != null) {
      map['video'] = video;
    }
    return map;
  }
}
