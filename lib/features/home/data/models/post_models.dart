class PostResponse {
  final List<Post> data;
  final String result;
  final String message;
  final int status;

  PostResponse({
    required this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class Post {
  final int id;
  final PostUser user;
  final String? content;
  final String image;
  final String video;
  final List<PostGallery> gallery;
  final List<dynamic> comments;
  final int likesCount;
  final bool isAdRequest;
  final bool? isAdApproved;
  final String? adApprovedAt;

  Post({
    required this.id,
    required this.user,
    this.content,
    required this.image,
    required this.video,
    required this.gallery,
    required this.comments,
    required this.likesCount,
    required this.isAdRequest,
    this.isAdApproved,
    this.adApprovedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      user: PostUser.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'],
      image: json['image'] ?? '',
      video: json['video'] ?? '',
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((e) => PostGallery.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      comments: json['comments'] as List<dynamic>? ?? [],
      likesCount: json['likes_count'] ?? 0,
      isAdRequest: json['is_ad_request'] ?? false,
      isAdApproved: json['is_ad_approved'],
      adApprovedAt: json['ad_approved_at'],
    );
  }
}

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

class PostGallery {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  PostGallery({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory PostGallery.fromJson(Map<String, dynamic> json) {
    return PostGallery(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
      authorId: json['authorId'],
      previewUrl: json['previewUrl'] ?? '',
      fullUrl: json['fullUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

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

class CreatePostResponse {
  final Post data;
  final String? message;

  CreatePostResponse({
    required this.data,
    this.message,
  });

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) {
    return CreatePostResponse(
      data: Post.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'],
    );
  }
}

