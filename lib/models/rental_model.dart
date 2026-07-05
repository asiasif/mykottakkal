class RentalModel {
  final String id;
  final String title;
  final String description;
  final String category; // "House", "Shop", "Vehicle", "Equipment"
  final double price;
  final String location;
  final String imageUrl;
  final String contactPhone;
  final DateTime date;

  RentalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.contactPhone,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'location': location,
      'imageUrl': imageUrl,
      'contactPhone': contactPhone,
      'date': date.toIso8601String(),
    };
  }

  factory RentalModel.fromMap(Map<String, dynamic> map) {
    return RentalModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      price: map['price'].toDouble(),
      location: map['location'],
      imageUrl: map['imageUrl'],
      contactPhone: map['contactPhone'],
      date: DateTime.parse(map['date']),
    );
  }
}
