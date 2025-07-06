class CorporateEvent {
  final String title;
  final String description;
  final int numberOfAttendees;
  final String imageUrl;
  final String hostDetails;
  final String contactNumber;
  final String location;
  final DateTime eventStartDateTime;
  final DateTime eventEndDateTime;

  CorporateEvent({
    required this.title,
    required this.description,
    required this.numberOfAttendees,
    required this.imageUrl,
    required this.hostDetails,
    required this.contactNumber,
    required this.location,
    required this.eventStartDateTime,
    required this.eventEndDateTime
  });

  factory CorporateEvent.fromJson(Map<String, dynamic> json) {
    return CorporateEvent(
      title: json['title'],
      description: json['description'],
      numberOfAttendees: json['numberOfAttendees'],
      imageUrl: json['imageUrl'],
      hostDetails: json['hostName'],
      contactNumber: json['contactNumber'],
      location: json['location'],
      eventStartDateTime: DateTime.parse(json['eventStartDateTime']),
      eventEndDateTime: DateTime.parse(json['eventEndDateTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'numberOfAttendees': numberOfAttendees,
      'imageUrl': imageUrl,
      'hostDetails': hostDetails,
      'contactNumber': contactNumber,
      'location': location,
      'eventStartDateTime': eventStartDateTime.toIso8601String(),
      'eventEndDateTime': eventEndDateTime.toIso8601String(),
    };
  }
}
