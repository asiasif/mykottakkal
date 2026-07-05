class ShopOrderModel {
  String id;
  String shopId;
  String shopName;
  String userId;
  String userName;
  String userPhone;
  List<Map<String, dynamic>> items; // List of {'dishId', 'name', 'price', 'quantity'}
  double totalAmount;
  String status; // 'Pending', 'Accepted', 'Rejected', 'Completed', 'Cancelled'
  String paymentMethod; // 'COD', 'Online'
  bool isPaid;
  DateTime timestamp;
  double discountApplied;
  int pointsRedeemed;

  ShopOrderModel({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.isPaid,
    required this.timestamp,
    this.discountApplied = 0.0,
    this.pointsRedeemed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'shopName': shopName,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'items': items,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'discountApplied': discountApplied,
      'pointsRedeemed': pointsRedeemed,
    };
  }

  factory ShopOrderModel.fromMap(Map<String, dynamic> map) {
    return ShopOrderModel(
      id: map['id'] ?? '',
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending',
      paymentMethod: map['paymentMethod'] ?? 'COD',
      isPaid: map['isPaid'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      discountApplied: (map['discountApplied'] ?? 0.0).toDouble(),
      pointsRedeemed: map['pointsRedeemed'] ?? 0,
    );
  }
}
