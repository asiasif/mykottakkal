class EventModel {
  final String id;
  final String title;
  final String description;
  final String date;  // Storing as String for simplicity (e.g., "Oct 25")
  final String location;
  final String type; // "Event", "News"
  final DateTime timestamp;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'type': type,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      location: map['location'],
      type: map['type'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
