class TourismModel {
  final String id;
  final String name; // e.g., "Arya Vaidya Sala"
  final String description;
  final String imageUrl;
  final String location; // e.g., "Kottakkal Junction"

  TourismModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
    };
  }

  factory TourismModel.fromMap(Map<String, dynamic> map) {
    return TourismModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      location: map['location'],
    );
  }
}
