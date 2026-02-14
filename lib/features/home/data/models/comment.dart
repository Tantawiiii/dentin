import 'post_user.dart';

class Comment {
  final int id;
  final int postId;
  final PostUser user;
  final String content;
  final String reaction;
  final String createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    required this.reaction,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      postId: json['post_id'] ?? 0,
      user: json['user'] != null
          ? PostUser.fromJson(json['user'] as Map<String, dynamic>)
          : PostUser(
              id: 0,
              userName: '',
              profileImage: '',
              createdAt: '',
              updatedAt: '',
            ),
      content: json['content'] ?? '',
      reaction: json['reaction'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user': {
        'id': user.id,
        'user_name': user.userName,
        'profile_image': user.profileImage,
        'created_at': user.createdAt,
        'updated_at': user.updatedAt,
      },
      'content': content,
      'reaction': reaction,
      'created_at': createdAt,
    };
  }
}
