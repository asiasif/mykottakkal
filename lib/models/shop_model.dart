class ShopModel {
  String uid;
  String shopName;
  String ownerName;
  String mobile;
  String email;
  String shopType; // 'Restaurant', 'Cafe', 'Grocery', 'Fashion', 'Electronics', 'Other'
  String address;
  String description;
  bool deliveryAvailable;
  String status; // 'Pending', 'Approved', 'Rejected'
  String? imageUrl; // Shop Board / Front Image
  String? logoUrl; // Shop Logo
  String? licenseUrl;
  String? googleMapLink; // Added googleMapLink
  DateTime timestamp;
  DateTime? approvedDate;

  ShopModel({
    required this.uid,
    required this.shopName,
    required this.ownerName,
    required this.mobile,
    required this.email,
    required this.shopType,
    required this.address,
    required this.description,
    required this.deliveryAvailable,
    required this.status,
    this.imageUrl,
    this.logoUrl,
    this.licenseUrl,
    this.googleMapLink,
    required this.timestamp,
    this.approvedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'shopName': shopName,
      'ownerName': ownerName,
      'mobile': mobile,
      'email': email,
      'shopType': shopType,
      'address': address,
      'description': description,
      'deliveryAvailable': deliveryAvailable,
      'status': status,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'licenseUrl': licenseUrl,
      'googleMapLink': googleMapLink,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'approvedDate': approvedDate?.millisecondsSinceEpoch,
    };
  }

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      uid: map['uid'] ?? '',
      shopName: map['shopName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      shopType: map['shopType'] ?? 'Other',
      address: map['address'] ?? '',
      description: map['description'] ?? '',
      deliveryAvailable: map['deliveryAvailable'] ?? false,
      status: map['status'] ?? 'Pending',
      imageUrl: map['imageUrl'],
      logoUrl: map['logoUrl'],
      licenseUrl: map['licenseUrl'],
      googleMapLink: map['googleMapLink'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      approvedDate: map['approvedDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['approvedDate']) : null,
    );
  }
}
