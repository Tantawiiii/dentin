import 'event.dart';
import 'pagination_links.dart';
import 'pagination_meta.dart';

class EventResponse {
  final List<Event> data;
  final PaginationLinks? links;
  final PaginationMeta? meta;
  final String result;
  final String message;
  final int status;

  EventResponse({
    required this.data,
    this.links,
    this.meta,
    required this.result,
    required this.message,
    required this.status,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
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
