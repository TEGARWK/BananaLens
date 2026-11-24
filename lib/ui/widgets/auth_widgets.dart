import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';

/// Illustrated editorial header adapting smoothly between Login and Register
/// modes, framed inside crisp 4-corner scanner viewfinder brackets (`┌ ┐ └ ┘`).
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.isRegister});

  final bool isRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isIncoming = child.key == ValueKey<bool>(isRegister);
          final direction = isRegister ? 1.0 : -1.0;
          final beginOffset = isIncoming
              ? Offset(direction, 0)
              : Offset(-direction, 0);
          return SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: Column(
          key: ValueKey<bool>(isRegister),
          children: <Widget>[
            IndustrialTagChip(
              label: isRegister
                  ? 'DAFTAR // BANANALENS'
                  : 'MASUK // BANANALENS',
              accent: true,
            ),
            const SizedBox(height: AppDimens.s16),
            Center(
              child: ScannerFrame(
                bracketLength: 16,
                strokeWidth: 2.0,
                bracketColor: harvest.accent,
                padding: const EdgeInsets.all(AppDimens.s12),
                child: Container(
                  width: 196,
                  height: isRegister ? 124 : 152,
                  decoration: BoxDecoration(
                    color: harvest.primarySoft,
                    borderRadius: BorderRadius.circular(AppDimens.rButton),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(AppDimens.s8),
                  child: Image.asset(
                    isRegister
                        ? 'assets/images/auth/auth_register.png'
                        : 'assets/images/auth/auth_login.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.s16),
            Text(
              isRegister ? 'Buat Profil Sehatmu' : 'Selamat Datang',
              textAlign: TextAlign.center,
              style: AppTheme.pixelDisplayStyle(
                context,
                fontSize: 24,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimens.s4),
            Text(
              isRegister
                  ? 'Simpan target gizi, pantau alergi, dan racik olahan pisang segar.'
                  : 'Lanjutkan pemantauan kematangan pisang dan nutrisi harianmu.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
            ),
          ],
        ),
      ),
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
              color: harvest.accent,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
              decorationColor: harvest.accent,
            ),
          ),
        ),
      ],
    );
  }
}

/// Flat editorial error banner with a crisp left accent bar (zero full-box stroke).
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.rButton),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.12),
          border: Border(
            left: BorderSide(color: colorScheme.error, width: 3.5),
          ),
        ),
        padding: const EdgeInsets.all(AppDimens.s12),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: colorScheme.error,
            ),
            const SizedBox(width: AppDimens.s8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Labeled divider separating primary auth form from secondary actions.
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

/// Shows a crisp flat Banana Gold scanner stamp overlay upon login/register success.
void showAuthSuccessOverlay(BuildContext context, {required bool isRegister}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _AuthSuccessOverlay(
      isRegister: isRegister,
      onCompleted: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _AuthSuccessOverlay extends StatefulWidget {
  const _AuthSuccessOverlay({
    required this.isRegister,
    required this.onCompleted,
  });

  final bool isRegister;
  final VoidCallback onCompleted;

  @override
  State<_AuthSuccessOverlay> createState() => _AuthSuccessOverlayState();
}

class _AuthSuccessOverlayState extends State<_AuthSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 750),
        )..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            widget.onCompleted();
          }
        });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final yellow = theme.colorScheme.primary;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          final t = _controller.value;
          final inCurve = const Interval(
            0.0,
            0.35,
            curve: Curves.easeOutBack,
          ).transform(t);
          final outCurve = const Interval(
            0.72,
            1.0,
            curve: Curves.easeIn,
          ).transform(t);
          final opacity = (inCurve.clamp(0.0, 1.0)) * (1.0 - outCurve);
          final scale = 0.88 + (0.12 * inCurve);

          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              color: ink.withValues(alpha: 0.22 * (1.0 - outCurve)),
              alignment: Alignment.center,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    color: yellow,
                    borderRadius: BorderRadius.circular(AppDimens.rHero),
                  ),
                  child: CustomPaint(
                    foregroundPainter: ScannerCornerPainter(
                      color: harvest.accent,
                      bracketLength: 14,
                      strokeWidth: 2.0,
                      inset: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.s32,
                        vertical: AppDimens.s24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.verified_rounded,
                            size: 36,
                            color: theme.colorScheme.onPrimary,
                          ),
                          const SizedBox(height: AppDimens.s8),
                          Text(
                            widget.isRegister
                                ? 'Akun Dibuat'
                                : 'Berhasil Masuk',
                            style: AppTheme.pixelDisplayStyle(
                              context,
                              fontSize: 18,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimens.s4),
                          Text(
                            'AKSES DITERIMA // BANANALENS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: harvest.accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
