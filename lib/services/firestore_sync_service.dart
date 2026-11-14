import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/data/repositories/history_repository.dart';

/// Contract for synchronizing local SQLite data and User Profiles with Cloud Firestore.
abstract class CloudSyncService {
  Future<void> syncUserProfile(UserProfile profile);
  Future<UserProfile?> fetchUserProfile(String uid);
  Future<int> syncPendingScans(String uid, HistoryRepository localRepo);
  Future<List<ScanResult>> fetchCloudScans(String uid);
}

/// Cloud Firestore implementation of [CloudSyncService].
class FirestoreSyncService implements CloudSyncService {
  FirestoreSyncService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _scansCollection = 'scans';

  @override
  Future<void> syncUserProfile(UserProfile profile) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(profile.uid);
      await docRef.set(<String, Object?>{
        ...profile.toJson(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log(
        'Gagal menyinkronkan profil ke Firestore: $e',
        name: 'FirestoreSync',
      );
    }
  }

  @override
  Future<UserProfile?> fetchUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      final data = docSnapshot.data();
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e) {
      developer.log(
        'Gagal mengambil profil dari Firestore: $e',
        name: 'FirestoreSync',
      );
      return null;
    }
  }

  @override
  Future<int> syncPendingScans(String uid, HistoryRepository localRepo) async {
    var syncedCount = 0;
    try {
      final pending = await localRepo.getUnsynced(userId: uid);
      if (pending.isEmpty) return 0;

      final scansRef = _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_scansCollection);

      for (final scan in pending) {
        final docId =
            'scan_${scan.id ?? scan.createdAt.millisecondsSinceEpoch}';
        await scansRef.doc(docId).set(<String, Object?>{
          'image_path': scan.imagePath,
          'fruit_label': scan.fruitLabel,
          'ripeness_label': scan.ripenessLabel,
          'confidence': scan.confidence,
          'created_at': scan.createdAt.toIso8601String(),
          'is_favorite': scan.isFavorite,
          'synced_at': FieldValue.serverTimestamp(),
        });

        if (scan.id != null) {
          await localRepo.markAsSynced(scan.id!);
          syncedCount++;
        }
      }
    } catch (e) {
      developer.log(
        'Gagal sinkronisasi riwayat scan ke Firestore: $e',
        name: 'FirestoreSync',
      );
    }
    return syncedCount;
  }

  @override
  Future<List<ScanResult>> fetchCloudScans(String uid) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_scansCollection)
          .orderBy('created_at', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return ScanResult(
          userId: uid,
          imagePath: data['image_path'] as String? ?? '',
          fruitLabel: data['fruit_label'] as String? ?? '',
          ripenessLabel: data['ripeness_label'] as String? ?? '',
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
          createdAt:
              DateTime.tryParse(data['created_at'] as String? ?? '') ??
              DateTime.now(),
          isFavorite: data['is_favorite'] as bool? ?? false,
          synced: true,
        );
      }).toList();
    } catch (e) {
      developer.log(
        'Gagal mengambil riwayat scan dari Firestore: $e',
        name: 'FirestoreSync',
      );
      return <ScanResult>[];
    }
  }
}

/// Fallback / mock implementation used in unit tests and offline environments.
class NoOpCloudSyncService implements CloudSyncService {
  @override
  Future<void> syncUserProfile(UserProfile profile) async {}

  @override
  Future<UserProfile?> fetchUserProfile(String uid) async => null;

  @override
  Future<int> syncPendingScans(String uid, HistoryRepository localRepo) async =>
      0;

  @override
  Future<List<ScanResult>> fetchCloudScans(String uid) async => <ScanResult>[];
}
