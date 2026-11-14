import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../widgets/splash_scanner_mark.dart';

/// Animated brand launch splash screen showcasing the FruitLens scanner mark.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    this.onCompleted,
    this.duration = const Duration(milliseconds: 3400),
    super.key,
  });

  /// Invoked when the launch choreography finishes. If omitted (e.g. direct
  /// `/splash` route), defaults to navigating to `/`.
  final VoidCallback? onCompleted;

  /// Total splash duration including the settle hold before fading out.
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _reducedMotionTimer;
  bool _finished = false;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1.0;
      _reducedMotionTimer = Timer(
        const Duration(milliseconds: 450),
        _completeSplash,
      );
    } else {
      _controller.addStatusListener(_handleStatusChanged);
      // Start after the first rendered frame so Android's native splash
      // handoff never clips the opening pop-in choreography.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_finished) {
          _controller.forward();
        }
      });
    }
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _completeSplash();
    }
  }

  void _completeSplash() {
    if (_finished || !mounted) return;
    _finished = true;
    if (widget.onCompleted != null) {
      widget.onCompleted!();
      return;
    }
    context.go('/');
  }

  @override
  void dispose() {
    _reducedMotionTimer?.cancel();
    _controller.removeStatusListener(_handleStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _SplashBackgroundAura(harvest: harvest, theme: theme),
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.s32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        SplashScannerMark(progress: t),
                        const SizedBox(height: AppDimens.s24),
                        _AnimatedBrandWordmark(progress: t),
                        const Spacer(flex: 3),
                        _OpticalProgressPill(progress: t),
                        const SizedBox(height: AppDimens.s32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackgroundAura extends StatelessWidget {
  const _SplashBackgroundAura({required this.harvest, required this.theme});

  final HarvestColors harvest;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.25),
          radius: 1.05,
          colors: [
            harvest.primarySoft.withValues(alpha: 0.72),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _AnimatedBrandWordmark extends StatelessWidget {
  const _AnimatedBrandWordmark({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final titleT = const Interval(
      0.28,
      0.56,
      curve: Curves.easeOutCubic,
    ).transform(progress);
    final subT = const Interval(
      0.40,
      0.68,
      curve: Curves.easeOutCubic,
    ).transform(progress);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: titleT,
          child: Transform.translate(
            offset: Offset(0, (1.0 - titleT) * 14),
            child: Text(
              AppStrings.appName,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: -0.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.s8),
        Opacity(
          opacity: subT,
          child: Transform.translate(
            offset: Offset(0, (1.0 - subT) * 10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.s12,
                vertical: AppDimens.s4,
              ),
              decoration: BoxDecoration(
                color: harvest.primarySoft,
                borderRadius: BorderRadius.circular(AppDimens.rPill),
                border: Border.all(color: harvest.border),
              ),
              child: Text(
                AppStrings.splashBadge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.s12),
        Opacity(
          opacity: subT,
          child: Text(
            AppStrings.splashTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: harvest.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _OpticalProgressPill extends StatelessWidget {
  const _OpticalProgressPill({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final barFade = const Interval(0.14, 0.34).transform(progress);
    final fillFraction = const Interval(
      0.16,
      0.85,
      curve: Curves.easeInOutCubic,
    ).transform(progress);

    return Opacity(
      opacity: barFade,
      child: SizedBox(
        width: 112,
        height: 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          child: Stack(
            children: [
              ColoredBox(color: harvest.border, child: const SizedBox.expand()),
              FractionallySizedBox(
                widthFactor: fillFraction.clamp(0.08, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, harvest.accent],
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
