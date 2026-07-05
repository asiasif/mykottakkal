class AutoStandModel {
  final String id;
  final String standName; // e.g., "Changuvetty Stand"
  final String location;
  final String driverPhone; // Key contact
  final double? latitude;
  final double? longitude;

  AutoStandModel({
    required this.id,
    required this.standName,
    required this.location,
    required this.driverPhone,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'standName': standName,
      'location': location,
      'driverPhone': driverPhone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AutoStandModel.fromMap(Map<String, dynamic> map) {
    return AutoStandModel(
      id: map['id'],
      standName: map['standName'],
      location: map['location'],
      driverPhone: map['driverPhone'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
