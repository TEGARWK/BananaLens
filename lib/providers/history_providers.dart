import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/providers/service_providers.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => SqfliteHistoryRepository(),
);

/// Provider holding the list of scan histories scoped to the current user/guest.
final historyListProvider =
    AsyncNotifierProvider<HistoryListNotifier, List<ScanResult>>(
      HistoryListNotifier.new,
    );

class HistoryListNotifier extends AsyncNotifier<List<ScanResult>> {
  String get _currentUserId {
    final user = ref.read(authNotifierProvider).asData?.value;
    return user?.uid ?? 'guest';
  }

  @override
  Future<List<ScanResult>> build() async {
    // Re-evaluate history whenever the active authenticated user changes.
    final user = ref.watch(authNotifierProvider).asData?.value;
    final currentUserId = user?.uid ?? 'guest';
    final repo = ref.read(historyRepositoryProvider);

    if (user != null) {
      final cloudService = ref.read(cloudSyncServiceProvider);
      final cloudScans = await cloudService.fetchCloudScans(user.uid);
      if (cloudScans.isNotEmpty) {
        final local = await repo.getAll(userId: user.uid);
        final localDates = local
            .map((e) => e.createdAt.toIso8601String())
            .toSet();
        for (final cloudItem in cloudScans) {
          if (!localDates.contains(cloudItem.createdAt.toIso8601String())) {
            await repo.insert(
              cloudItem.copyWith(userId: user.uid, synced: true),
            );
          }
        }
      }
    }

    return repo.getAll(userId: currentUserId);
  }

  Future<void> add(ScanResult result) async {
    final currentUserId = _currentUserId;
    final resultWithOwner = result.copyWith(userId: currentUserId);

    await ref.read(historyRepositoryProvider).insert(resultWithOwner);
    state = await AsyncValue.guard(
      () => ref.read(historyRepositoryProvider).getAll(userId: currentUserId),
    );
  }

  Future<void> delete(int id) async {
    final currentUserId = _currentUserId;
    await ref.read(historyRepositoryProvider).delete(id);
    state = await AsyncValue.guard(
      () => ref.read(historyRepositoryProvider).getAll(userId: currentUserId),
    );
  }

  Future<void> toggleFavorite(int id, bool currentStatus) async {
    final currentUserId = _currentUserId;
    await ref
        .read(historyRepositoryProvider)
        .toggleFavorite(id, !currentStatus);
    state = await AsyncValue.guard(
      () => ref.read(historyRepositoryProvider).getAll(userId: currentUserId),
    );
  }

  Future<void> refresh() async {
    final currentUserId = _currentUserId;
    state = await AsyncValue.guard(
      () => ref.read(historyRepositoryProvider).getAll(userId: currentUserId),
    );
  }
}
