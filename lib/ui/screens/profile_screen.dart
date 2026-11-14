import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/core/theme/theme_controller.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/ui/widgets/fruitlens_app_bar.dart';
import 'package:fruitlens/ui/widgets/profile_header_card.dart';
import 'package:fruitlens/ui/widgets/profile_history_card.dart';
import 'package:fruitlens/ui/widgets/profile_menu_section.dart';
import 'package:fruitlens/ui/widgets/soft_button.dart';
import 'package:fruitlens/ui/widgets/theme_picker_sheet.dart';
import 'package:go_router/go_router.dart';

/// Clean, compact Profile screen structured around Profile -> History ->
/// Account Settings -> App Settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: const FruitLensAppBar(
        title: 'Profil Saya',
        leadingIcon: Icons.person_rounded,
      ),
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: SoftButton(
            text: 'Muat Ulang Profil',
            onPressed: () => ref.invalidate(authNotifierProvider),
          ),
        ),
        data: (user) =>
            _buildContent(context, ref, user: user, themeMode: themeMode),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required UserProfile? user,
    required ThemeMode themeMode,
  }) {
    final accountSubtitle = user == null
        ? 'Masuk untuk atur tujuan & alergi buah'
        : _summarizePreferences(user);

    final accountItems = <ProfileMenuItem>[
      ProfileMenuItem(
        icon: Icons.manage_accounts_outlined,
        title: 'Profil & Preferensi Kesehatan',
        subtitle: accountSubtitle,
        onTap: () => context.push(user == null ? '/auth' : '/account-settings'),
      ),
      ProfileMenuItem(
        icon: Icons.lock_outline_rounded,
        title: 'Keamanan & Kata Sandi',
        subtitle: 'Ubah atau atur ulang kata sandi akun',
        onTap: () {
          final query = user == null
              ? ''
              : '?email=${Uri.encodeComponent(user.email)}';
          context.push('/forgot-password$query');
        },
      ),
      if (user != null)
        ProfileMenuItem(
          icon: Icons.logout_rounded,
          title: 'Keluar dari Akun',
          subtitle: 'Akhiri sesi pada perangkat ini',
          isDestructive: true,
          onTap: () => _confirmLogout(context, ref),
        ),
    ];

    final settingItems = <ProfileMenuItem>[
      ProfileMenuItem(
        icon: Icons.palette_outlined,
        title: 'Tema & Tampilan',
        subtitle: themeModeLabel(themeMode),
        onTap: () => ThemePickerSheet.show(context),
      ),
      ProfileMenuItem(
        icon: Icons.memory_rounded,
        title: 'Engine AI On-Device',
        subtitle: 'TFLite MobileNetV3 + SVM · Google ML Kit',
        onTap: () => _showAboutDialog(context),
      ),
      ProfileMenuItem(
        icon: Icons.menu_book_outlined,
        title: 'Panduan Penggunaan',
        subtitle: 'Lihat ulang cara kerja FruitLens',
        onTap: () => context.go('/onboarding'),
      ),
      ProfileMenuItem(
        icon: Icons.info_outline_rounded,
        title: 'Tentang FruitLens',
        subtitle: 'Versi 1.0.0 · Privasi pemindaian lokal',
        onTap: () => _showAboutDialog(context),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.s16,
        AppDimens.s16,
        AppDimens.s16,
        AppDimens.s32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeaderCard(
            user: user,
            onLoginDemo: () => _loginDemoAccount(context, ref),
          ),
          const SizedBox(height: AppDimens.s16),
          const ProfileHistoryCard(),
          const SizedBox(height: AppDimens.s20),
          ProfileMenuSection(title: 'Pengaturan Akun', items: accountItems),
          const SizedBox(height: AppDimens.s20),
          ProfileMenuSection(title: 'Pengaturan', items: settingItems),
        ],
      ),
    );
  }

  String _summarizePreferences(UserProfile user) {
    final allergyCount = user.allergies.length;
    final allergyText = allergyCount == 0
        ? 'Tanpa alergi tercatat'
        : '$allergyCount alergi aktif';
    return '${user.goal} · $allergyText';
  }

  Future<void> _loginDemoAccount(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(authNotifierProvider.notifier);
    try {
      await notifier.login('budi@fruitlens.id', '123456');
    } catch (_) {
      await notifier.register('budi@fruitlens.id', '123456', 'Budi Santoso');
    }
    final user = ref.read(authNotifierProvider).asData?.value;
    if (user != null) {
      await notifier.updateProfile(
        user.copyWith(
          name: 'Budi Santoso',
          age: 26,
          weight: 64.5,
          goal: 'Pola Hidup Sehat',
          allergies: const <String>['Lateks (Alpukat/Pisang)'],
        ),
      );
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Masuk ke Akun Demo (Budi Santoso)')),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
        ),
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Riwayat pemindaian di perangkat ini tetap tersimpan dengan aman.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
        ),
        title: const Text('FruitLens v1.0.0'),
        content: Text(
          'Deteksi jenis & kematangan buah secara instan langsung di perangkat '
          'dengan model TFLite offline-first, dilengkapi referensi nutrisi USDA & Kemenkes RI.',
          style: theme.textTheme.bodyMedium?.copyWith(color: harvest.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
