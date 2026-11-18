import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/data/repositories/fruit_info_repository.dart';
import 'package:fruitlens/data/repositories/recipe_repository.dart';
import 'package:fruitlens/services/chat_service.dart';
import 'package:fruitlens/services/fake_chat_service.dart';
import 'package:fruitlens/services/firestore_sync_service.dart';
import 'package:fruitlens/services/gemini_chat_service.dart';
import 'package:fruitlens/services/on_device_scan_service.dart';
import 'package:fruitlens/services/scan_service.dart';

// On-device inference: Google ML Kit + TFLite MobileNetV3Small + Masked HSV + PCA + SVM
final scanServiceProvider = Provider<ScanService>((ref) {
  final service = OnDeviceScanService();
  ref.onDispose(service.dispose);
  return service;
});

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  if (Firebase.apps.isNotEmpty) {
    return FirestoreSyncService();
  }
  return NoOpCloudSyncService();
});

final chatServiceProvider = Provider<ChatService>((ref) {
  final geminiKey = dotenv.isInitialized ? dotenv.env['GEMINI_API_KEY'] : null;
  final modelName = dotenv.isInitialized ? dotenv.env['GEMINI_MODEL'] : null;
  if (geminiKey != null && geminiKey.trim().isNotEmpty) {
    return GeminiChatService(
      apiKey: geminiKey.trim(),
      modelName: modelName?.trim().isNotEmpty == true
          ? modelName!.trim()
          : 'gemini-3.5-flash-lite',
    );
  }
  return FakeChatService();
});

final fruitInfoRepositoryProvider = Provider<FruitInfoRepository>(
  (ref) => SqfliteFruitInfoRepository(),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => SqfliteRecipeRepository(),
);
