import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  late TextEditingController _apiKeyController;
  String _provider = AppConfig.defaultProvider;
  String _model = AppConfig.defaultModel;
  bool _isLoaded = false;
  bool _showApiKey = false;
  bool _isTestingConnection = false;

  final Map<String, List<String>> _modelsByProvider = {
    'groq': [
      'llama-3.1-8b-instant',
      'llama-3.1-70b-versatile',
      'mixtral-8x7b-32768',
      'llama-3.2-1b-preview',
    ],
    'openrouter': [
      'meta-llama/llama-3.1-8b-instruct:free',
      'meta-llama/llama-3.1-70b-instruct:free',
      'meta-llama/llama-2-7b-chat:free',
      'mistralai/mistral-7b-instruct:free',
    ],
  };

  final Map<String, String> _providerApiBase = {
    'groq': AppConfig.groqApiBase,
    'openrouter': AppConfig.openrouterApiBase,
  };

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = _prefs.getString(AppConfig.apiKeyPref) ?? '';
      _provider = _prefs.getString(AppConfig.providerPref) ?? AppConfig.defaultProvider;
      _model = _prefs.getString(AppConfig.modelPref) ?? AppConfig.defaultModel;
      _isLoaded = true;
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setString(AppConfig.apiKeyPref, _apiKeyController.text);
    await _prefs.setString(AppConfig.providerPref, _provider);
    await _prefs.setString(AppConfig.modelPref, _model);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _testConnection() async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API key first')),
      );
      return;
    }

    setState(() {
      _isTestingConnection = true;
    });

    try {
      final apiBase = _providerApiBase[_provider]!;
      final response = await http
          .post(
            Uri.parse('$apiBase/chat/completions'),
            headers: {
              'Authorization': 'Bearer ${_apiKeyController.text}',
              'Content-Type': 'application/json',
              if (_provider == 'openrouter')
                'HTTP-Referer': 'https://github.com/laiadlotape/laiadandroid',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': 'Hi'}
              ],
              'max_tokens': 10,
            }),
          )
          .timeout(const Duration(seconds: 10));

      setState(() {
        _isTestingConnection = false;
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Connection successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Invalid API key'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${response.statusCode}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Connection failed: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Key Section
            _buildSectionTitle('API Key'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2a2a3e)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _apiKeyController,
                obscureText: !_showApiKey,
                decoration: InputDecoration(
                  hintText: 'Enter your API key',
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showApiKey ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF7c3aed),
                    ),
                    onPressed: () {
                      setState(() {
                        _showApiKey = !_showApiKey;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTestingConnection ? null : _testConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7c3aed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: _isTestingConnection
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      _isTestingConnection ? 'Testing...' : 'Test Connection',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Provider Section
            _buildSectionTitle('Provider'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProviderCard('groq', 'Groq', '🚀'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProviderCard('openrouter', 'OpenRouter', '🌐'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Model Section
            _buildSectionTitle('Model'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2a2a3e)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _model,
                isExpanded: true,
                underline: Container(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: (_modelsByProvider[_provider] ?? [])
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            m,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _model = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 32),

            // Info Card
            Card(
              color: const Color(0xFF1a1a2e),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📚 Get a Free API Key',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF7c3aed),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      '🚀 Groq',
                      'https://console.groq.com',
                      'No credit card needed • Fast inference',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      '🌐 OpenRouter',
                      'https://openrouter.ai',
                      'Multiple models • Free tier available',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7c3aed),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFF2a2a3e)),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFe2e8f0),
      ),
    );
  }

  Widget _buildProviderCard(String value, String label, String emoji) {
    final isSelected = _provider == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _provider = value;
          _model = _modelsByProvider[value]!.first;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7c3aed).withOpacity(0.2)
              : const Color(0xFF1a1a2e),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7c3aed)
                : const Color(0xFF2a2a3e),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF7c3aed)
                    : const Color(0xFFe2e8f0),
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7c3aed),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Selected',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String url, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFFe2e8f0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          url,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7c3aed),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9ca3af),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
