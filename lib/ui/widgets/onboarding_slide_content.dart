import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/ui/widgets/primary_button.dart';

/// Immutable data describing a single onboarding slide.
class OnboardingSlideData {
  const OnboardingSlideData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.fallbackIcon,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String imagePath;
  final IconData fallbackIcon;
}

/// Renders one illustrated onboarding slide with Fresh Harvest typography.
class OnboardingSlidePage extends StatelessWidget {
  const OnboardingSlidePage({super.key, required this.slide});

  final OnboardingSlideData slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final harvest = context.harvest;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s24,
        vertical: AppDimens.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _IllustrationFrame(
            imagePath: slide.imagePath,
            fallbackIcon: slide.fallbackIcon,
          ),
          const SizedBox(height: AppDimens.s24),
          Text(
            slide.eyebrow,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppDimens.s8),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.s12),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: harvest.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom navigation controls (dot indicators, CTA, optional login link).
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.slideCount,
    required this.currentIndex,
    required this.onNextOrStart,
    required this.onGoToAuth,
  });

  final int slideCount;
  final int currentIndex;
  final VoidCallback onNextOrStart;
  final VoidCallback onGoToAuth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final harvest = context.harvest;
    final isLast = currentIndex == slideCount - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.s24,
        AppDimens.s12,
        AppDimens.s24,
        AppDimens.s20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(slideCount, (int i) {
              final active = i == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? colorScheme.primary : harvest.border,
                  borderRadius: BorderRadius.circular(AppDimens.rPill),
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimens.s20),
          PrimaryButton(
            text: isLast ? 'Daftar Akun Baru' : 'Lanjut',
            icon: isLast
                ? Icons.person_add_rounded
                : Icons.chevron_right_rounded,
            onPressed: onNextOrStart,
          ),
          if (isLast) ...<Widget>[
            const SizedBox(height: AppDimens.s8),
            TextButton(
              onPressed: onGoToAuth,
              child: const Text('Sudah punya akun? Masuk di sini'),
            ),
          ],
        ],
      ),
    );
  }
}

class _IllustrationFrame extends StatelessWidget {
  const _IllustrationFrame({
    required this.imagePath,
    required this.fallbackIcon,
  });

  final String imagePath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 270),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Center(
            child: Icon(fallbackIcon, size: 72, color: colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
