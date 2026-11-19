import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';
import 'package:fruitlens/ui/widgets/primary_button.dart';
import 'package:fruitlens/ui/widgets/soft_button.dart';
import 'package:go_router/go_router.dart';

/// Layered tactile profile header card supporting Guest and Authenticated states.
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
    final ink = theme.colorScheme.onSurface;

    return IndustrialSpecimenCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const IndustrialTagChip(label: 'MODE TAMU // OFFLINE'),
              Text(
                'BANANALENS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: harvest.muted,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s16),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  border: Border.all(color: ink, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: ink,
                      offset: const Offset(2.5, 2.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: theme.colorScheme.onPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belum Masuk ke Akun',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
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
                  height: 48,
                  onPressed: () => context.push('/auth'),
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: SoftButton(
                  text: 'Daftar',
                  height: 48,
                  fullWidth: true,
                  onPressed: () => context.push('/auth?mode=register'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          TextButton.icon(
            onPressed: onLoginDemo,
            icon: Icon(Icons.bolt_rounded, size: 17, color: ink),
            label: Text(
              'Coba Akun Demo (1-Klik)',
              style: theme.textTheme.labelMedium?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
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
    final ink = theme.colorScheme.onSurface;
    final displayName = profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'Pengguna BananaLens';
    final initial = displayName[0].toUpperCase();
    final allergyCount = profile.allergies.length;

    return IndustrialSpecimenCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const IndustrialTagChip(label: 'AKUN AKTIF', accent: true),
              Text(
                'BANANALENS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: harvest.muted,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  border: Border.all(color: ink, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: ink,
                      offset: const Offset(2.5, 2.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTheme.pixelDisplayStyle(
                    context,
                    fontSize: 22,
                    color: theme.colorScheme.onPrimary,
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: harvest.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s12),
          Divider(color: harvest.border, height: 1),
          const SizedBox(height: AppDimens.s12),
          Wrap(
            spacing: AppDimens.s8,
            runSpacing: AppDimens.s8,
            children: [
              _ProfileStatBadge(icon: Icons.flag_outlined, label: profile.goal),
              _ProfileStatBadge(
                icon: Icons.health_and_safety_outlined,
                label: allergyCount == 0
                    ? 'Tanpa alergi'
                    : '$allergyCount alergi',
              ),
              if (profile.age > 0)
                _ProfileStatBadge(
                  icon: Icons.cake_outlined,
                  label: '${profile.age} thn',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStatBadge extends StatelessWidget {
  const _ProfileStatBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s8 + 2,
        vertical: AppDimens.s4 + 1,
      ),
      decoration: BoxDecoration(
        color: harvest.primarySoft,
        borderRadius: BorderRadius.circular(AppDimens.rSharp),
        border: Border.all(color: harvest.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: ink),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: ink,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
