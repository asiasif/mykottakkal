class DailyRatesModel {
  final double gold24k;
  final double gold22k;
  final double silver;
  final DateTime updatedAt;
  final bool isManual;
  final double manualGold24k;
  final double manualGold22k;
  final double manualSilver;

  DailyRatesModel({
    required this.gold24k,
    required this.gold22k,
    required this.silver,
    required this.updatedAt,
    required this.isManual,
    required this.manualGold24k,
    required this.manualGold22k,
    required this.manualSilver,
  });

  Map<String, dynamic> toMap() {
    return {
      'gold24k': gold24k,
      'gold22k': gold22k,
      'silver': silver,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isManual': isManual,
      'manualGold24k': manualGold24k,
      'manualGold22k': manualGold22k,
      'manualSilver': manualSilver,
    };
  }

  factory DailyRatesModel.fromMap(Map<String, dynamic> map) {
    return DailyRatesModel(
      gold24k: (map['gold24k'] as num?)?.toDouble() ?? 0.0,
      gold22k: (map['gold22k'] as num?)?.toDouble() ?? 0.0,
      silver: (map['silver'] as num?)?.toDouble() ?? 0.0,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) 
          : DateTime.now(),
      isManual: map['isManual'] ?? false,
      manualGold24k: (map['manualGold24k'] as num?)?.toDouble() ?? 0.0,
      manualGold22k: (map['manualGold22k'] as num?)?.toDouble() ?? 0.0,
      manualSilver: (map['manualSilver'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
