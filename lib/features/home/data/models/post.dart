import 'post_user.dart';
import 'post_gallery.dart';
import 'comment.dart';

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
  final bool isLiked;

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
    required this.isLiked,
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
      isLiked:
          json['is_liked'] == true ||
          json['liked'] == true ||
          json['liked_by_me'] == true,
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
    bool? isLiked,
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
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
