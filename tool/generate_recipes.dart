import 'dart:convert';
import 'dart:io';

/// Standalone CLI script to pre-generate structured fruit recipes using Gemini API.
/// Usage:
///   dart run tool/generate_recipes.dart --fruit=banana --bucket=very_ripe
///
/// Output is validated against PRD section 5 JSON schema and saved to
/// `assets/data/generated_recipes_draft.json` with `is_reviewed: false`
/// for manual review before seeding into production DB.
Future<void> main(List<String> args) async {
  final parsedArgs = _parseArgs(args);
  final fruit = (parsedArgs['fruit'] ?? 'banana').trim().toLowerCase();
  final bucket = (parsedArgs['bucket'] ?? 'ripe').trim().toLowerCase();

  if (!const {'unripe', 'ripe', 'very_ripe'}.contains(bucket)) {
    stderr.writeln(
      'Invalid --bucket="$bucket". Expected: unripe | ripe | very_ripe',
    );
    exitCode = 1;
    return;
  }

  final env = _loadDotEnv('.env');
  final apiKey =
      env['GEMINI_API_KEY'] ?? Platform.environment['GEMINI_API_KEY'];
  final model =
      env['GEMINI_MODEL'] ??
      Platform.environment['GEMINI_MODEL'] ??
      'gemini-3.5-flash-lite';

  if (apiKey == null || apiKey.trim().isEmpty) {
    stderr.writeln('GEMINI_API_KEY is missing in .env or environment.');
    exitCode = 1;
    return;
  }

  final prompt = _buildPrompt(fruit: fruit, bucket: bucket);
  stdout.writeln(
    'Generating recipes via $model for fruit="$fruit", bucket="$bucket"...',
  );

  final responseMap = await _callGemini(
    apiKey: apiKey.trim(),
    model: model.trim(),
    prompt: prompt,
  );

  _validateSchema(responseMap, expectedBucket: bucket);

  final recipes = (responseMap['recipes'] as List<Object?>)
      .cast<Map<String, Object?>>()
      .map(
        (r) => <String, Object?>{
          'fruit_id': fruit,
          'ripeness_bucket': bucket,
          'name': r['name'],
          'type': r['type'],
          'ingredients': r['ingredients'],
          'steps': r['steps'],
          'safety_notes': r['safety_notes'],
          'is_reviewed': false,
        },
      )
      .toList(growable: false);

  final outFile = File('assets/data/generated_recipes_draft.json');
  await outFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'fruit': fruit,
      'ripeness_bucket': bucket,
      'recipes': recipes,
    }),
  );

  stdout.writeln(
    'Saved ${recipes.length} unreviewed draft recipes to ${outFile.path}',
  );
}

Map<String, String> _parseArgs(List<String> args) {
  final map = <String, String>{};
  for (final arg in args) {
    if (!arg.startsWith('--')) continue;
    final idx = arg.indexOf('=');
    if (idx > 2) {
      map[arg.substring(2, idx)] = arg.substring(idx + 1);
    }
  }
  return map;
}

Map<String, String> _loadDotEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) return const <String, String>{};
  final map = <String, String>{};
  for (final rawLine in file.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final eq = line.indexOf('=');
    if (eq <= 0) continue;
    map[line.substring(0, eq).trim()] = line.substring(eq + 1).trim();
  }
  return map;
}

String _buildPrompt({required String fruit, required String bucket}) {
  final bucketGuidance = switch (bucket) {
    'unripe' =>
      'buah masih mentah (wajib pengolahan dimasak/direbus/digoreng atau dicuci getahnya agar aman, dan WAJIB isi safety_notes secara eksplisit).',
    'very_ripe' =>
      'buah matang banget / lunak manis (cocok untuk smoothie, pancake, banana bread, selai).',
    _ =>
      'buah matang pas (cocok dimakan segar atau olahan ringan seperti salad, oatmeal topping, jus).',
  };

  return '''
Buat 2 resep kuliner Indonesia berbahasa Indonesia untuk buah "$fruit" pada tingkat kematangan "$bucket" ($bucketGuidance).

KEMBALIKAN HANYA JSON VALID dengan struktur persis seperti berikut (tanpa markdown fence, tanpa teks lain):
{
  "fruit": "$fruit",
  "ripeness_bucket": "$bucket",
  "recipes": [
    {
      "name": "Nama Resep",
      "type": "food",
      "ingredients": ["bahan 1", "bahan 2"],
      "steps": ["Langkah 1.", "Langkah 2."],
      "safety_notes": null
    }
  ]
}

Aturan ketat:
- "type" hanya boleh "food" atau "drink".
- "ingredients" dan "steps" harus array string tidak kosong dan langkah singkat jelas.
- Jika "ripeness_bucket" adalah "unripe", "safety_notes" TIDAK BOLEH null dan harus berisi catatan keamanan pengolahan yang jelas.
''';
}

Future<Map<String, Object?>> _callGemini({
  required String apiKey,
  required String model,
  required String prompt,
}) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );
    final req = await client.postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(
      jsonEncode(<String, Object?>{
        'contents': <Object?>[
          <String, Object?>{
            'parts': <Object?>[
              <String, Object?>{'text': prompt},
            ],
          },
        ],
        'generationConfig': <String, Object?>{
          'responseMimeType': 'application/json',
        },
      }),
    );

    final res = await req.close();
    final body = await utf8.decodeStream(res);
    if (res.statusCode != 200) {
      throw HttpException('Gemini API HTTP ${res.statusCode}: $body');
    }

    final decoded = jsonDecode(body) as Map<String, Object?>;
    final candidates = decoded['candidates'] as List<Object?>;
    final content =
        (candidates.first as Map<String, Object?>)['content']
            as Map<String, Object?>;
    final parts = content['parts'] as List<Object?>;
    final text = (parts.first as Map<String, Object?>)['text'] as String;
    return jsonDecode(text) as Map<String, Object?>;
  } finally {
    client.close();
  }
}

void _validateSchema(
  Map<String, Object?> json, {
  required String expectedBucket,
}) {
  if (json['fruit'] is! String || json['ripeness_bucket'] != expectedBucket) {
    throw const FormatException(
      'Root JSON fields fruit/ripeness_bucket invalid',
    );
  }
  final recipes = json['recipes'];
  if (recipes is! List<Object?> || recipes.isEmpty) {
    throw const FormatException('recipes must be a non-empty array');
  }
  for (final item in recipes) {
    if (item is! Map<String, Object?>) {
      throw const FormatException('Recipe item must be a JSON object');
    }
    final type = item['type'];
    if (type != 'food' && type != 'drink') {
      throw FormatException('Invalid recipe type: $type');
    }
    final ingredients = item['ingredients'];
    final steps = item['steps'];
    if (ingredients is! List<Object?> ||
        ingredients.isEmpty ||
        steps is! List<Object?> ||
        steps.isEmpty) {
      throw const FormatException('ingredients and steps must be non-empty');
    }
    if (expectedBucket == 'unripe') {
      final notes = item['safety_notes'];
      if (notes is! String || notes.trim().isEmpty) {
        throw const FormatException(
          'Unripe recipes must include non-empty safety_notes',
        );
      }
    }
  }
}
