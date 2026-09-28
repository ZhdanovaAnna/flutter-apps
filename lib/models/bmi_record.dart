class BmiRecord {
  const BmiRecord({
    required this.id,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.recommendation,
    required this.createdAt,
  });

  final String id;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final String recommendation;
  final DateTime createdAt;

  factory BmiRecord.fromMap(Map<String, dynamic> map) {
    return BmiRecord(
      id: map['id'] as String,
      heightCm: (map['height'] as num?)?.toDouble() ?? 0,
      weightKg: (map['weight'] as num?)?.toDouble() ?? 0,
      bmi: (map['body_mass_index'] as num?)?.toDouble() ?? 0,
      recommendation: map['recommendation'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}
