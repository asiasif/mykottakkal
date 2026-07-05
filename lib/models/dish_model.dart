class DishModel {
  String id;
  String shopId;
  String name;
  String description;
  double price;
  String imageUrl;
  String category;
  bool isAvailable;
  DateTime createdAt;
  bool isRescueItem; // New
  double? originalPrice; // New

  DishModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
    required this.createdAt,
    this.isRescueItem = false, // Default false
    this.originalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRescueItem': isRescueItem,
      'originalPrice': originalPrice,
    };
  }

  factory DishModel.fromMap(Map<String, dynamic> map, String id) {
    return DishModel(
      id: id,
      shopId: map['shopId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      isRescueItem: map['isRescueItem'] ?? false,
      originalPrice: map['originalPrice'] != null ? (map['originalPrice'] as num).toDouble() : null,
    );
  }
}
