class HerbModel {
  final String id;
  final String name;
  final String localName; // Malayalam name
  final String scientificName;
  final String benefits; // Description of benefits
  final String howToUse;
  final String imageUrl;

  HerbModel({
    required this.id,
    required this.name,
    required this.localName,
    required this.scientificName,
    required this.benefits,
    required this.howToUse,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'localName': localName,
      'scientificName': scientificName,
      'benefits': benefits,
      'howToUse': howToUse,
      'imageUrl': imageUrl,
    };
  }

  factory HerbModel.fromMap(Map<String, dynamic> map) {
    return HerbModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      localName: map['localName'] ?? '',
      scientificName: map['scientificName'] ?? '',
      benefits: map['benefits'] ?? '',
      howToUse: map['howToUse'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
