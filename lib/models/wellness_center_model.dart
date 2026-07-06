class WellnessCenterModel {
  final String id;
  final String name;
  final String imageUrl;
  final String address;
  final String phone;
  final String description;
  final double rating;
  final String googleMapLink;

  WellnessCenterModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.phone,
    required this.description,
    required this.rating,
    required this.googleMapLink,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
      'phone': phone,
      'description': description,
      'rating': rating,
      'googleMapLink': googleMapLink,
    };
  }

  factory WellnessCenterModel.fromMap(Map<String, dynamic> map) {
    return WellnessCenterModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 0.0) is int ? (map['rating'] as int).toDouble() : (map['rating'] ?? 0.0),
      googleMapLink: map['googleMapLink'] ?? '',
    );
  }
}
