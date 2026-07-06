class FootballMatchModel {
  final String id;
  final String teamA;
  final String teamB;
  final int scoreA;
  final int scoreB;
  final String status; // 'Upcoming', 'Live', 'Completed'
  final String matchTime;
  final String matchDate;
  final String venue;
  final String tournamentName;
  final DateTime timestamp;
  final String minute; // e.g. "45'" or "FT" or "HT"

  FootballMatchModel({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.scoreA,
    required this.scoreB,
    required this.status,
    required this.matchTime,
    required this.matchDate,
    required this.venue,
    required this.tournamentName,
    required this.timestamp,
    required this.minute,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamA': teamA,
      'teamB': teamB,
      'scoreA': scoreA,
      'scoreB': scoreB,
      'status': status,
      'matchTime': matchTime,
      'matchDate': matchDate,
      'venue': venue,
      'tournamentName': tournamentName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'minute': minute,
    };
  }

  factory FootballMatchModel.fromMap(Map<String, dynamic> map) {
    return FootballMatchModel(
      id: map['id'] ?? '',
      teamA: map['teamA'] ?? '',
      teamB: map['teamB'] ?? '',
      scoreA: map['scoreA'] ?? 0,
      scoreB: map['scoreB'] ?? 0,
      status: map['status'] ?? 'Upcoming',
      matchTime: map['matchTime'] ?? '',
      matchDate: map['matchDate'] ?? '',
      venue: map['venue'] ?? '',
      tournamentName: map['tournamentName'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      minute: map['minute'] ?? '',
    );
  }
}
