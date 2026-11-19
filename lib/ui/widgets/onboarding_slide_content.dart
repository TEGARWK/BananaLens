import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';
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
    final harvest = context.harvest;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s24,
        vertical: AppDimens.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppDimens.s8),
          _AnimatedIllustrationFrame(
            key: ValueKey<String>(slide.imagePath),
            imagePath: slide.imagePath,
            fallbackIcon: slide.fallbackIcon,
          ),
          const SizedBox(height: AppDimens.s16),
          Center(child: IndustrialTagChip(label: slide.eyebrow, accent: true)),
          const SizedBox(height: AppDimens.s20),
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
    this.isLoggedIn = false,
  });

  final int slideCount;
  final int currentIndex;
  final VoidCallback onNextOrStart;
  final VoidCallback onGoToAuth;
  final bool isLoggedIn;

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
                width: active ? 28 : 10,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? colorScheme.primary : harvest.primarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(
                    color: active ? colorScheme.onSurface : harvest.border,
                    width: 1.2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimens.s20),
          PrimaryButton(
            text: isLast
                ? (isLoggedIn ? 'Selesai' : 'Daftar Akun Baru')
                : 'Lanjut',
            icon: isLast
                ? (isLoggedIn ? Icons.check_rounded : Icons.person_add_rounded)
                : Icons.chevron_right_rounded,
            onPressed: onNextOrStart,
          ),
          if (isLast && !isLoggedIn) ...<Widget>[
            const SizedBox(height: AppDimens.s8),
            TextButton(
              onPressed: onGoToAuth,
              child: Text(
                'Sudah punya akun? Masuk di sini',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedIllustrationFrame extends StatefulWidget {
  const _AnimatedIllustrationFrame({
    required this.imagePath,
    required this.fallbackIcon,
    super.key,
  });

  final String imagePath;
  final IconData fallbackIcon;

  @override
  State<_AnimatedIllustrationFrame> createState() =>
      _AnimatedIllustrationFrameState();
}

class _AnimatedIllustrationFrameState extends State<_AnimatedIllustrationFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    final imageWidget = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 330),
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Center(
            child: Icon(
              widget.fallbackIcon,
              size: 72,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );

    if (reducedMotion) return imageWidget;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final t = _controller.value;
        final pop = const Interval(
          0.0,
          0.55,
          curve: Curves.easeOutBack,
        ).transform(t);
        final sway = const Interval(
          0.35,
          1.0,
          curve: Curves.easeInOut,
        ).transform(t);
        final angle =
            (-0.035 * (1.0 - pop)) +
            (0.018 * (sway < 0.5 ? sway * 2 : (1.0 - sway) * 2));
        final dy = 14.0 * (1.0 - pop);

        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.rotate(
              angle: angle,
              child: Transform.scale(scale: 0.9 + (0.1 * pop), child: child),
            ),
          ),
        );
      },
      child: imageWidget,
    );
  }
}
