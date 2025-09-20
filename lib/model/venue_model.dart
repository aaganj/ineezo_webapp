class Venue {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String placeId;
  final int? id;

  Venue({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    this.id,
  });

  Venue copyWith({int? id}) {
    return Venue(
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      placeId: placeId,
      id: id ?? this.id,
    );
  }

  /// ✅ Convert Venue to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
      if (id != null) 'id': id,
    };
  }

  /// ✅ Create Venue from JSON
  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      placeId: json['placeId'] ?? '',
      id: json['id'], // can be null
    );
  }
}
