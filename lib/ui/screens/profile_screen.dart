import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/core/theme/theme_controller.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/ui/widgets/fruitlens_app_bar.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';
import 'package:fruitlens/ui/widgets/primary_button.dart';
import 'package:fruitlens/ui/widgets/profile_header_card.dart';
import 'package:fruitlens/ui/widgets/profile_history_card.dart';
import 'package:fruitlens/ui/widgets/profile_menu_section.dart';
import 'package:fruitlens/ui/widgets/shimmer_box.dart';
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
        loading: () => const _ProfileSkeleton(),
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
        onTap: () => _showInfoModal(context, isEngine: true),
      ),
      ProfileMenuItem(
        icon: Icons.menu_book_outlined,
        title: 'Panduan Penggunaan',
        subtitle: 'Lihat ulang cara kerja BananaLens',
        onTap: () => context.push('/onboarding'),
      ),
      ProfileMenuItem(
        icon: Icons.info_outline_rounded,
        title: 'Tentang BananaLens',
        subtitle: 'Versi 1.0.0 · Privasi pemindaian lokal',
        onTap: () => _showInfoModal(context, isEngine: false),
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
          allergies: const <String>['Pisang / Lateks'],
        ),
      );
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Masuk ke Akun Demo (Budi Santoso)')),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppDimens.s24),
        child: IndustrialSpecimenCard(
          padding: const EdgeInsets.all(AppDimens.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const IndustrialTagChip(label: 'KONFIRMASI · KELUAR'),
                  Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s16),
              Text(
                'Keluar dari Akun?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                'Riwayat pemindaian di perangkat ini tetap tersimpan dengan aman.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: harvest.muted,
                ),
              ),
              const SizedBox(height: AppDimens.s20),
              Row(
                children: [
                  Expanded(
                    child: SoftButton(
                      text: 'Batal',
                      height: 48,
                      fullWidth: true,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.rButton,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Keluar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }

  void _showInfoModal(BuildContext context, {required bool isEngine}) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppDimens.s24),
        child: IndustrialSpecimenCard(
          padding: const EdgeInsets.all(AppDimens.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IndustrialTagChip(
                    label: isEngine ? 'MOD-AI · ENGINE' : 'BANANALENS · V1.0',
                    accent: true,
                  ),
                  if (isEngine)
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                      ),
                      child: Icon(
                        Icons.memory_rounded,
                        size: 20,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  else
                    const IndustrialBananaMark(size: 40),
                ],
              ),
              const SizedBox(height: AppDimens.s16),
              Text(
                isEngine ? 'Engine AI On-Device' : 'BananaLens v1.0.0',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimens.s8),
              if (isEngine) ...[
                const _ModalSpecRow(
                  label: 'DETEKSI OBJEK',
                  value: 'Google ML Kit Image Labeling',
                ),
                const SizedBox(height: AppDimens.s8),
                const _ModalSpecRow(
                  label: 'FITUR VISUAL',
                  value: 'TFLite MobileNetV3Small + Masked HSV',
                ),
                const SizedBox(height: AppDimens.s8),
                const _ModalSpecRow(
                  label: 'KLASIFIKASI',
                  value: 'PCA + RBF SVM + Kalibrasi Pigmen',
                ),
                const SizedBox(height: AppDimens.s8),
                const _ModalSpecRow(
                  label: 'PRIVASI',
                  value: '100% Offline di Background Isolate',
                ),
              ] else
                Text(
                  'Instrumen pintar pendeteksi jenis & tingkat kematangan pisang secara instan di HP meski tanpa internet, dilengkapi info gizi dan ide resep olahan.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: harvest.muted,
                  ),
                ),
              const SizedBox(height: AppDimens.s20),
              PrimaryButton(
                text: 'Tutup',
                height: 48,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalSpecRow extends StatelessWidget {
  const _ModalSpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s8,
      ),
      decoration: BoxDecoration(
        color: harvest.primarySoft,
        borderRadius: BorderRadius.circular(AppDimens.rSharp),
        border: Border.all(color: harvest.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: harvest.muted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: const [
        ShimmerBox(height: 112, radius: AppDimens.rCard),
        SizedBox(height: AppDimens.s16),
        ShimmerBox(height: 168, radius: AppDimens.rCard),
        SizedBox(height: AppDimens.s16),
        ShimmerBox(height: 140, radius: AppDimens.rCard),
      ],
    );
  }
}
