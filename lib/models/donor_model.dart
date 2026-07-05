class DonorModel {
  final String id;
  final String uid; // Links to Auth User
  final String name;
  final String bloodGroup; // "A+", "B+", etc.
  final String phone;
  final String location;
  final bool isAvailable;

  DonorModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.bloodGroup,
    required this.phone,
    required this.location,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'bloodGroup': bloodGroup,
      'phone': phone,
      'location': location,
      'isAvailable': isAvailable,
    };
  }

  factory DonorModel.fromMap(Map<String, dynamic> map) {
    return DonorModel(
      id: map['id'],
      uid: map['uid'],
      name: map['name'],
      bloodGroup: map['bloodGroup'],
      phone: map['phone'],
      location: map['location'],
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
