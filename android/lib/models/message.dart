enum MessageRole { user, assistant }

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {'role': role.name, 'content': content};
}
