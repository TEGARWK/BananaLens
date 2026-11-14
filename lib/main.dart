import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/app.dart';
import 'package:fruitlens/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bootstrap: initialize SharedPreferences, optional Firebase, and start app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env is optional; fallback services are used if absent.
  }

  try {
    await Firebase.initializeApp();
    developer.log('Firebase initialized successfully', name: 'FruitLens');
  } catch (e) {
    developer.log(
      'Firebase initialization skipped or not configured: $e. Using local services.',
      name: 'FruitLens',
    );
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const FruitLensApp(enableSplash: true),
    ),
  );
}
