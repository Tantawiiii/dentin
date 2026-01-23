class CreateCommentRequest {
  final int postId;
  final String content;
  final String reaction;

  CreateCommentRequest({
    required this.postId,
    required this.content,
    required this.reaction,
  });

  Map<String, dynamic> toJson() {
    return {'post_id': postId, 'content': content, 'reaction': reaction};
  }
}
