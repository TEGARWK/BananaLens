import 'dart:convert';

import 'package:fruitlens/data/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exception thrown by [AuthService] when authentication or validation fails.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Contract for authentication and profile management.
abstract class AuthService {
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile> login(String email, String password);
  Future<UserProfile> loginWithGoogle();
  Future<UserProfile> register(String email, String password, String name);
  Future<void> resetPassword(String email, String newPassword);
  Future<void> updateProfile(UserProfile profile);
  Future<void> logout();
}

/// Local persistent implementation of [AuthService] using [SharedPreferences].
class LocalAuthService implements AuthService {
  static const String _sessionKey = 'fruitlens_current_user';
  static const String _usersPrefix = 'fruitlens_user_';
  static const String _passwordsPrefix = 'fruitlens_pwd_';

  /// Built-in demo credentials for quick local testing and exploration.
  static const String demoEmail = 'budi@fruitlens.id';
  static const String demoPassword = '123456';

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Computes a deterministic 128-bit salted digest using 32-bit arithmetic
  /// so behavior is identical on Dart VM and web/JS targets without extra packages.
  String _hashPassword(String normalizedEmail, String password) {
    final bytes = utf8.encode('fruitlens_v1|$normalizedEmail|$password');
    var h1 = 0x811c9dc5;
    var h2 = 0x9e3779b1;
    var h3 = 0x85ebca6b;
    var h4 = 0xc2b2ae35;

    for (var round = 0; round < 256; round++) {
      h1 = (h1 ^ round) & 0xffffffff;
      for (final byte in bytes) {
        h1 = ((h1 ^ byte) * 0x01000193) & 0xffffffff;
        h2 = ((h2 + h1 + byte) * 0x85ebca77) & 0xffffffff;
        h3 = ((h3 ^ h2) * 0xc2b2ae3d) & 0xffffffff;
        h4 = ((h4 + h3 ^ byte) * 0x27d4eb2f) & 0xffffffff;
      }
      // Cross-lane diffusion
      final tmp = h1;
      h1 = ((h1 << 7) | (h1 >>> 25)) ^ h3;
      h3 = ((h3 << 13) | (h3 >>> 19)) ^ h2;
      h2 = ((h2 << 11) | (h2 >>> 21)) ^ h4;
      h4 = ((h4 << 17) | (h4 >>> 15)) ^ tmp;
    }

    String hex32(int v) => (v & 0xffffffff).toRadixString(16).padLeft(8, '0');
    return '${hex32(h1)}${hex32(h2)}${hex32(h3)}${hex32(h4)}';
  }

  UserProfile _buildDemoProfile() {
    return const UserProfile(
      uid: 'demo_budi',
      email: demoEmail,
      name: 'Budi Santoso',
      age: 26,
      weight: 68.0,
      goal: 'Energi & Imunitas',
      allergies: <String>['Susu / Laktosa'],
    );
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserProfile.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserProfile> login(String email, String password) async {
    final normalized = _normalizeEmail(email);
    if (normalized.isEmpty || password.isEmpty) {
      throw const AuthException('Email dan kata sandi wajib diisi.');
    }

    final prefs = await SharedPreferences.getInstance();
    final rawUser =
        prefs.getString('$_usersPrefix$normalized') ??
        prefs.getString('$_usersPrefix${email.trim()}');

    if (rawUser == null) {
      // Seed the built-in demo account transparently on first demo login.
      if (normalized == demoEmail && password == demoPassword) {
        final demoUser = _buildDemoProfile();
        await prefs.setString(
          '$_passwordsPrefix$normalized',
          _hashPassword(normalized, password),
        );
        await prefs.setString(
          '$_usersPrefix$normalized',
          demoUser.toJsonString(),
        );
        await prefs.setString(_sessionKey, demoUser.toJsonString());
        return demoUser;
      }
      throw const AuthException('Akun dengan email ini belum terdaftar.');
    }

    final savedHash = prefs.getString('$_passwordsPrefix$normalized');
    if (savedHash == null) {
      if (normalized == demoEmail && password == demoPassword) {
        await prefs.setString(
          '$_passwordsPrefix$normalized',
          _hashPassword(normalized, password),
        );
      } else {
        throw const AuthException(
          'Akun perlu pembaruan keamanan. Gunakan "Lupa kata sandi?" untuk mengatur ulang.',
        );
      }
    } else if (savedHash != _hashPassword(normalized, password)) {
      throw const AuthException('Kata sandi yang Anda masukkan salah.');
    }

    final user = UserProfile.fromJsonString(rawUser);
    await prefs.setString(_sessionKey, user.toJsonString());
    return user;
  }

  @override
  Future<UserProfile> loginWithGoogle() async {
    throw const AuthException(
      'Masuk dengan Google membutuhkan layanan Firebase yang aktif.',
    );
  }

  @override
  Future<UserProfile> register(
    String email,
    String password,
    String name,
  ) async {
    final normalized = _normalizeEmail(email);
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const AuthException('Nama lengkap wajib diisi.');
    }
    if (normalized.isEmpty || !normalized.contains('@')) {
      throw const AuthException('Format email tidak valid.');
    }
    if (password.length < 6) {
      throw const AuthException('Kata sandi minimal 6 karakter.');
    }

    final prefs = await SharedPreferences.getInstance();
    final existing =
        prefs.getString('$_usersPrefix$normalized') ??
        prefs.getString('$_usersPrefix${email.trim()}');
    if (existing != null) {
      throw const AuthException(
        'Email ini sudah terdaftar. Silakan masuk ke akun Anda.',
      );
    }

    final user = UserProfile(
      uid: 'local_${DateTime.now().millisecondsSinceEpoch}',
      email: normalized,
      name: trimmedName,
    );
    await prefs.setString(
      '$_passwordsPrefix$normalized',
      _hashPassword(normalized, password),
    );
    await prefs.setString('$_usersPrefix$normalized', user.toJsonString());
    await prefs.setString(_sessionKey, user.toJsonString());
    return user;
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    final normalized = _normalizeEmail(email);
    if (normalized.isEmpty || !normalized.contains('@')) {
      throw const AuthException('Format email tidak valid.');
    }
    if (newPassword.length < 6) {
      throw const AuthException('Kata sandi baru minimal 6 karakter.');
    }

    final prefs = await SharedPreferences.getInstance();
    final existing =
        prefs.getString('$_usersPrefix$normalized') ??
        prefs.getString('$_usersPrefix${email.trim()}');
    if (existing == null) {
      if (normalized == demoEmail) {
        final demoUser = _buildDemoProfile();
        await prefs.setString(
          '$_usersPrefix$normalized',
          demoUser.toJsonString(),
        );
      } else {
        throw const AuthException(
          'Email belum terdaftar. Periksa kembali alamat email Anda.',
        );
      }
    }

    await prefs.setString(
      '$_passwordsPrefix$normalized',
      _hashPassword(normalized, newPassword),
    );
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeEmail(profile.email);
    await prefs.setString('$_usersPrefix$normalized', profile.toJsonString());
    await prefs.setString(_sessionKey, profile.toJsonString());
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
