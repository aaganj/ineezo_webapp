import 'package:inyzo_admin_web/model/venue_model.dart';

import 'event_schedule.dart';

class CorporateEvent {
  final double? id;
  final String title;
  final String description;
  final int numberOfAttendees;
  final String imageUrl;
  final String contactNumber;
  final String? hostname;
  final Venue venue;
  final String instagramUrl;
  final String bookingUrl;
  final String eventType;
  final bool isFree;
  final double price;
  final double hostId;
  final List<EventSchedule> schedules;

  CorporateEvent({
    this.id,
    required this.title,
    required this.description,
    required this.numberOfAttendees,
    required this.imageUrl,
    required this.contactNumber,
    required this.hostname,
    required this.venue,
    this.instagramUrl = '',
    this.bookingUrl = '',
    required this.isFree,
    this.price=0.0,
    required this.eventType,
    required this.hostId,
    required this.schedules,
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
      venue: json['venue'] != null ? Venue.fromJson(json['venue']) : throw Exception("Venue missing"),  // ✅ new
      instagramUrl: json['instagramUrl'] ?? '',
      bookingUrl: json['bookingUrl'] ?? '',
      eventType: json['eventType'] ?? 'General',
      isFree: json['isFree'] ?? true,
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      hostId: json['hostId'],
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map((e) => EventSchedule.fromJson(e))
          .toList() ??
          [],
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
      'venue': venue.toJson(),
      'instagramUrl': instagramUrl,
      'bookingUrl': bookingUrl,
      'eventType': eventType,
      'isFree': isFree,
      'price': price,
      'hostId': hostId,
      'schedules': schedules.map((s) => s.toJson()).toList(),
    };
  }
}
