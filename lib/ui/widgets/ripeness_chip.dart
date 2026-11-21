import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../data/models/ripeness.dart';

class RipenessChip extends StatelessWidget {
  const RipenessChip({super.key, required this.ripeness, this.showIcon = true});

  final Ripeness ripeness;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;

    final (label, icon, bg, fg) = switch (ripeness) {
      Ripeness.unripe => (
        'Mentah',
        Icons.eco_outlined,
        const Color(0xFF3E7D28),
        Colors.white,
      ),
      Ripeness.ripe => (
        'Matang',
        Icons.check_circle_outline,
        theme.colorScheme.primary,
        const Color(0xFF181A16),
      ),
      Ripeness.overripe => (
        'Matang Banget',
        Icons.warning_amber_rounded,
        const Color(0xFFD97706),
        Colors.white,
      ),
      Ripeness.rotten => (
        'Busuk',
        Icons.dangerous_outlined,
        const Color(0xFFC43E2B),
        Colors.white,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s8 + 2,
        vertical: AppDimens.s4 + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rSharp),
        border: Border.all(color: ink, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: AppDimens.s4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
