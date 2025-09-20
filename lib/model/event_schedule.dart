class EventSchedule {
  final DateTime startDatetime;
  final DateTime endDatetime;

  EventSchedule({
    required this.startDatetime,
    required this.endDatetime,
  });

  Map<String, dynamic> toJson() => {
    "startDatetime": startDatetime.toIso8601String(),
    "endDatetime": endDatetime.toIso8601String(),
  };

  factory EventSchedule.fromJson(Map<String, dynamic> json) {
    return EventSchedule(
      startDatetime: DateTime.parse(json['startDatetime']),
      endDatetime: DateTime.parse(json['endDatetime']),
    );
  }
}
