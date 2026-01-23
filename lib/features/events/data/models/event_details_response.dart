import 'event.dart';

class EventDetailsResponse {
  final Event data;
  final String result;
  final String message;
  final int status;

  EventDetailsResponse({
    required this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory EventDetailsResponse.fromJson(Map<String, dynamic> json) {
    return EventDetailsResponse(
      data: Event.fromJson(json['data'] as Map<String, dynamic>),
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}
