import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';

void main() {
  group('HistoryRepository Tests', () {
    late HistoryRepository repo;

    setUp(() {
      repo = InMemoryHistoryRepository();
    });

    test('inserts scan results and retrieves in descending order', () async {
      final item1 = ScanResult(
        imagePath: 'banana.jpg',
        fruitLabel: 'banana',
        ripenessLabel: 'ripe',
        confidence: 0.94,
        createdAt: DateTime(2026, 1, 1, 10, 0),
      );
      final item2 = ScanResult(
        imagePath: 'apple.jpg',
        fruitLabel: 'apple',
        ripenessLabel: 'unripe',
        confidence: 0.89,
        createdAt: DateTime(2026, 1, 1, 11, 0),
      );

      await repo.insert(item1);
      final inserted2 = await repo.insert(item2);

      final list = await repo.getAll();
      expect(list.length, 2);
      expect(list.first.fruitLabel, 'apple'); // yang terbaru di atas
      expect(inserted2.id, isNotNull);
    });

    test('deletes an item by id', () async {
      final item = ScanResult(
        imagePath: 'orange.jpg',
        fruitLabel: 'orange',
        ripenessLabel: 'ripe',
        confidence: 0.90,
        createdAt: DateTime.now(),
      );
      final inserted = await repo.insert(item);

      await repo.delete(inserted.id!);
      final list = await repo.getAll();
      expect(list, isEmpty);
    });

    test('toggles favorite status', () async {
      final item = ScanResult(
        imagePath: 'mango.jpg',
        fruitLabel: 'mango',
        ripenessLabel: 'ripe',
        confidence: 0.91,
        createdAt: DateTime.now(),
        isFavorite: false,
      );
      final inserted = await repo.insert(item);

      await repo.toggleFavorite(inserted.id!, true);
      final list = await repo.getAll();
      expect(list.first.isFavorite, isTrue);
    });
  });
}
