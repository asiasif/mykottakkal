class WorkerModel {
  String uid;
  String name;
  String phone;
  String category; // 'Farmer', 'Coconut Climber', 'Grass Cutter', 'Plumber'
  String description;
  double? price; // Optional starting price
  bool isAvailable;
  String? profileImage;
  double rating;
  double? latitude; // NEW: For Map Location
  double? longitude; // NEW: For Map Location
  String? address; // NEW: Verification
  String? certificateUrl; // NEW: Verification
  String status; // 'Pending', 'Approved', 'Rejected'
  DateTime? approvedDate; // For ID Card
  int ratingCount; // NEW: For Rating
  double totalRating; // NEW: For Rating

  WorkerModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.category,
    required this.description,
    this.price,
    this.isAvailable = true,
    this.profileImage,
    this.rating = 0.0,
    this.latitude,
    this.longitude,
    this.address,
    this.certificateUrl,
    this.status = 'Pending', // Default status
    this.approvedDate,
    this.ratingCount = 0,
    this.totalRating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'category': category,
      'description': description,
      'price': price,
      'isAvailable': isAvailable,
      'profileImage': profileImage,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'certificateUrl': certificateUrl,
      'status': status,
      'approvedDate': approvedDate?.toIso8601String(),
      'ratingCount': ratingCount,
      'totalRating': totalRating,
    };
  }

  factory WorkerModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkerModel(
      uid: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      profileImage: map['profileImage'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      address: map['address'],
      certificateUrl: map['certificateUrl'],
      status: map['status'] ?? 'Pending',
      approvedDate: map['approvedDate'] != null ? DateTime.parse(map['approvedDate']) : null,
      ratingCount: map['ratingCount'] ?? 0,
      totalRating: (map['totalRating'] ?? 0.0).toDouble(),
    );
  }
}
