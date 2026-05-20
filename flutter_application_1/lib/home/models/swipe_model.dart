class SwipeModel {
  final String id;
  final String name;
  final int age;
  final String city;
  final String? avatarUrl;
  final List<String> photos;

  const SwipeModel({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    this.avatarUrl,
    this.photos = const [],
  });

  SwipeModel copyWith({
    String? id,
    String? name,
    int? age,
    String? city,
    String? avatarUrl,
    List<String>? photos,
  }) {
    return SwipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      photos: photos ?? this.photos,
    );
  }

  factory SwipeModel.fromMap(Map<String, dynamic> map) {
    return SwipeModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      city: map['city'] ?? '',
      avatarUrl: map['avatar_url'],
      photos: List<String>.from(map['photos'] ?? []),
    );
  }
}
