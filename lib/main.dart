import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MindCareApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('CRITICAL INITIALIZATION ERROR: $e');
    debugPrint('STACK TRACE: $stack');
    // Fallback minimal app to show error if possible
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Initialization Error: $e\n\nPlease restart the app.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.red500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Provider for SharedPreferences to be accessible across the app
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});
