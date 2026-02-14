import 'post.dart';

class CreatePostResponse {
  final Post data;
  final String? message;

  CreatePostResponse({required this.data, this.message});

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) {
    return CreatePostResponse(
      data: Post.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'],
    );
  }
}
