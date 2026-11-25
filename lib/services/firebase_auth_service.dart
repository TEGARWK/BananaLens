import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase Authentication implementation of [AuthService].
///
/// Handles user login, Google Sign-In, registration, password resets, and session
/// management via Firebase Auth, with supplementary profile fields cached locally
/// in [SharedPreferences] until Cloud Firestore is fully synchronized.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    fb.FirebaseAuth? firebaseAuth,
    SharedPreferences? preferences,
  }) : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _prefs = preferences;

  final fb.FirebaseAuth _auth;
  SharedPreferences? _prefs;
  bool _googleInitialized = false;

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
      throw const AuthException(
        'Gagal masuk ke akun. Periksa koneksi internet dan coba lagi.',
      );
    }
  }

  @override
  Future<UserProfile> loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        final webClientId = dotenv.isInitialized
            ? dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim()
            : null;
        await googleSignIn.initialize(
          serverClientId: (webClientId != null && webClientId.isNotEmpty)
              ? webClientId
              : null,
        );
        _googleInitialized = true;
      }

      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException(
          'Token Google tidak tersedia. Pastikan Google Sign-In & SHA-1 sudah dikonfigurasi di Firebase.',
        );
      }

      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) {
        throw const AuthException('Gagal masuk dengan akun Google.');
      }

      final existing = await getCurrentUser();
      final profile =
          existing ??
          UserProfile(
            uid: user.uid,
            email: user.email ?? account.email,
            name: user.displayName ?? account.displayName ?? '',
          );

      final storage = await _storage;
      await storage.setString(
        '$_profileMetaPrefix${profile.uid}',
        profile.toJsonString(),
      );
      return profile;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Masuk dengan Google dibatalkan.');
      }
      throw const AuthException(
        'Gagal masuk dengan Google. Periksa konfigurasi atau koneksi internet.',
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException(
        'Gagal masuk dengan Google. Periksa koneksi internet dan coba lagi.',
      );
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
      throw const AuthException(
        'Pendaftaran belum berhasil. Periksa koneksi internet dan coba lagi.',
      );
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
      throw const AuthException(
        'Gagal mengirim tautan atur ulang kata sandi. Coba lagi sebentar.',
      );
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
    if (_googleInitialized) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Ignore Google sign-out errors if platform session is already cleared.
      }
    }
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
