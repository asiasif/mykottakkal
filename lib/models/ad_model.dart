class AdModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  final String contactPhone;
  final DateTime postedDate;

  AdModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.contactPhone,
    required this.postedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'contactPhone': contactPhone,
      'postedDate': postedDate.millisecondsSinceEpoch,
    };
  }

  factory AdModel.fromMap(Map<String, dynamic> map) {
    return AdModel(
      id: map['id'],
      sellerId: map['sellerId'],
      sellerName: map['sellerName'],
      title: map['title'],
      price: (map['price'] as num).toDouble(),
      description: map['description'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      contactPhone: map['contactPhone'],
      postedDate: DateTime.fromMillisecondsSinceEpoch(map['postedDate']),
    );
  }
}
