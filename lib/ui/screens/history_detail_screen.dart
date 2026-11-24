import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimens.dart';
import '../../data/models/fruit_info.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_outcome.dart';
import '../../data/models/scan_result.dart';
import '../../providers/chat_notifier.dart';
import '../../providers/service_providers.dart';
import '../widgets/fruitlens_app_bar.dart';
import '../widgets/history_detail_guidance_card.dart';
import '../widgets/history_detail_hero_card.dart';
import '../widgets/history_detail_sheets.dart';
import '../widgets/primary_button.dart';
import '../widgets/result_recipe_gating_section.dart';
import '../widgets/rotten_guidance_sheet.dart';
import '../widgets/soft_button.dart';

/// Displays full nutrition, status, and safe handling actions for a scan record.
class HistoryDetailScreen extends ConsumerStatefulWidget {
  const HistoryDetailScreen({required this.initialItem, super.key});

  final ScanResult initialItem;

  @override
  ConsumerState<HistoryDetailScreen> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  FruitInfo? _fruitInfo;

  @override
  void initState() {
    super.initState();
    _loadFruitInfo();
  }

  Future<void> _loadFruitInfo() async {
    final repo = ref.read(fruitInfoRepositoryProvider);
    final info = await repo.getByLabel(widget.initialItem.fruitLabel);
    if (mounted) {
      setState(() => _fruitInfo = info);
    }
  }

  String _formatFullDate(DateTime dt) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day $month ${dt.year} · $hour:$min';
  }

  ScanSuccess _toScanSuccess(ScanResult item) {
    Map<String, double>? probs;
    if (item.unripeProb != null ||
        item.ripeProb != null ||
        item.rottenProb != null) {
      final unripe = (item.unripeProb ?? 0.0).clamp(0.0, 1.0);
      final ripe = (item.ripeProb ?? 0.0).clamp(0.0, 1.0);
      final rotten = (item.rottenProb ?? 0.0).clamp(0.0, 1.0);
      final overripe = (1.0 - unripe - ripe - rotten).clamp(0.0, 1.0);
      probs = <String, double>{
        'unripe': unripe,
        'ripe': ripe,
        'overripe': overripe,
        'rotten': rotten,
      };
    }
    return ScanSuccess(
      fruitLabel: item.fruitLabel,
      ripenessLabel: item.ripenessLabel,
      fruitConfidence: item.confidence,
      ripenessConfidence: item.confidence,
      classProbabilities: probs,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.initialItem;
    final theme = Theme.of(context);
    final ripeness = Ripeness.fromLabel(item.ripenessLabel);
    final fruitInfo = _fruitInfo;
    final fruitTitle = fruitInfo?.nameId ?? item.fruitLabel;
    final confPct = (item.confidence * 100).round();
    final scanOutcome = _toScanSuccess(item);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: FruitLensAppBar(
        title: 'Detail Riwayat Pindai',
        showBackButton: true,
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/history');
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: [
          HistoryDetailHeroCard(
            item: item,
            fruitTitle: fruitTitle,
            formattedDate: _formatFullDate(item.createdAt),
            ripeness: ripeness,
            onOpenFullscreen: () => showHistoryFullscreenImage(
              context,
              imagePath: item.imagePath,
              fruitLabel: item.fruitLabel,
            ),
            onShowBreakdown: () => showHistoryConfidenceBreakdownSheet(
              context,
              confPct: confPct,
              ripeness: ripeness,
            ),
          ),
          const SizedBox(height: AppDimens.s16),
          ResultRecipeGatingSection(outcome: scanOutcome),
          if (fruitInfo != null) HistoryDetailNutritionSection(info: fruitInfo),
          HistoryDetailGuidanceCard(fruitInfo: fruitInfo, ripeness: ripeness),
          const SizedBox(height: AppDimens.s16),
        ],
      ),
      bottomNavigationBar: _HistoryActionBar(
        item: item,
        fruitTitle: fruitTitle,
        ripeness: ripeness,
        onAskAi: () {
          final status = ripeness?.labelId ?? item.ripenessLabel;
          ref
              .read(chatNotifierProvider.notifier)
              .openWithScanContext(
                '$fruitTitle ($status, akurasi $confPct%) dari riwayat pindai',
              );
          context.go('/chat');
        },
      ),
    );
  }
}

class _HistoryActionBar extends StatelessWidget {
  const _HistoryActionBar({
    required this.item,
    required this.fruitTitle,
    required this.ripeness,
    required this.onAskAi,
  });

  final ScanResult item;
  final String fruitTitle;
  final Ripeness? ripeness;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRotten = ripeness == Ripeness.rotten;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.screenPadding,
        AppDimens.s12,
        AppDimens.screenPadding,
        AppDimens.s16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: isRotten ? 'Daur Ulang' : 'Resep',
                icon: isRotten
                    ? Icons.recycling_rounded
                    : Icons.menu_book_rounded,
                onPressed: isRotten
                    ? () => showRottenGuidanceSheet(context, fruitTitle)
                    : () => context.push(
                        '/recipes?fruit=${Uri.encodeComponent(item.fruitLabel)}'
                        '&ripeness=${Uri.encodeComponent(item.ripenessLabel)}',
                      ),
              ),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: SoftButton(
                text: 'Tanya AI',
                icon: Icons.auto_awesome,
                onPressed: onAskAi,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
