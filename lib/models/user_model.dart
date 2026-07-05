class UserModel {
  String uid;
  String? name;
  String phone;
  String role; // 'user', 'worker', 'merchant', 'admin'
  bool isVerified;
  String? profileImage;
  int points;

  UserModel({
    required this.uid,
    this.name,
    required this.phone,
    required this.role,
    this.isVerified = false,
    this.profileImage,
    this.points = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,
      'profileImage': profileImage,
      'points': points,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'],
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      isVerified: map['isVerified'] ?? false,
      profileImage: map['profileImage'],
      points: map['points'] ?? 0,
    );
  }
}
