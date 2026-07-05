class JobApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String applicantId;
  final String applicantName;
  final String applicantPhone;
  final String status; // "Pending", "Shortlisted", "Rejected", "Hired"
  final DateTime appliedDate;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.applicantId,
    required this.applicantName,
    required this.applicantPhone,
    required this.status,
    required this.appliedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantPhone': applicantPhone,
      'status': status,
      'appliedDate': appliedDate.millisecondsSinceEpoch,
    };
  }

  factory JobApplicationModel.fromMap(Map<String, dynamic> map) {
    return JobApplicationModel(
      id: map['id'],
      jobId: map['jobId'],
      jobTitle: map['jobTitle'],
      applicantId: map['applicantId'],
      applicantName: map['applicantName'],
      applicantPhone: map['applicantPhone'],
      status: map['status'] ?? 'Pending',
      appliedDate: DateTime.fromMillisecondsSinceEpoch(map['appliedDate']),
    );
  }
}
