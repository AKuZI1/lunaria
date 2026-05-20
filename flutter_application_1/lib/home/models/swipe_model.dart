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
