class EmergencyModel {
  final String id;
  final String name;
  final String phone;
  final String category; // "Police", "Ambulance", "Fire", "Hospital", "Electricity"

  EmergencyModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'category': category,
    };
  }

  factory EmergencyModel.fromMap(Map<String, dynamic> map) {
    return EmergencyModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      category: map['category'],
    );
  }
}
