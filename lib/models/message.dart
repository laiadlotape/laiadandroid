/// Chat message model
/// Represents a single message in the chat conversation

class Message {
  /// Unique identifier for the message
  final String id;
  
  /// Message content/text
  final String content;
  
  /// Sender of the message ('user' or 'ai')
  final String role;
  
  /// Timestamp when message was created
  final DateTime timestamp;
  
  /// Optional error message if request failed
  final String? error;
  
  /// Whether the message is still loading
  final bool isLoading;
  
  /// Constructor
  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.error,
    this.isLoading = false,
  });
  
  /// Check if message is from user
  bool get isUserMessage => role == 'user';
  
  /// Check if message is from AI
  bool get isAiMessage => role == 'assistant';
  
  /// Check if message has an error
  bool get hasError => error != null && error!.isNotEmpty;
  
  /// Create a copy with modified fields
  Message copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? timestamp,
    String? error,
    bool? isLoading,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
      'isLoading': isLoading,
    };
  }
  
  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }
}
