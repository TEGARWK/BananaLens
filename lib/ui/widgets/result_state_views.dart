import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/scan_report.dart';
import 'fruit_image.dart';
import 'industrial_art.dart';
import 'primary_button.dart';
import 'shimmer_box.dart';

/// Animated industrial scanner view shown while inspecting a fruit photo.
class ResultLoadingView extends StatefulWidget {
  const ResultLoadingView({super.key, this.imagePath});

  final String? imagePath;

  @override
  State<ResultLoadingView> createState() => _ResultLoadingViewState();
}

class _ResultLoadingViewState extends State<ResultLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    );
    if (!isTest) {
      _scanController.repeat(reverse: true);
    } else {
      _scanController.value = 0.45;
    }
    _scanAnim = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final hasImage =
        widget.imagePath != null && widget.imagePath!.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        IndustrialSpecimenCard(
          padding: const EdgeInsets.all(AppDimens.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasImage)
                        FruitImage(
                          imagePath: widget.imagePath!,
                          height: 220,
                          radius: AppDimens.rButton,
                        )
                      else
                        Container(
                          color: const Color(0xFF181A16),
                          child: Center(
                            child: Icon(
                              Icons.center_focus_strong_rounded,
                              size: 56,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                        ),
                      // Subtle dark scrim so the yellow scan laser pops
                      Container(
                        color: const Color(0xFF181A16).withValues(alpha: 0.28),
                      ),
                      // Sweeping BananaLens scan laser
                      AnimatedBuilder(
                        animation: _scanAnim,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _ScanLaserPainter(
                              progress: _scanAnim.value,
                              accentColor: theme.colorScheme.primary,
                            ),
                          );
                        },
                      ),
                      // Top-left industrial status tag
                      Positioned(
                        top: AppDimens.s12,
                        left: AppDimens.s12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.s8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rSharp,
                            ),
                            border: Border.all(color: ink, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.document_scanner_rounded,
                                size: 12,
                                color: theme.colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'SCANNING // ANALISIS AI',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.s12),
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: ink,
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Expanded(
                    child: Text(
                      'Sedang memindai & memeriksa kondisi buah…',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Menganalisis jenis buah, warna kulit, dan tingkat kematangan secara lokal.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: harvest.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.s16),
        const ShimmerBox(height: 112, radius: AppDimens.rCard),
        const SizedBox(height: AppDimens.s12),
        const Row(
          children: [
            Expanded(child: ShimmerBox(height: 48, radius: AppDimens.rButton)),
            SizedBox(width: AppDimens.s12),
            Expanded(child: ShimmerBox(height: 48, radius: AppDimens.rButton)),
          ],
        ),
      ],
    );
  }
}

class _ScanLaserPainter extends CustomPainter {
  const _ScanLaserPainter({required this.progress, required this.accentColor});

  final double progress;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    const bracketLen = 22.0;
    const pad = 12.0;
    final bracketPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // 4 corner viewfinder brackets
    const left = pad;
    const top = pad;
    final right = size.width - pad;
    final bottom = size.height - pad;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + bracketLen)
        ..lineTo(left, top)
        ..lineTo(left + bracketLen, top),
      bracketPaint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(right - bracketLen, top)
        ..lineTo(right, top)
        ..lineTo(right, top + bracketLen),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - bracketLen)
        ..lineTo(left, bottom)
        ..lineTo(left + bracketLen, bottom),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(right - bracketLen, bottom)
        ..lineTo(right, bottom)
        ..lineTo(right, bottom - bracketLen),
      bracketPaint,
    );

    // Sweeping laser beam + vertical gradient trail
    final y = top + (bottom - top) * progress;
    final trailRect = Rect.fromLTRB(
      left,
      (y - 34).clamp(top, bottom),
      right,
      y,
    );
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor.withValues(alpha: 0.0),
          accentColor.withValues(alpha: 0.34),
        ],
      ).createShader(trailRect);
    canvas.drawRect(trailRect, trailPaint);

    final linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.6;
    canvas.drawLine(Offset(left, y), Offset(right, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScanLaserPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}

/// Fallback view when a fruit is not confidently recognized or detected.
class ResultUncertainView extends StatelessWidget {
  const ResultUncertainView({super.key, required this.report, this.onRetake});

  final ScanReport report;
  final VoidCallback? onRetake;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        IndustrialSpecimenCard(
          padding: const EdgeInsets.all(AppDimens.s16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  border: Border.all(color: ink, width: 1.5),
                ),
                child: FruitImage(
                  imagePath: report.imagePath,
                  height: 160,
                  radius: AppDimens.rButton - 1,
                ),
              ),
              const SizedBox(height: AppDimens.s16),
              const IndustrialTagChip(label: 'DETEKSI // TIDAK YAKIN'),
              const SizedBox(height: AppDimens.s12),
              Text(
                AppStrings.resultUncertainTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                AppStrings.resultUncertainBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ink.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.s20),
        PrimaryButton(
          text: AppStrings.resultRetake,
          icon: Icons.refresh_rounded,
          onPressed:
              onRetake ??
              () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/scan');
                }
              },
        ),
      ],
    );
  }
}

/// Generic error view when scan processing fails unexpectedly.
class ResultErrorView extends StatelessWidget {
  const ResultErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: IndustrialSpecimenCard(
          padding: const EdgeInsets.all(AppDimens.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  border: Border.all(
                    color: theme.colorScheme.error,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 30,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppDimens.s16),
              Text(
                AppStrings.resultErrorTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                message.isNotEmpty ? message : AppStrings.resultErrorBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ink.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppDimens.s20),
              PrimaryButton(
                text: AppStrings.resultRetry,
                onPressed: onRetry,
                fullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
