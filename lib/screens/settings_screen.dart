/// Settings screen for API configuration
/// Allows users to set and validate their Groq API key

import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/ai_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  bool _isValidating = false;
  bool _showApiKey = false;
  String? _validationMessage;
  bool? _isValid;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: AppConfig.groqApiKey ?? '',
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _validateApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    
    if (apiKey.isEmpty) {
      setState(() {
        _validationMessage = 'Please enter an API key';
        _isValid = false;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _validationMessage = null;
    });

    try {
      final isValid = await AiService.validateApiKey(apiKey);
      setState(() {
        _isValid = isValid;
        _validationMessage = isValid
            ? '✓ API key is valid!'
            : '✗ Invalid API key. Please check and try again.';
      });
    } catch (e) {
      setState(() {
        _isValid = false;
        _validationMessage = 'Error validating API key: $e';
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  void _saveApiKey() {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isNotEmpty && _isValid == true) {
      AppConfig.setGroqApiKey(apiKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API key saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please validate your API key first.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Groq API Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Get your free API key from Groq Console:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('https://console.groq.com'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text(
                'https://console.groq.com',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'API Key',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              obscureText: !_showApiKey,
              decoration: InputDecoration(
                hintText: 'Enter your Groq API key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showApiKey ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showApiKey = !_showApiKey;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isValidating ? null : _validateApiKey,
                icon: _isValidating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  _isValidating ? 'Validating...' : 'Validate API Key',
                ),
              ),
            ),
            if (_validationMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isValid == true
                      ? Colors.green[100]
                      : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isValid == true
                        ? Colors.green[400]!
                        : Colors.red[400]!,
                  ),
                ),
                child: Text(
                  _validationMessage!,
                  style: TextStyle(
                    color: _isValid == true
                        ? Colors.green[900]
                        : Colors.red[900],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid == true ? _saveApiKey : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save API Key'),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'About LAIA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'LAIA Chat is a free AI assistant powered by Groq\'s API. '
              'It provides fast and intelligent responses without requiring a credit card.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Models available:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Mixtral 8x7B (fast, versatile)\n'
              '• Llama 2 70B (powerful)\n'
              '• Gemma 7B (efficient)',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
