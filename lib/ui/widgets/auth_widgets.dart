import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';

/// Clean centered hero illustration + headline adapting to Login/Register mode.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.isRegister});

  final bool isRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final imagePath = isRegister
        ? 'assets/images/auth/auth_register.png'
        : 'assets/images/auth/auth_login.png';

    return Column(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: SizedBox(
            key: ValueKey<bool>(isRegister),
            height: 164,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                isRegister ? Icons.restaurant_rounded : Icons.eco_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.s12),
        Text(
          isRegister ? 'Buat Profil Sehatmu' : 'Selamat Datang Kembali',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimens.s4),
        Text(
          isRegister
              ? 'Simpan target gizi, pantau alergi, dan racik olahan buah segar.'
              : 'Lanjutkan pemantauan kematangan buah dan nutrisi harianmu.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
        ),
      ],
    );
  }
}

/// Prompt toggle below the primary submit button switching Login/Register.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.isRegister,
    required this.onToggle,
  });

  final bool isRegister;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          isRegister ? 'Sudah punya akun?' : 'Belum punya akun?',
          style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
        ),
        TextButton(
          onPressed: onToggle,
          child: Text(
            isRegister ? 'Masuk di sini' : 'Daftar di sini',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Inline Fresh Harvest error banner shared across auth forms and screens.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.s12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppDimens.rButton),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppDimens.s8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Labeled divider separating primary auth form from Demo Login.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'atau'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: harvest.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.s12),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
          ),
        ),
        Expanded(child: Divider(color: harvest.border)),
      ],
    );
  }
}
