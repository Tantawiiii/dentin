class Event {
  final int id;
  final String name;
  final String description;
  final String startTime;
  final String endTime;
  final bool active;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.active,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      active: json['active'] ?? false,
    );
  }

  DateTime? get startDateTime {
    try {
      return DateTime.parse(startTime);
    } catch (e) {
      return null;
    }
  }

  DateTime? get endDateTime {
    try {
      return DateTime.parse(endTime);
    } catch (e) {
      return null;
    }
  }
}
