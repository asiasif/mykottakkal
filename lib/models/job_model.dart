class JobModel {
  final String id;
  final String? recruiterId; // Shop ID or Admin ID (null if guest/admin)
  final String recruiterName; // "My Shop" or "Admin"
  final String jobTitle; // "Sales Staff", "Painter"
  final String category; // "Shop", "Daily Wage", "Driver", "Other"
  final String description;
  final String salaryRange; // "10k - 15k" or "800/day"
  final String contactPhone;
  final DateTime postedDate;

  JobModel({
    required this.id,
    this.recruiterId,
    required this.recruiterName,
    required this.jobTitle,
    required this.category,
    required this.description,
    required this.salaryRange,
    required this.contactPhone,
    required this.postedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recruiterId': recruiterId,
      'recruiterName': recruiterName,
      'jobTitle': jobTitle,
      'category': category,
      'description': description,
      'salaryRange': salaryRange,
      'contactPhone': contactPhone,
      'postedDate': postedDate.millisecondsSinceEpoch,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'],
      recruiterId: map['recruiterId'],
      recruiterName: map['recruiterName'] ?? 'Unknown',
      jobTitle: map['jobTitle'],
      category: map['category'] ?? 'Other',
      description: map['description'],
      salaryRange: map['salaryRange'] ?? 'Negotiable',
      contactPhone: map['contactPhone'],
      postedDate: DateTime.fromMillisecondsSinceEpoch(map['postedDate']),
    );
  }
}
