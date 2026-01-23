class PostUser {
  final int id;
  final String userName;
  final String profileImage;
  final String createdAt;
  final String updatedAt;

  PostUser({
    required this.id,
    required this.userName,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      profileImage: json['profile_image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
