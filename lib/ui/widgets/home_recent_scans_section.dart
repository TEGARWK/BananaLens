import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../core/utils/fruit_name_helper.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_result.dart';
import 'empty_state.dart';
import 'fruit_vector_icon.dart';
import 'industrial_art.dart';
import 'ripeness_chip.dart';
import 'section_header.dart';
import 'shimmer_box.dart';

/// Section rendering recent scan entries on the home screen.
class HomeRecentScansSection extends StatelessWidget {
  const HomeRecentScansSection({super.key, required this.historyAsync});

  final AsyncValue<List<ScanResult>> historyAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Riwayat Terakhir',
          actionText: 'Lihat semua',
          onAction: () => context.go('/history'),
        ),
        const SizedBox(height: AppDimens.s8),
        historyAsync.when(
          loading: () => const IndustrialSpecimenCard(
            child: Column(
              children: [
                ShimmerBox(height: 52, radius: AppDimens.s12),
                SizedBox(height: AppDimens.s8),
                ShimmerBox(height: 52, radius: AppDimens.s12),
              ],
            ),
          ),
          error: (err, _) => IndustrialSpecimenCard(
            child: Text(
              'Gagal memuat riwayat: $err',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const IndustrialSpecimenCard(
                padding: EdgeInsets.symmetric(vertical: AppDimens.s20),
                child: EmptyState(
                  icon: Icons.history_rounded,
                  title: 'Belum Ada Riwayat',
                  message:
                      'Pindai buah pertamamu untuk melihat hasil analisis kematangan dan nutrisi di sini.',
                ),
              );
            }
            final recents = items.take(3).toList();
            return IndustrialSpecimenCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < recents.length; i++) ...[
                    InkWell(
                      onTap: () =>
                          context.push('/history-detail', extra: recents[i]),
                      borderRadius: BorderRadius.vertical(
                        top: i == 0
                            ? const Radius.circular(AppDimens.rCard)
                            : Radius.zero,
                        bottom: i == recents.length - 1
                            ? const Radius.circular(AppDimens.rCard)
                            : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.s16),
                        child: Row(
                          children: [
                            _RecentScanThumb(
                              item: recents[i],
                              ink: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: AppDimens.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    FruitNameHelper.toIndonesian(
                                      recents[i].fruitLabel,
                                    ),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${FruitNameHelper.formatRelativeDate(recents[i].createdAt)} · ${(recents[i].confidence * 100).toStringAsFixed(0)}% yakin',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: harvest.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (Ripeness.fromLabel(recents[i].ripenessLabel) !=
                                null)
                              RipenessChip(
                                ripeness: Ripeness.fromLabel(
                                  recents[i].ripenessLabel,
                                )!,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (i < recents.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: harvest.border,
                        indent: AppDimens.s16,
                        endIndent: AppDimens.s16,
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RecentScanThumb extends StatelessWidget {
  const _RecentScanThumb({required this.item, required this.ink});

  final ScanResult item;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final path = item.imagePath;
    if (path.isNotEmpty && File(path).existsSync()) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.rSharp),
          border: Border.all(color: ink, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => FruitVectorIcon(
            fruitLabel: item.fruitLabel,
            ripeness: item.ripenessLabel,
            size: 44,
            isCircular: false,
          ),
        ),
      );
    }
    return FruitVectorIcon(
      fruitLabel: item.fruitLabel,
      ripeness: item.ripenessLabel,
      size: 44,
      isCircular: false,
    );
  }
}
