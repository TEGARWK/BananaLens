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
    );
  }
}
