class IssueModel {
  final String id;
  final String userId;
  final String category; // e.g., "Waste", "Road", "Light"
  final String description;
  final String status; // "Pending", "In Progress", "Resolved"
  final DateTime timestamp;
  final String? imageUrl; // New: Optional photo
  final double? latitude; // New: Optional locaion
  final double? longitude; // New: Optional location

  IssueModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.status,
    required this.timestamp,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'description': description,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory IssueModel.fromMap(Map<String, dynamic> map) {
    return IssueModel(
      id: map['id'],
      userId: map['userId'],
      category: map['category'],
      description: map['description'],
      status: map['status'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      imageUrl: map['imageUrl'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
