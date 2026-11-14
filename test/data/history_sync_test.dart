import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';
import 'package:fruitlens/services/firestore_sync_service.dart';

class MockCloudSyncService implements CloudSyncService {
  final List<ScanResult> cloudScans = <ScanResult>[];
  UserProfile? storedProfile;

  @override
  Future<void> syncUserProfile(UserProfile profile) async {
    storedProfile = profile;
  }

  @override
  Future<UserProfile?> fetchUserProfile(String uid) async => storedProfile;

  @override
  Future<int> syncPendingScans(String uid, HistoryRepository localRepo) async {
    final pending = await localRepo.getUnsynced();
    var count = 0;
    for (final item in pending) {
      cloudScans.add(item.copyWith(synced: true));
      if (item.id != null) {
        await localRepo.markAsSynced(item.id!);
        count++;
      }
    }
    return count;
  }

  @override
  Future<List<ScanResult>> fetchCloudScans(String uid) async => cloudScans;
}

void main() {
  group('History Offline-First & Sync Tests', () {
    late InMemoryHistoryRepository repo;

    setUp(() {
      repo = InMemoryHistoryRepository();
    });

    test(
      'getUnsynced and markAsSynced function correctly in repository',
      () async {
        final scan1 = await repo.insert(
          ScanResult(
            imagePath: '/path/1.jpg',
            fruitLabel: 'banana',
            ripenessLabel: 'Matang',
            confidence: 0.95,
            createdAt: DateTime.now(),
            synced: false,
          ),
        );

        await repo.insert(
          ScanResult(
            imagePath: '/path/2.jpg',
            fruitLabel: 'banana',
            ripenessLabel: 'Mentah',
            confidence: 0.88,
            createdAt: DateTime.now(),
            synced: true,
          ),
        );

        final unsyncedInitial = await repo.getUnsynced();
        expect(unsyncedInitial.length, 1);
        expect(unsyncedInitial.first.id, scan1.id);

        await repo.markAsSynced(scan1.id!);
        final unsyncedAfter = await repo.getUnsynced();
        expect(unsyncedAfter, isEmpty);

        final all = await repo.getAll();
        expect(all.length, 2);
        expect(all.every((item) => item.synced), isTrue);
      },
    );

    test(
      'MockCloudSyncService pushes pending scans and updates sync flag',
      () async {
        final syncService = MockCloudSyncService();

        await repo.insert(
          ScanResult(
            imagePath: '/offline/scan.jpg',
            fruitLabel: 'banana',
            ripenessLabel: 'Matang',
            confidence: 0.99,
            createdAt: DateTime.now(),
            synced: false,
          ),
        );

        expect((await repo.getUnsynced()).length, 1);

        final syncedCount = await syncService.syncPendingScans(
          'user_abc',
          repo,
        );
        expect(syncedCount, 1);
        expect((await repo.getUnsynced()), isEmpty);
        expect((await syncService.fetchCloudScans('user_abc')).length, 1);
      },
    );

    test('NoOpCloudSyncService safely handles calls without errors', () async {
      final noOp = NoOpCloudSyncService();
      await noOp.syncUserProfile(
        const UserProfile(uid: 'u1', email: 'test@fruitlens.id'),
      );
      expect(await noOp.fetchUserProfile('u1'), isNull);
      expect(await noOp.syncPendingScans('u1', repo), 0);
      expect(await noOp.fetchCloudScans('u1'), isEmpty);
    });
    test('isolates scans per userId between guest, userA, and userB', () async {
      await repo.insert(
        ScanResult(
          userId: 'guest',
          imagePath: '/guest.jpg',
          fruitLabel: 'banana',
          ripenessLabel: 'Matang',
          confidence: 0.9,
          createdAt: DateTime.now(),
        ),
      );

      await repo.insert(
        ScanResult(
          userId: 'user_A',
          imagePath: '/userA.jpg',
          fruitLabel: 'banana',
          ripenessLabel: 'Mentah',
          confidence: 0.85,
          createdAt: DateTime.now(),
        ),
      );

      final guestScans = await repo.getAll(userId: 'guest');
      final userAScans = await repo.getAll(userId: 'user_A');
      final userBScans = await repo.getAll(userId: 'user_B');

      expect(guestScans.length, 1);
      expect(guestScans.first.imagePath, '/guest.jpg');

      expect(userAScans.length, 1);
      expect(userAScans.first.imagePath, '/userA.jpg');

      expect(userBScans, isEmpty);
    });
  });
}
