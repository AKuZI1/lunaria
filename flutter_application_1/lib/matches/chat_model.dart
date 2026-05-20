class ChatModel {
  final String id;
  final String name;
  final int age;
  final String lastMessage;
  final String? avatarUrl;
  final int unreadCount;
  final bool isOnline;

  const ChatModel({
    required this.id,
    required this.name,
    required this.age,
    required this.lastMessage,
    this.avatarUrl,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      lastMessage: map['last_message'] ?? '',
      avatarUrl: map['avatar_url'],
      unreadCount: map['unread_count'] ?? 0,
      isOnline: map['is_online'] ?? false,
    );
  }
}
