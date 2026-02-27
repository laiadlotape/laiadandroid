import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../config/app_config.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _apiKey;
  String? _provider;
  String? _model;
  late SharedPreferences _prefs;
  late AnimationController _thinkingAnimController;
  final ScrollController _scrollController = ScrollController();
  String _streamingContent = '';

  @override
  void initState() {
    super.initState();
    _thinkingAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = _prefs.getString(AppConfig.apiKeyPref);
      _provider = _prefs.getString(AppConfig.providerPref) ?? AppConfig.defaultProvider;
      _model = _prefs.getString(AppConfig.modelPref) ?? AppConfig.defaultModel;
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _apiKey == null) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _controller.text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _streamingContent = '';
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final aiService = AIService(
        apiKey: _apiKey!,
        provider: _provider ?? AppConfig.defaultProvider,
        model: _model ?? AppConfig.defaultModel,
      );

      final assistantMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(assistantMessage);
      });

      // Stream the response
      await for (final token in aiService.chatStream(_messages.sublist(0, _messages.length - 1))) {
        setState(() {
          _streamingContent += token;
          _messages.last = Message(
            id: assistantMessage.id,
            content: _streamingContent,
            role: MessageRole.assistant,
            timestamp: assistantMessage.timestamp,
          );
        });
        _scrollToBottom();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _clearConversation() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _streamingContent = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LAIA', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => _loadPreferences());
            },
          ),
        ],
      ),
      body: _apiKey == null ? _buildNoApiKeyState() : _buildChatState(),
    );
  }

  Widget _buildNoApiKeyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF7c3aed).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 40,
                  color: Color(0xFF7c3aed),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to LAIA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFe2e8f0),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your AI assistant awaits',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9ca3af),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                color: const Color(0xFF1a1a2e),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7c3aed),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Go to Settings',
                        style: TextStyle(color: Color(0xFFe2e8f0)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '2. Enter your API key (Groq or OpenRouter)',
                        style: TextStyle(color: Color(0xFFe2e8f0)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '3. Start chatting!',
                        style: TextStyle(color: Color(0xFFe2e8f0)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Free API keys available:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9ca3af),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Groq: console.groq.com (no card needed)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9ca3af),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• OpenRouter: openrouter.ai',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9ca3af),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  ).then((_) => _loadPreferences());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7c3aed),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.settings),
                label: const Text('Go to Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatState() {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        _messages[_messages.length - 1 - index];
                    return _buildMessageBubble(message);
                  },
                ),
        ),
        if (_isLoading) _buildThinkingBubble(),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF7c3aed).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 40,
                  color: Color(0xFF7c3aed),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Start a Conversation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFe2e8f0),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ask anything and let LAIA help',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9ca3af),
                ),
              ),
              const SizedBox(height: 32),
              _buildSuggestedPrompt('What is machine learning?'),
              const SizedBox(height: 12),
              _buildSuggestedPrompt('Help me write a poem'),
              const SizedBox(height: 12),
              _buildSuggestedPrompt('Explain quantum computing'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedPrompt(String prompt) {
    return InkWell(
      onTap: () {
        _controller.text = prompt;
        _sendMessage();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF7c3aed)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFe2e8f0)),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.role == MessageRole.user;
    final timeStr =
        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isUser ? 0.3 : -0.3, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: ModalRoute.of(context)?.animation ?? AlwaysStoppedAnimation(1),
            curve: Curves.easeOut,
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: ModalRoute.of(context)?.animation ?? AlwaysStoppedAnimation(1),
                curve: Curves.easeOut,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF7c3aed)
                        : const Color(0xFF1a1a2e),
                    borderRadius: BorderRadius.circular(16),
                    border: !isUser
                        ? Border.all(
                            color: const Color(0xFF2a2a3e),
                            width: 1,
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: Color(0xFFe2e8f0),
                              fontSize: 15,
                            ),
                            code: TextStyle(
                              backgroundColor:
                                  const Color(0xFF0f0f1a).withOpacity(0.5),
                              color: const Color(0xFF7c3aed),
                              fontSize: 12,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color:
                                  const Color(0xFF0f0f1a).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            codeblockPadding: const EdgeInsets.all(12),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2a2a3e),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: AnimatedBuilder(
            animation: _thinkingAnimController,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(0),
                  const SizedBox(width: 4),
                  _buildDot(1),
                  const SizedBox(width: 4),
                  _buildDot(2),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final progress = (_thinkingAnimController.value * 3 - index).clamp(0, 1);
    final scale = 0.5 + (0.5 * (1 - (progress - 0.5).abs() * 2));

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF7c3aed),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: const Color(0xFF1a1a2e),
      padding: const EdgeInsets.all(12),
      child: SafeArea(
        child: Column(
          children: [
            if (_messages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _messages.isEmpty ? null : _clearConversation,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: _isLoading
                      ? Colors.grey[700]
                      : const Color(0xFF7c3aed),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _thinkingAnimController.dispose();
    super.dispose();
  }
}
