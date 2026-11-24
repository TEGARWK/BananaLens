import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'industrial_art.dart';

/// Joined 3-cell Swiss Editorial Grid strip (`[ Tips Buah | Asisten AI | Resep Sehat ]`)
/// mirroring the connected feature boxes in the reference, with a single subtle
/// top-left scanner corner (`┌`) and diagonal `↗` corner arrows.
class HomeQuickActionChips extends StatelessWidget {
  const HomeQuickActionChips({
    super.key,
    required this.onTipsTap,
    required this.onAiTap,
    required this.onRecipeTap,
  });

  final VoidCallback onTipsTap;
  final VoidCallback onAiTap;
  final VoidCallback onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.rCard),
        border: Border.all(color: harvest.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        foregroundPainter: ScannerCornerPainter(
          color: harvest.accent.withValues(alpha: 0.6),
          bracketLength: 10,
          strokeWidth: 1.6,
          inset: 4,
          style: ScannerCornerStyle.topLeft1,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _JoinedCell(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Tips Buah',
                  subtitle: 'Panduan simpan',
                  badgeBg: theme.colorScheme.primary,
                  badgeFg: theme.colorScheme.onPrimary,
                  onTap: onTipsTap,
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: harvest.border),
              Expanded(
                child: _JoinedCell(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Asisten AI',
                  subtitle: 'Tanya gizi',
                  badgeBg: harvest.accent,
                  badgeFg: harvest.onAccent,
                  onTap: onAiTap,
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: harvest.border),
              Expanded(
                child: _JoinedCell(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Resep Sehat',
                  subtitle: 'Ide olahan',
                  badgeBg: harvest.primarySoft,
                  badgeFg: theme.colorScheme.onSurface,
                  onTap: onRecipeTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JoinedCell extends StatelessWidget {
  const _JoinedCell({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.badgeBg,
    required this.badgeFg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color badgeBg;
  final Color badgeFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.s12,
            AppDimens.s12,
            AppDimens.s8,
            AppDimens.s8 + 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(AppDimens.rSharp + 2),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 15, color: badgeFg),
                  ),
                  Icon(
                    Icons.north_east_rounded,
                    size: 13,
                    color: harvest.muted,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: harvest.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
