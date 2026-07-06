class WellnessBookingModel {
  final String id;
  final String centerId;
  final String centerName;
  final String userId;
  final String userName;
  final String userPhone;
  final String date;
  final String time;
  final String status; // 'Pending', 'Approved', 'Cancelled'
  final String message;
  final DateTime timestamp;

  WellnessBookingModel({
    required this.id,
    required this.centerId,
    required this.centerName,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.date,
    required this.time,
    required this.status,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'centerId': centerId,
      'centerName': centerName,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'date': date,
      'time': time,
      'status': status,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory WellnessBookingModel.fromMap(Map<String, dynamic> map) {
    return WellnessBookingModel(
      id: map['id'] ?? '',
      centerId: map['centerId'] ?? '',
      centerName: map['centerName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'Pending',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}
