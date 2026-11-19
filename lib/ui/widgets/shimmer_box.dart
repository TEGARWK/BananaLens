import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';

/// Animated skeleton placeholder with a left-to-right shimmer sweep
/// calibrated for both Technical Paper (light) and Night Instrument (dark).
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = AppDimens.s8,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF282B23)
        : const Color(0xFFD5D8CC);
    final highlightColor = isDark
        ? const Color(0xFF3E4236)
        : const Color(0xFFF6F7F2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final slide = (_controller.value * 3.0) - 1.5;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(slide - 0.8, -0.2),
              end: Alignment(slide + 0.8, 0.2),
              colors: <Color>[baseColor, highlightColor, baseColor],
              stops: const <double>[0.15, 0.5, 0.85],
            ),
          ),
        );
      },
    );
  }
}
