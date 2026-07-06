class BulletinNoticeModel {
  final String id;
  final String title;
  final String description;
  final String postedBy;
  final DateTime postedDate;
  final String category; // 'General', 'Traffic', 'Water/Power', 'Health Alert'

  BulletinNoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.postedBy,
    required this.postedDate,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'postedBy': postedBy,
      'postedDate': postedDate.millisecondsSinceEpoch,
      'category': category,
    };
  }

  factory BulletinNoticeModel.fromMap(Map<String, dynamic> map) {
    return BulletinNoticeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      postedBy: map['postedBy'] ?? 'Anonymous',
      postedDate: DateTime.fromMillisecondsSinceEpoch(map['postedDate'] ?? DateTime.now().millisecondsSinceEpoch),
      category: map['category'] ?? 'General',
    );
  }
}
