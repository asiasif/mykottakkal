class OrganicHarvestModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String title;
  final String description;
  final double price;
  final String unit;
  final double quantity;
  final String location;
  final String phone;
  final String imageUrl;
  final DateTime timestamp;
  final bool isApproved;

  OrganicHarvestModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.title,
    required this.description,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.location,
    required this.phone,
    required this.imageUrl,
    required this.timestamp,
    required this.isApproved,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'title': title,
      'description': description,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'location': location,
      'phone': phone,
      'imageUrl': imageUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isApproved': isApproved,
    };
  }

  factory OrganicHarvestModel.fromMap(Map<String, dynamic> map) {
    return OrganicHarvestModel(
      id: map['id'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'kg',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      isApproved: map['isApproved'] ?? false,
    );
  }
}
