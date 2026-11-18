/// Persisted record of a single scan stored in local SQLite database.
class ScanResult {
  const ScanResult({
    required this.imagePath,
    required this.fruitLabel,
    required this.ripenessLabel,
    required this.confidence,
    required this.createdAt,
    this.userId = 'guest',
    this.id,
    this.isFavorite = false,
    this.synced = false,
    this.unripeProb,
    this.ripeProb,
    this.rottenProb,
  });

  factory ScanResult.fromMap(Map<String, Object?> map) {
    return ScanResult(
      id: map['id'] as int?,
      userId: map['user_id'] as String? ?? 'guest',
      imagePath: map['image_path']! as String,
      fruitLabel: map['fruit_label']! as String,
      ripenessLabel: map['ripeness_label']! as String,
      confidence: (map['confidence']! as num).toDouble(),
      createdAt: DateTime.parse(map['created_at']! as String),
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      synced: (map['synced'] as int? ?? 0) == 1,
      unripeProb: (map['unripe_prob'] as num?)?.toDouble(),
      ripeProb: (map['ripe_prob'] as num?)?.toDouble(),
      rottenProb: (map['rotten_prob'] as num?)?.toDouble(),
    );
  }

  final int? id;
  final String userId;
  final String imagePath;
  final String fruitLabel;
  final String ripenessLabel;
  final double confidence;
  final DateTime createdAt;
  final bool isFavorite;
  final bool synced;
  final double? unripeProb;
  final double? ripeProb;
  final double? rottenProb;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'user_id': userId,
      'image_path': imagePath,
      'fruit_label': fruitLabel,
      'ripeness_label': ripenessLabel,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      'synced': synced ? 1 : 0,
      'unripe_prob': unripeProb,
      'ripe_prob': ripeProb,
      'rotten_prob': rottenProb,
    };
  }

  ScanResult copyWith({
    int? id,
    String? userId,
    String? imagePath,
    String? fruitLabel,
    String? ripenessLabel,
    double? confidence,
    DateTime? createdAt,
    bool? isFavorite,
    bool? synced,
    double? unripeProb,
    double? ripeProb,
    double? rottenProb,
  }) {
    return ScanResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      fruitLabel: fruitLabel ?? this.fruitLabel,
      ripenessLabel: ripenessLabel ?? this.ripenessLabel,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      synced: synced ?? this.synced,
      unripeProb: unripeProb ?? this.unripeProb,
      ripeProb: ripeProb ?? this.ripeProb,
      rottenProb: rottenProb ?? this.rottenProb,
    );
  }
}
