import 'comment.dart';

class CreateCommentResponse {
  final Comment data;

  CreateCommentResponse({required this.data});

  factory CreateCommentResponse.fromJson(Map<String, dynamic> json) {
    return CreateCommentResponse(
      data: Comment.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
