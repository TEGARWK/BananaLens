import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/data/models/ripeness.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/ui/widgets/fruit_image.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';
import 'package:fruitlens/ui/widgets/ripeness_chip.dart';
import 'package:fruitlens/ui/widgets/shimmer_box.dart';
import 'package:go_router/go_router.dart';

/// History summary card positioned right below the profile header card.
class ProfileHistoryCard extends ConsumerWidget {
  const ProfileHistoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);

    return IndustrialSpecimenCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, historyAsync.asData?.value ?? const []),
          const SizedBox(height: AppDimens.s12),
          historyAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimens.s8),
              child: Column(
                children: [
                  ShimmerBox(height: 56, radius: AppDimens.s12),
                  SizedBox(height: AppDimens.s8),
                  ShimmerBox(height: 56, radius: AppDimens.s12),
                ],
              ),
            ),
            error: (_, _) => _buildEmptyOrError(
              context,
              icon: Icons.error_outline_rounded,
              message: 'Gagal memuat riwayat pemindaian.',
              actionLabel: 'Coba Lagi',
              onAction: () => ref.invalidate(historyListProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return _buildEmptyOrError(
                  context,
                  icon: Icons.history_rounded,
                  message: 'Belum ada riwayat pemindaian buah.',
                  actionLabel: 'Mulai Pindai',
                  onAction: () => context.go('/scan'),
                );
              }
              final preview = items.take(2).toList();
              return Column(
                children: [
                  for (var i = 0; i < preview.length; i++) ...[
                    _HistoryPreviewTile(item: preview[i]),
                    if (i < preview.length - 1) const Divider(height: 1),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<ScanResult> items) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final favoriteCount = items.where((item) => item.isFavorite).length;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat Pemindaian',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${items.length} scan · $favoriteCount favorit',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: harvest.muted,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => context.go('/history'),
          borderRadius: BorderRadius.circular(AppDimens.rSharp),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s12,
              vertical: AppDimens.s8 - 2,
            ),
            decoration: BoxDecoration(
              color: harvest.primarySoft,
              borderRadius: BorderRadius.circular(AppDimens.rSharp),
              border: Border.all(color: ink, width: 1.2),
            ),
            child: Text(
              'Lihat Semua',
              style: theme.textTheme.labelSmall?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrError(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: harvest.primarySoft,
            borderRadius: BorderRadius.circular(AppDimens.rSharp),
            border: Border.all(color: harvest.border),
          ),
          child: Icon(icon, color: ink, size: 18),
        ),
        const SizedBox(width: AppDimens.s12),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
          ),
        ),
        const SizedBox(width: AppDimens.s8),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(AppDimens.rSharp),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s12,
              vertical: AppDimens.s8 - 2,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppDimens.rSharp),
              border: Border.all(color: ink, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: ink,
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              actionLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryPreviewTile extends StatelessWidget {
  const _HistoryPreviewTile({required this.item});

  final ScanResult item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ripeness = Ripeness.fromLabel(item.ripenessLabel);

    return InkWell(
      onTap: () => context.push('/history-detail', extra: item),
      borderRadius: BorderRadius.circular(AppDimens.rButton),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.s8),
        child: Row(
          children: [
            FruitImage(
              imagePath: item.imagePath,
              fruitLabel: item.fruitLabel,
              width: 44,
              height: 44,
              radius: AppDimens.rButton,
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fruitLabelId(item.fruitLabel),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _shortDate(item.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: harvest.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (ripeness != null) RipenessChip(ripeness: ripeness),
          ],
        ),
      ),
    );
  }

  String _fruitLabelId(String raw) {
    return switch (raw.toLowerCase()) {
      'banana' => 'Pisang',
      'apple' => 'Apel',
      'orange' => 'Jeruk',
      'mango' => 'Mangga',
      'papaya' => 'Pepaya',
      'strawberry' => 'Stroberi',
      'avocado' => 'Alpukat',
      'dragonfruit' => 'Buah Naga',
      'guava' => 'Jambu Biji',
      'pineapple' => 'Nanas',
      _ => raw.isNotEmpty ? '${raw[0].toUpperCase()}${raw.substring(1)}' : raw,
    };
  }

  String _shortDate(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} · $hour:$minute';
  }
}
