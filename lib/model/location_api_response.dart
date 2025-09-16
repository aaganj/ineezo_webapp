class LocationAPIResponse{

  final String? selectedLocationName;
  final String? selectedFormattedAddress;
  final double latitude;
  final double longitude;

  LocationAPIResponse(
      {required this.selectedLocationName,
        required this.selectedFormattedAddress,
        required this.latitude,
        required this.longitude});

  factory LocationAPIResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return LocationAPIResponse(
      selectedLocationName: result['name'],
      selectedFormattedAddress: result['formatted_address'],
      latitude: result['geometry']['location']['lat']?.toDouble(),
      longitude: result['geometry']['location']['lng']?.toDouble(),
    );
  }

}