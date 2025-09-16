class CorporateEvent {
  final double? id;
  final String title;
  final String description;
  final int numberOfAttendees;
  final String imageUrl;
  final String contactNumber;
  final String? hostname;
  final String location;
  final double latitude;
  final double longitude;
  final String instagramUrl;
  final String bookingUrl;
  final String eventType;
  final bool isFree;
  final double price;
  final DateTime eventStartDateTime;
  final DateTime eventEndDateTime;
  final double hostID;

  CorporateEvent({
    this.id,
    required this.title,
    required this.description,
    required this.numberOfAttendees,
    required this.imageUrl,
    required this.contactNumber,
    required this.hostname,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.instagramUrl = '',
    this.bookingUrl = '',
    required this.isFree,
    this.price=0.0,
    required this.eventType,
    required this.eventStartDateTime,
    required this.eventEndDateTime,
    required this.hostID,
  });

  factory CorporateEvent.fromJson(Map<String, dynamic> json) {
    return CorporateEvent(
      id: json['id'] != null ? json['id'].toDouble() : null,
      title: json['title'],
      description: json['description'],
      numberOfAttendees: json['numberOfAttendees'],
      imageUrl: json['imageUrl'],
      hostname: json['hostName'],
      contactNumber: json['contactNumber'],
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      instagramUrl: json['instagramUrl'] ?? '',
      bookingUrl: json['bookingUrl'] ?? '',
      eventType: json['eventType'] ?? 'General',
      isFree: json['isFree'] ?? true,
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      eventStartDateTime: DateTime.parse(json['eventStartDateTime']),
      eventEndDateTime: DateTime.parse(json['eventEndDateTime']),
      hostID: json['hostID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'numberOfAttendees': numberOfAttendees,
      'imageUrl': imageUrl,
      'hostname': hostname,
      'contactNumber': contactNumber,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'instagramUrl': instagramUrl,
      'bookingUrl': bookingUrl,
      'eventType': eventType,
      'isFree': isFree,
      'price': price,
      'eventStartDateTime': eventStartDateTime.toIso8601String(),
      'eventEndDateTime': eventEndDateTime.toIso8601String(),
      'hostID': hostID,
    };
  }
}
