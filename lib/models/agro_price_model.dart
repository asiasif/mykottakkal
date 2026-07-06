class AgroPriceModel {
  final String id;
  final String name;
  final double price;
  final String unit;
  final String trend; // 'up', 'down', 'stable'
  final DateTime updatedAt;

  AgroPriceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.trend,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'unit': unit,
      'trend': trend,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory AgroPriceModel.fromMap(Map<String, dynamic> map) {
    return AgroPriceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      trend: map['trend'] ?? 'stable',
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }
}
