import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:fruitlens/data/models/recipe.dart';

/// Contract for generating structured recipes from scan results via LLM.
abstract class LiveRecipeGenerator {
  Future<List<Recipe>> generate({
    required String fruitId,
    required String fruitNameId,
    required RipenessBucket bucket,
    required double confidence,
    RecipePreference preference = RecipePreference.any,
  });
}

/// Live Gemini REST implementation of [LiveRecipeGenerator] using [Dio],
/// completely separate from Chat AI Assistant.
class GeminiRecipeService implements LiveRecipeGenerator {
  GeminiRecipeService({
    required String apiKey,
    String modelName = 'gemini-3.5-flash-lite',
    Dio? client,
  }) : _apiKey = apiKey,
       _modelName = modelName,
       _client =
           client ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 15),
             ),
           );

  final String _apiKey;
  final String _modelName;
  final Dio _client;
  final List<String> _recentNames = <String>[];
  final math.Random _random = math.Random();

  static const List<String> _themeAngles = <String>[
    'sarapan praktis & mengenyangkan',
    'camilan tradisional Nusantara yang unik',
    'dessert atau hidangan penutup segar kekinian',
    'minuman sehat rendah gula & menyegarkan',
    'olahan panggang/kukus sehat tanpa banyak minyak',
    'kreasi bekal atau snack anak sekolah yang menarik',
  ];

  @override
  Future<List<Recipe>> generate({
    required String fruitId,
    required String fruitNameId,
    required RipenessBucket bucket,
    required double confidence,
    RecipePreference preference = RecipePreference.any,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw StateError('GEMINI_API_KEY belum dikonfigurasi');
    }

    final pct = (confidence * 100).toStringAsFixed(0);
    final angle = _themeAngles[_random.nextInt(_themeAngles.length)];
    final prompt = _buildPrompt(
      fruitId: fruitId,
      fruitNameId: fruitNameId,
      bucket: bucket,
      percentageText: '$pct%',
      themeAngle: angle,
      preference: preference,
      avoidNames: _recentNames,
    );

    final candidateModels = <String>{
      _modelName.trim(),
      'gemini-2.5-flash-lite',
      'gemini-3.5-flash',
    }.toList(growable: false);

    DioException? lastDioError;
    for (final model in candidateModels) {
      try {
        final generated = await _requestModel(
          model: model,
          prompt: prompt,
          fruitId: fruitId,
          bucket: bucket,
        );
        for (final r in generated) {
          _recentNames.add(r.name);
        }
        while (_recentNames.length > 10) {
          _recentNames.removeAt(0);
        }
        return generated;
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        lastDioError = e;
        // Retry with fallback model on transient server overload or rate limit.
        if (code == 503 || code == 500 || code == 429) {
          await Future<void>.delayed(const Duration(milliseconds: 400));
          continue;
        }
        rethrow;
      }
    }

    throw lastDioError!;
  }

  Future<List<Recipe>> _requestModel({
    required String model,
    required String prompt,
    required String fruitId,
    required RipenessBucket bucket,
  }) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${_apiKey.trim()}';

    final response = await _client.post<Map<String, dynamic>>(
      url,
      options: Options(contentType: Headers.jsonContentType),
      data: <String, Object?>{
        'contents': <Object?>[
          <String, Object?>{
            'parts': <Object?>[
              <String, Object?>{'text': prompt},
            ],
          },
        ],
        'generationConfig': <String, Object?>{
          'responseMimeType': 'application/json',
          'temperature': 1.15,
          'topP': 0.95,
        },
      },
    );

    final body = response.data;
    if (body == null) {
      throw const FormatException('Respons kosong dari Gemini');
    }

    final candidates = body['candidates'] as List<Object?>?;
    if (candidates == null || candidates.isEmpty) {
      throw const FormatException('Tidak ada kandidat respons dari Gemini');
    }

    final firstCandidate = candidates.first as Map<String, Object?>;
    final content = firstCandidate['content'] as Map<String, Object?>?;
    final parts = content?['parts'] as List<Object?>?;
    final rawText = (parts?.first as Map<String, Object?>?)?['text'] as String?;

    if (rawText == null || rawText.trim().isEmpty) {
      throw const FormatException('Teks respons Gemini kosong');
    }

    return parseAndValidateResponse(rawText, fruitId: fruitId, bucket: bucket);
  }

  static List<Recipe> parseAndValidateResponse(
    String rawJson, {
    required String fruitId,
    required RipenessBucket bucket,
  }) {
    final cleaned = rawJson
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
        .trim();

    final decoded = jsonDecode(cleaned) as Map<String, Object?>;
    final rawRecipes = decoded['recipes'];
    if (rawRecipes is! List<Object?> || rawRecipes.isEmpty) {
      throw const FormatException('Missing or empty recipes list');
    }

    final now = DateTime.now();
    final results = <Recipe>[];

    for (var i = 0; i < rawRecipes.length; i++) {
      final item = rawRecipes[i];
      if (item is! Map<String, Object?>) continue;

      final name = (item['name'] as String?)?.trim();
      final typeStr = (item['type'] as String?)?.trim().toLowerCase();
      final ingredients = (item['ingredients'] as List<Object?>?)
          ?.map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      final steps = (item['steps'] as List<Object?>?)
          ?.map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      final safetyNotes = (item['safety_notes'] as String?)?.trim();

      if (name == null ||
          name.isEmpty ||
          ingredients == null ||
          ingredients.isEmpty ||
          steps == null ||
          steps.isEmpty) {
        continue;
      }

      if (bucket == RipenessBucket.unripe &&
          (safetyNotes == null || safetyNotes.isEmpty)) {
        continue;
      }

      final type = typeStr == 'drink' ? RecipeType.drink : RecipeType.food;
      results.add(
        Recipe(
          id: 10000 + i,
          title: name,
          fruitLabel: fruitId,
          suitableRipeness: <String>[
            bucket == RipenessBucket.veryRipe ? 'overripe' : bucket.dbValue,
          ],
          ingredients: ingredients,
          steps: steps,
          prepTime: (item['prep_time'] as String?)?.trim() ?? '15 menit',
          difficulty: (item['difficulty'] as String?)?.trim() ?? 'Mudah',
          ripenessBucket: bucket,
          type: type,
          safetyNotes: safetyNotes == null || safetyNotes.isEmpty
              ? null
              : safetyNotes,
          isReviewed: true,
          source: RecipeSource.ai,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    if (results.isEmpty) {
      throw const FormatException('No valid recipes parsed from Gemini JSON');
    }
    return results;
  }

  static String _buildPrompt({
    required String fruitId,
    required String fruitNameId,
    required RipenessBucket bucket,
    required String percentageText,
    required String themeAngle,
    required RecipePreference preference,
    required List<String> avoidNames,
  }) {
    final conditionDesc = switch (bucket) {
      RipenessBucket.unripe =>
        'masih mentah (wajib pengolahan dimasak/direbus/digoreng atau dibuang getahnya agar aman, WAJIB isi safety_notes secara jelas)',
      RipenessBucket.veryRipe =>
        'matang banget / sangat manis & lunak (cocok untuk smoothie, pancake, banana bread, bolu, selai)',
      RipenessBucket.ripe =>
        'matang pas (cocok dinikmati segar atau olahan ringan seperti salad buah, oatmeal topping, jus)',
    };
    final prefInstruction = switch (preference) {
      RecipePreference.any =>
        'Campurkan variasi kreatif sesuai tema "$themeAngle" (boleh makanan maupun minuman).',
      RecipePreference.food =>
        'WAJIB berupa MAKANAN atau CAMILAN ("type": "food"), jangan buat minuman.',
      RecipePreference.drink =>
        'WAJIB berupa MINUMAN segar atau hangat ("type": "drink"), misalnya jus, smoothie, es buah, latte, atau wedang buah.',
      RecipePreference.sweet =>
        'WAJIB bercita rasa MANIS atau hidangan dessert/pencuci mulut yang lezat.',
      RecipePreference.savory =>
        'WAJIB bercita rasa GURIH / ASIN / PEDAS (seperti camilan gorengan renyah, nugget gurih, sambal buah, tumisan, atau salad gurih), BUKAN dessert manis.',
      RecipePreference.quick =>
        'WAJIB SUPER PRAKTIS: waktu pembuatan maksimal 10–15 menit dengan maksimal 4 bahan sederhana yang mudah ditemukan di dapur.',
    };
    final avoidClause = avoidNames.isEmpty
        ? ''
        : '\n- JANGAN mengulang atau membuat resep yang mirip dengan daftar berikut: ${avoidNames.join(', ')}.';

    return '''
Hasil scan menunjukkan buah "$fruitNameId" ($fruitId) dengan kondisi "${bucket.labelId}" (keyakinan: $percentageText), yaitu $conditionDesc.

Buatkan 2 ide resep masakan/minuman Indonesia yang kreatif, praktis, dan bervariasi.
PREFERENSI PENGGUNA: $prefInstruction$avoidClause

KEMBALIKAN HANYA JSON VALID dengan schema persis seperti ini:
{
  "fruit": "$fruitId",
  "ripeness_bucket": "${bucket.dbValue}",
  "recipes": [
    {
      "name": "Nama Resep",
      "type": "food",
      "prep_time": "15 menit",
      "difficulty": "Mudah",
      "ingredients": ["bahan 1", "bahan 2"],
      "steps": ["Langkah 1.", "Langkah 2."],
      "safety_notes": null
    }
  ]
}

Aturan wajib:
- "type" hanya boleh "food" atau "drink".
- "ingredients" dan "steps" harus array string tidak kosong.
- Jika ripeness_bucket adalah "unripe", "safety_notes" TIDAK BOLEH null dan harus berisi catatan keamanan pengolahan yang jelas.
''';
  }
}
