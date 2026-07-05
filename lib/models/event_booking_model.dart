class EventBookingModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String userId;
  final String userName;
  final String userPhone;
  final DateTime timestamp;

  EventBookingModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory EventBookingModel.fromMap(Map<String, dynamic> map) {
    return EventBookingModel(
      id: map['id'],
      eventId: map['eventId'],
      eventTitle: map['eventTitle'],
      userId: map['userId'],
      userName: map['userName'],
      userPhone: map['userPhone'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
