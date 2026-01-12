class PostResponse {
  final List<Post> data;
  final PaginationLinks? links;
  final PaginationMeta? meta;
  final String result;
  final String message;
  final int status;

  PostResponse({
    required this.data,
    this.links,
    this.meta,
    required this.result,
    required this.message,
    required this.status,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      links: json['links'] != null
          ? PaginationLinks.fromJson(json['links'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({this.first, this.last, this.prev, this.next});

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}

class Post {
  final int id;
  final PostUser user;
  final String? content;
  final String image;
  final String video;
  final List<PostGallery> gallery;
  final List<Comment> comments;
  final int likesCount;
  final bool isAdRequest;
  final bool? isAdApproved;
  final String? adApprovedAt;
  final bool isHidden;
  final bool isSaved;

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
    required this.isHidden,
    required this.isSaved,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      user: PostUser.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'],
      image: json['image'] ?? '',
      video: json['video'] ?? '',
      gallery:
          (json['gallery'] as List<dynamic>?)
              ?.map((e) => PostGallery.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      likesCount: json['likes_count'] ?? 0,
      isAdRequest: json['is_ad_request'] ?? false,
      isAdApproved: json['is_ad_approved'],
      adApprovedAt: json['ad_approved_at'],
      isHidden: json['is_hidden'] ?? false,
      isSaved: json['is_saved'] ?? false,
    );
  }

  Post copyWith({
    int? id,
    PostUser? user,
    String? content,
    String? image,
    String? video,
    List<PostGallery>? gallery,
    List<Comment>? comments,
    int? likesCount,
    bool? isAdRequest,
    bool? isAdApproved,
    String? adApprovedAt,
    bool? isHidden,
    bool? isSaved,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      content: content ?? this.content,
      image: image ?? this.image,
      video: video ?? this.video,
      gallery: gallery ?? this.gallery,
      comments: comments ?? this.comments,
      likesCount: likesCount ?? this.likesCount,
      isAdRequest: isAdRequest ?? this.isAdRequest,
      isAdApproved: isAdApproved ?? this.isAdApproved,
      adApprovedAt: adApprovedAt ?? this.adApprovedAt,
      isHidden: isHidden ?? this.isHidden,
      isSaved: isSaved ?? this.isSaved,
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

  CreatePostResponse({required this.data, this.message});

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) {
    return CreatePostResponse(
      data: Post.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'],
    );
  }
}

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

class CreateCommentResponse {
  final Comment data;

  CreateCommentResponse({required this.data});

  factory CreateCommentResponse.fromJson(Map<String, dynamic> json) {
    return CreateCommentResponse(
      data: Comment.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class LikePostRequest {
  final bool liked;
  final int likesCount;

  LikePostRequest({required this.liked, required this.likesCount});

  Map<String, dynamic> toJson() {
    return {'liked': liked, 'likes_count': likesCount};
  }
}
