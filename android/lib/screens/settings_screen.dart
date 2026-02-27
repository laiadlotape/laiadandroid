import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final Map<String, List<String>> _modelsByProvider = {
    'groq': [
      'llama-3.1-8b-instant',
      'llama-3.1-70b-versatile',
      'mixtral-8x7b-32768',
    ],
    'openrouter': [
      'meta-llama/llama-3.1-8b-instruct:free',
      'meta-llama/llama-2-7b-chat:free',
    ],
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
        const SnackBar(content: Text('Settings saved!')),
      );
      Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('API Key', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your API key',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Provider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _provider,
              isExpanded: true,
              items: ['groq', 'openrouter']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _provider = value;
                    _model = _modelsByProvider[value]!.first;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Model', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _model,
              isExpanded: true,
              items: (_modelsByProvider[_provider] ?? [])
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _model = value;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Save Settings'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ℹ️ Get a free API key:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('• Groq: https://console.groq.com (no credit card)'),
                    const SizedBox(height: 4),
                    const Text('• OpenRouter: https://openrouter.ai'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
