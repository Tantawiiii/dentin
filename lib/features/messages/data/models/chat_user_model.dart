class ChatUser {
  final int id;
  final String userName;
  final String? profileImage;
  final String createdAt;
  final String updatedAt;

  ChatUser({
    required this.id,
    required this.userName,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      profileImage: json['profile_image'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'profile_image': profileImage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
