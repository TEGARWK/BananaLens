import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/ui/widgets/app_card.dart';
import 'package:fruitlens/ui/widgets/primary_button.dart';
import 'package:fruitlens/ui/widgets/soft_button.dart';
import 'package:go_router/go_router.dart';

/// Compact profile header card supporting Guest and Authenticated states.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.user,
    required this.onLoginDemo,
    super.key,
  });

  final UserProfile? user;
  final VoidCallback onLoginDemo;

  @override
  Widget build(BuildContext context) {
    return user == null ? _buildGuestCard(context) : _buildUserCard(context);
  }

  Widget _buildGuestCard(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final primary = theme.colorScheme.primary;

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: harvest.primarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.rCard),
                ),
                child: Icon(Icons.person_outline_rounded, color: primary),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belum Masuk ke Akun',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Masuk untuk simpan preferensi gizi & alergi.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: harvest.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Masuk',
                  height: 44,
                  onPressed: () => context.push('/auth'),
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: SoftButton(
                  text: 'Daftar',
                  height: 44,
                  fullWidth: true,
                  onPressed: () => context.push('/auth?mode=register'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          TextButton.icon(
            onPressed: onLoginDemo,
            icon: Icon(Icons.bolt_rounded, size: 17, color: primary),
            label: Text(
              'Coba Akun Demo (1-Klik)',
              style: theme.textTheme.labelMedium?.copyWith(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    final profile = user!;
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final primary = theme.colorScheme.primary;
    final displayName = profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'Pengguna FruitLens';
    final initial = displayName[0].toUpperCase();

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      onTap: () => context.push('/account-settings'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: harvest.primarySoft,
            child: Text(
              initial,
              style: theme.textTheme.titleLarge?.copyWith(
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: harvest.muted,
                  ),
                ),
                const SizedBox(height: AppDimens.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s8,
                    vertical: AppDimens.s4,
                  ),
                  decoration: BoxDecoration(
                    color: harvest.primarySoft,
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                  ),
                  child: Text(
                    profile.goal,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: harvest.muted),
        ],
      ),
    );
  }
}
