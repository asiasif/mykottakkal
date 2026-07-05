class BusModel {
  final String id;
  final String route; // e.g., "Kottakkal -> Malappuram"
  final String busName; // e.g., "KSRTC", "Ave Maria"
  final String time; // e.g., "08:30 AM"
  final String type; // "Ordinary", "Limited Stop"

  BusModel({
    required this.id,
    required this.route,
    required this.busName,
    required this.time,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'route': route,
      'busName': busName,
      'time': time,
      'type': type,
    };
  }

  factory BusModel.fromMap(Map<String, dynamic> map) {
    return BusModel(
      id: map['id'],
      route: map['route'],
      busName: map['busName'],
      time: map['time'],
      type: map['type'],
    );
  }
}
