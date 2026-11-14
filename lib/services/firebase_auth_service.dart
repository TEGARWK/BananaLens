import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase Authentication implementation of [AuthService].
///
/// Handles user login, registration, password resets, and session management
/// via Firebase Auth, with supplementary profile fields cached locally in
/// [SharedPreferences] until Cloud Firestore is fully synchronized.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    fb.FirebaseAuth? firebaseAuth,
    SharedPreferences? preferences,
  }) : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _prefs = preferences;

  final fb.FirebaseAuth _auth;
  SharedPreferences? _prefs;

  static const String _profileMetaPrefix = 'fruitlens_fb_meta_';

  Future<SharedPreferences> get _storage async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<UserProfile?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final storage = await _storage;
    final metaRaw = storage.getString('$_profileMetaPrefix${user.uid}');

    if (metaRaw != null) {
      try {
        final profile = UserProfile.fromJsonString(metaRaw);
        return profile.copyWith(
          uid: user.uid,
          email: user.email ?? profile.email,
          name: (user.displayName != null && user.displayName!.isNotEmpty)
              ? user.displayName!
              : profile.name,
        );
      } catch (_) {
        // Fallback to base UserProfile from Firebase User
      }
    }

    return UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
    );
  }

  @override
  Future<UserProfile> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Gagal masuk. Pengguna tidak ditemukan.');
      }

      final profile = await getCurrentUser();
      return profile ??
          UserProfile(
            uid: user.uid,
            email: user.email ?? email.trim(),
            name: user.displayName ?? '',
          );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Terjadi kendala autentikasi: $e');
    }
  }

  @override
  Future<UserProfile> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Gagal mendaftar. Pengguna tidak terbentuk.');
      }

      if (name.trim().isNotEmpty) {
        await user.updateDisplayName(name.trim());
      }

      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? email.trim(),
        name: name.trim(),
      );

      await updateProfile(profile);
      return profile;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Terjadi kendala registrasi: $e');
    }
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Gagal mengirim email reset kata sandi: $e');
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user != null && profile.name.trim().isNotEmpty) {
      if (user.displayName != profile.name.trim()) {
        await user.updateDisplayName(profile.name.trim());
      }
    }

    final storage = await _storage;
    await storage.setString(
      '$_profileMetaPrefix${profile.uid}',
      profile.toJsonString(),
    );
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email belum terdaftar. Silakan daftar akun baru.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan masuk.';
      case 'invalid-email':
        return 'Format alamat email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan masuk. Coba lagi beberapa saat lagi.';
      case 'user-disabled':
        return 'Akun pengguna ini telah dinonaktifkan.';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi (${e.code}).';
    }
  }
}
