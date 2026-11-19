import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';
import 'package:fruitlens/ui/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

/// Compact summary header displaying the active user avatar, name, and email.
class AccountIdentityBanner extends StatelessWidget {
  const AccountIdentityBanner({required this.user, super.key});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final name = user.name.trim().isNotEmpty ? user.name.trim() : 'Pengguna';
    final initial = name[0].toUpperCase();

    final ink = theme.colorScheme.onSurface;

    return IndustrialSpecimenCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppDimens.rButton),
              border: Border.all(color: ink, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: ink,
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTheme.pixelDisplayStyle(
                context,
                fontSize: 18,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: harvest.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Clean navigation tile linking to the password reset flow.
class AccountPasswordTile extends StatelessWidget {
  const AccountPasswordTile({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final ink = theme.colorScheme.onSurface;

    return InkWell(
      onTap: () =>
          context.push('/forgot-password?email=${Uri.encodeComponent(email)}'),
      borderRadius: BorderRadius.circular(AppDimens.rCard),
      child: IndustrialSpecimenCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s12,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppDimens.rButton - 2),
                border: Border.all(color: ink, width: 1.3),
              ),
              child: Icon(Icons.lock_reset_rounded, size: 20, color: ink),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubah Kata Sandi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Perbarui kata sandi keamanan akunmu',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: harvest.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: ink),
          ],
        ),
      ),
    );
  }
}

/// Sticky bottom action bar with SafeArea spacing above system navigation bars.
class AccountBottomSaveBar extends StatelessWidget {
  const AccountBottomSaveBar({
    required this.isSaving,
    required this.onSave,
    super.key,
  });

  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: harvest.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.s16,
        AppDimens.s12,
        AppDimens.s16,
        AppDimens.s16,
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          text: 'Simpan Perubahan',
          icon: Icons.check_rounded,
          isLoading: isSaving,
          onPressed: isSaving ? null : onSave,
        ),
      ),
    );
  }
}
