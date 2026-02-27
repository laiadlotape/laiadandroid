import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() => runApp(const LaiaApp());

class LaiaApp extends StatelessWidget {
  const LaiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0f0f1a),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7c3aed),
          surface: const Color(0xFF1a1a2e),
          background: const Color(0xFF0f0f1a),
          onSurface: const Color(0xFFe2e8f0),
          onBackground: const Color(0xFFe2e8f0),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a1a2e),
          foregroundColor: Color(0xFFe2e8f0),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFF1a1a2e),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7c3aed)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2a2a3e), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7c3aed), width: 2),
          ),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}
