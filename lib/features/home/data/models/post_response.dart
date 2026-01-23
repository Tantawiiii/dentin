import 'post.dart';
import 'pagination_links.dart';
import 'pagination_meta.dart';

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
