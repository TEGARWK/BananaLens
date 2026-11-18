import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../core/utils/fruit_name_helper.dart';
import '../../data/models/scan_result.dart';
import '../../providers/auth_providers.dart';
import 'industrial_art.dart';

/// Smart freshness reminder card and personalized wellness recommendations.
class HomeSmartReminderCard extends ConsumerWidget {
  const HomeSmartReminderCard({super.key, required this.historyAsync});

  final AsyncValue<List<ScanResult>> historyAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final items = historyAsync.asData?.value ?? <ScanResult>[];
    final userProfile = ref.watch(authNotifierProvider).asData?.value;

    final recentRipe = items.cast<ScanResult?>().firstWhere(
      (e) =>
          e != null &&
          (e.ripenessLabel == 'ripe' || e.ripenessLabel == 'overripe'),
      orElse: () => null,
    );

    String reminderText;
    IconData reminderIcon;
    Color badgeColor;

    if (recentRipe != null) {
      final fruitName = FruitNameHelper.toIndonesian(recentRipe.fruitLabel);
      reminderText =
          '$fruitName yang kamu scan siap disantap atau diolah menjadi smoothie sebelum terlalu matang!';
      reminderIcon = Icons.alarm_rounded;
      badgeColor = theme.colorScheme.primary;
    } else {
      reminderText =
          'Tahukah kamu? Simpan buah matang terpisah agar gas etilen tidak membuat buah lain cepat busuk.';
      reminderIcon = Icons.eco_rounded;
      badgeColor = harvest.primarySoft;
    }

    final goalText = userProfile?.goal != null && userProfile!.goal.isNotEmpty
        ? 'Cocok untuk target ${userProfile.goal}: Perbanyak asupan apel & alpukat kaya serat.'
        : 'Rekomendasi diet sehat: Konsumsi minimal 2 porsi buah segar setiap hari.';
    final ink = theme.colorScheme.onSurface;

    return IndustrialSpecimenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.s8),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(color: ink, width: 1.2),
                ),
                child: Icon(reminderIcon, size: 18, color: ink),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengingat Kesegaran',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reminderText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: harvest.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          Divider(height: 1, color: harvest.border),
          const SizedBox(height: AppDimens.s8),
          Row(
            children: [
              Icon(Icons.person_pin_rounded, size: 15, color: ink),
              const SizedBox(width: AppDimens.s4),
              Expanded(
                child: Text(
                  goalText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: harvest.muted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
