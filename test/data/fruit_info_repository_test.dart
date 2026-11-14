import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/repositories/fruit_info_repository.dart';

Future<List<String>> _readLabels(String path) async {
  final raw = await rootBundle.loadString(path);
  return raw
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('finds fruit by label with nutrition values', () async {
    final repo = AssetFruitInfoRepository();

    final info = await repo.getByLabel('banana');

    expect(info, isNotNull);
    expect(info!.nameId, 'Pisang');
    expect(info.calories, 89);
  });

  test('returns null for unknown label', () async {
    final repo = AssetFruitInfoRepository();

    expect(await repo.getByLabel('durian'), isNull);
  });

  test(
    'every label in labels_fruit.txt has fruit info and vice versa',
    () async {
      final repo = AssetFruitInfoRepository();
      final labels = await _readLabels('assets/models/labels_fruit.txt');
      final infoLabels = (await repo.getAll()).map((e) => e.label).toList();

      expect(labels.length, 10);
      expect(infoLabels, unorderedEquals(labels));
    },
  );

  test('ripeness labels follow the contract order', () async {
    final labels = await _readLabels('assets/models/labels_ripeness.txt');

    expect(labels, <String>['unripe', 'ripe', 'overripe', 'rotten']);
  });

  test('parses via injected loader (no asset bundle needed)', () async {
    final repo = AssetFruitInfoRepository(
      loadString: (_) async =>
          '[{"label":"x","name_id":"X","calories":1,"carbs":1,"sugar":1,'
          '"fiber":1,"vitamins":"v","benefits":"b","storage_tips":"s",'
          '"allergen_note":"a"}]',
    );

    expect((await repo.getAll()).single.label, 'x');
  });
}
