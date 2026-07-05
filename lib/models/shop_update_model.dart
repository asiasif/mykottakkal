
class ShopUpdateModel {
  String id;
  String shopName;
  String message; // "Fresh Tuna available"
  DateTime timestamp;
  String? imageUrl;
  bool isActive;

  ShopUpdateModel({
    required this.id,
    required this.shopName,
    required this.message,
    required this.timestamp,
    this.imageUrl,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopName': shopName,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
