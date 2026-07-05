class BookingModel {
  String id;
  String workerId;
  String workerName;
  String userId;
  String userName;
  String userPhone;
  String serviceCategory;
  DateTime bookingDate;
  String status; // 'Pending', 'Confirmed', 'Completed', 'Cancelled'
  DateTime timestamp;
  double? userLatitude; // NEW
  double? userLongitude; // NEW
  bool isRated;

  BookingModel({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.serviceCategory,
    required this.bookingDate,
    required this.status,
    required this.timestamp,
    this.userLatitude,
    this.userLongitude,
    this.isRated = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workerId': workerId,
      'workerName': workerName,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'serviceCategory': serviceCategory,
      'bookingDate': bookingDate.millisecondsSinceEpoch,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'isRated': isRated,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      workerId: map['workerId'] ?? '',
      workerName: map['workerName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      serviceCategory: map['serviceCategory'] ?? '',
      bookingDate: DateTime.fromMillisecondsSinceEpoch(map['bookingDate']),
      status: map['status'] ?? 'Pending',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      userLatitude: map['userLatitude']?.toDouble(),
      userLongitude: map['userLongitude']?.toDouble(),
      isRated: map['isRated'] ?? false,
    );
  }
}
