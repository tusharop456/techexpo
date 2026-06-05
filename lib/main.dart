import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'services/gemini_insight_service.dart';
import 'services/realtime_alert_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Gemini service
  try {
    await geminiService.initialize();
    debugPrint('✓ Gemini API service initialized');
  } catch (e) {
    debugPrint('⚠ Gemini service initialization failed: $e');
  }
  
  // Connect to real-time alerts WebSocket
  try {
    await realtimeAlertService.connect();
    debugPrint('✓ Real-time alerts connected');
  } catch (e) {
    debugPrint('⚠ Real-time alerts connection failed: $e');
  }
  
  runApp(
    const ProviderScope(
      child: ChildSafetyApp(),
    ),
  );
}
