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
    Color badgeBg;
    Color badgeFg;

    if (recentRipe != null) {
      final fruitName = FruitNameHelper.toIndonesian(recentRipe.fruitLabel);
      reminderText =
          '$fruitName yang kamu scan siap disantap atau diolah menjadi smoothie sebelum terlalu matang!';
      reminderIcon = Icons.alarm_rounded;
      badgeBg = theme.colorScheme.primary;
      badgeFg = theme.colorScheme.onPrimary;
    } else {
      reminderText =
          'Tahukah kamu? Bungkus pangkal tangkai pisang matang agar gas etilen tidak membuatnya cepat menghitam.';
      reminderIcon = Icons.eco_rounded;
      badgeBg = harvest.accent;
      badgeFg = harvest.onAccent;
    }

    final goalText = userProfile?.goal != null && userProfile!.goal.isNotEmpty
        ? 'Cocok untuk target ${userProfile.goal}: Pisang matang pas kaya kalium & serat untuk energi harian.'
        : 'Rekomendasi harian: Nikmati pisang matang segar atau olahan rendah gula sesuai kebutuhanmu.';

    return IndustrialSpecimenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                ),
                alignment: Alignment.center,
                child: Icon(reminderIcon, size: 19, color: badgeFg),
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
                    const SizedBox(height: 3),
                    Text(
                      reminderText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: harvest.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s12,
              vertical: AppDimens.s8,
            ),
            decoration: BoxDecoration(
              color: harvest.primarySoft,
              borderRadius: BorderRadius.circular(AppDimens.rButton),
            ),
            child: Row(
              children: [
                Icon(Icons.person_pin_rounded, size: 16, color: harvest.accent),
                const SizedBox(width: AppDimens.s8),
                Expanded(
                  child: Text(
                    goalText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.85,
                      ),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
