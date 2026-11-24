import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../widgets/industrial_art.dart';
import '../widgets/splash_scanner_mark.dart';

/// Animated brand launch splash screen showcasing the BananaLens optical
/// scanner viewfinder mark in flat Ripe Banana Gold & Roasted Cocoa Brown.
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.s16),
          child: CustomPaint(
            foregroundPainter: ScannerCornerPainter(
              color: harvest.accent.withValues(alpha: 0.22),
              bracketLength: 22,
              strokeWidth: 1.8,
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.s24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        SplashScannerMark(progress: t),
                        const SizedBox(height: AppDimens.s24),
                        _AnimatedBrandWordmark(progress: t),
                        const Spacer(flex: 3),
                        _OpticalProgressBar(progress: t),
                        const SizedBox(height: AppDimens.s24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
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
      0.26,
      0.54,
      curve: Curves.easeOutCubic,
    ).transform(progress);
    final subT = const Interval(
      0.38,
      0.66,
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
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.s12),
        Opacity(
          opacity: subT,
          child: Transform.translate(
            offset: Offset(0, (1.0 - subT) * 10),
            child: const IndustrialTagChip(
              label: AppStrings.splashBadge,
              accent: true,
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

class _OpticalProgressBar extends StatelessWidget {
  const _OpticalProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final barFade = const Interval(0.14, 0.34).transform(progress);
    final fillFraction = const Interval(
      0.16,
      0.86,
      curve: Curves.easeInOutCubic,
    ).transform(progress);
    final percent = (fillFraction * 100).round();

    return Opacity(
      opacity: barFade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 156,
            height: 6,
            decoration: BoxDecoration(
              color: harvest.primarySoft,
              borderRadius: BorderRadius.circular(AppDimens.rSharp),
            ),
            clipBehavior: Clip.antiAlias,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fillFraction.clamp(0.06, 1.0),
                child: ColoredBox(
                  color: harvest.accent,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.s8),
          Text(
            'MENYIAPKAN SCANNER · $percent%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: harvest.muted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
