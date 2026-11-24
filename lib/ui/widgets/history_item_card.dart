import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../core/utils/fruit_name_helper.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_result.dart';
import 'fruit_image.dart';
import 'industrial_art.dart';
import 'ripeness_chip.dart';
import 'soft_button.dart';

/// Swipeable history list item card showing photo thumbnail, ripeness badge,
/// relative timestamp, and confidence percentage.
class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onRequestDelete,
  });

  final ScanResult item;
  final VoidCallback onTap;
  final Future<void> Function() onRequestDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ripeness = Ripeness.fromLabel(item.ripenessLabel);
    final itemKey = ValueKey(item.id ?? item.createdAt.toIso8601String());
    final confidencePct = (item.confidence * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s12),
      child: Dismissible(
        key: itemKey,
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          await onRequestDelete();
          return false;
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppDimens.s20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(AppDimens.rCard),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: theme.colorScheme.onError,
            size: 26,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.rCard),
          child: IndustrialSpecimenCard(
            padding: const EdgeInsets.all(AppDimens.s12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.rButton),
                    border: Border.all(color: harvest.border, width: 1),
                  ),
                  child: FruitImage(
                    imagePath: item.imagePath,
                    fruitLabel: item.fruitLabel,
                    width: 56,
                    height: 56,
                    radius: AppDimens.rButton - 1,
                  ),
                ),
                const SizedBox(width: AppDimens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FruitNameHelper.toIndonesian(item.fruitLabel),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_formatDate(item.createdAt)} · $confidencePct% yakin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: harvest.muted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                if (ripeness != null) RipenessChip(ripeness: ripeness),
                IconButton(
                  tooltip: 'Hapus riwayat',
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: harvest.muted,
                  onPressed: onRequestDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final dayDiff = today.difference(target).inDays;
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = dt.hour.toString().padLeft(2, '0');

    if (dayDiff == 0) return 'Hari ini, $hourStr:$minuteStr';
    if (dayDiff == 1) return 'Kemarin, $hourStr:$minuteStr';
    if (dayDiff > 1 && dayDiff < 7) return '$dayDiff hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

/// Shows the BananaLens-styled delete confirmation dialog and returns `true`
/// if the user confirms permanent deletion.
Future<bool> showDeleteHistoryDialog(
  BuildContext context,
  ScanResult item,
) async {
  final theme = Theme.of(context);
  final harvest = context.harvest;
  final fruitName = FruitNameHelper.toIndonesian(item.fruitLabel);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppDimens.s24),
      child: IndustrialSpecimenCard(
        padding: const EdgeInsets.all(AppDimens.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const IndustrialTagChip(label: 'HAPUS · RIWAYAT'),
                Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.s16),
            Text(
              'Hapus Riwayat?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.s8),
            Text(
              'Riwayat scan $fruitName akan dihapus permanen.',
              style: theme.textTheme.bodyMedium?.copyWith(color: harvest.muted),
            ),
            const SizedBox(height: AppDimens.s20),
            Row(
              children: [
                Expanded(
                  child: SoftButton(
                    text: 'Batal',
                    height: 48,
                    fullWidth: true,
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                ),
                const SizedBox(width: AppDimens.s12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed == true;
}
