class LikePostRequest {
  final bool liked;
  final int likesCount;

  LikePostRequest({required this.liked, required this.likesCount});

  Map<String, dynamic> toJson() {
    return {'liked': liked, 'likes_count': likesCount};
  }
}
