import 'dart:convert';

/// User profile holding health goals, dietary preferences, and allergies.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    this.name = '',
    this.age = 0,
    this.weight = 0.0,
    this.goal = 'Pola Hidup Sehat',
    this.allergies = const <String>[],
  });

  factory UserProfile.fromJson(Map<String, Object?> json) {
    return UserProfile(
      uid: json['uid']! as String,
      email: json['email']! as String,
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      goal: json['goal'] as String? ?? 'Pola Hidup Sehat',
      allergies:
          (json['allergies'] as List<Object?>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }

  final String uid;
  final String email;
  final String name;
  final int age;
  final double weight;
  final String goal;
  final List<String> allergies;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'weight': weight,
      'goal': goal,
      'allergies': allergies,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static UserProfile fromJsonString(String raw) =>
      UserProfile.fromJson(jsonDecode(raw) as Map<String, Object?>);

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    int? age,
    double? weight,
    String? goal,
    List<String>? allergies,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      allergies: allergies ?? this.allergies,
    );
  }
}
