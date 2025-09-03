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


}