import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/fruit_info.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_result.dart';
import '../../providers/chat_notifier.dart';
import '../../providers/history_providers.dart';
import '../../providers/service_providers.dart';
import '../widgets/app_card.dart';
import '../widgets/fruit_image.dart';
import '../widgets/nutrient_tile.dart';
import '../widgets/ripeness_chip.dart';
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
  late bool _isFavorite;
  FruitInfo? _fruitInfo;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialItem.isFavorite;
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
    return '$day $month ${dt.year} • $hour:$min WIB';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.initialItem;
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ripeness = Ripeness.fromLabel(item.ripenessLabel);
    final fruitInfo = _fruitInfo;
    final fruitTitle = fruitInfo?.nameId ?? item.fruitLabel;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, harvest, item),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: [
          FruitImage(
            imagePath: item.imagePath,
            fruitLabel: item.fruitLabel,
            height: 160,
            radius: AppDimens.rHero,
          ),
          const SizedBox(height: AppDimens.s16),
          _buildHeader(theme, harvest, item, fruitTitle, ripeness),
          const SizedBox(height: AppDimens.s12),
          Text(
            _formatFullDate(item.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
          ),
          const SizedBox(height: AppDimens.s16),
          if (fruitInfo != null) _buildNutritionGrid(fruitInfo),
          _buildGuidanceCard(theme, harvest, fruitInfo, ripeness),
          _buildActionButtons(context, item, fruitTitle, ripeness),
          const SizedBox(height: AppDimens.s16),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    HarvestColors harvest,
    ScanResult item,
  ) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(AppDimens.s8),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: harvest.primarySoft,
            foregroundColor: theme.colorScheme.primary,
            shape: const CircleBorder(),
          ),
        ),
      ),
      title: Text(
        'Detail Riwayat Pindai',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isFavorite ? Colors.redAccent : harvest.muted,
            size: 24,
          ),
          onPressed: () {
            setState(() => _isFavorite = !_isFavorite);
            if (item.id != null) {
              ref
                  .read(historyListProvider.notifier)
                  .toggleFavorite(item.id!, !_isFavorite);
            }
          },
        ),
        const SizedBox(width: AppDimens.s8),
      ],
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    HarvestColors harvest,
    ScanResult item,
    String fruitTitle,
    Ripeness? ripeness,
  ) {
    final confidenceColor = ripeness != null
        ? harvest.forRipeness(ripeness)
        : theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fruitTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimens.s4),
              if (ripeness != null) RipenessChip(ripeness: ripeness),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(item.confidence * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: confidenceColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Akurasi Kematangan',
              style: theme.textTheme.labelSmall?.copyWith(color: harvest.muted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionGrid(FruitInfo fruitInfo) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NutrientTile(
                value: fruitInfo.calories.toStringAsFixed(0),
                unit: 'kkal',
                label: 'Kalori',
              ),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: NutrientTile(
                value: fruitInfo.carbs.toStringAsFixed(1),
                unit: 'g',
                label: 'Karbohidrat',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.s12),
        Row(
          children: [
            Expanded(
              child: NutrientTile(
                value: fruitInfo.sugar.toStringAsFixed(1),
                unit: 'g',
                label: 'Gula Alami',
              ),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: NutrientTile(
                value: fruitInfo.fiber.toStringAsFixed(1),
                unit: 'g',
                label: 'Serat',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.s16),
      ],
    );
  }

  Widget _buildGuidanceCard(
    ThemeData theme,
    HarvestColors harvest,
    FruitInfo? fruitInfo,
    Ripeness? ripeness,
  ) {
    // Rotten scans must display food safety warnings instead of eating/smoothie tips.
    if (ripeness == Ripeness.rotten) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.s16),
        child: AppCard(
          color: harvest.rotten.withValues(alpha: 0.08),
          borderColor: harvest.rotten,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GuidanceSection(
                icon: Icons.warning_amber_rounded,
                iconColor: harvest.rotten,
                title: AppStrings.rottenAdviceTitle,
                body: AppStrings.rottenAdviceWarning,
                titleColor: harvest.rotten,
              ),
              const SizedBox(height: AppDimens.s12),
              Divider(height: 1, color: harvest.rotten.withValues(alpha: 0.25)),
              const SizedBox(height: AppDimens.s12),
              _GuidanceSection(
                icon: Icons.compost_rounded,
                iconColor: theme.colorScheme.primary,
                title: AppStrings.rottenEcoTitle,
                body: AppStrings.rottenEcoBody,
              ),
            ],
          ),
        ),
      );
    }

    if (fruitInfo == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GuidanceSection(
              icon: Icons.access_time_rounded,
              iconColor: theme.colorScheme.primary,
              title: 'SARAN KONSUMSI',
              body: fruitInfo.benefits,
            ),
            const SizedBox(height: AppDimens.s12),
            Divider(height: 1, color: harvest.border),
            const SizedBox(height: AppDimens.s12),
            _GuidanceSection(
              icon: Icons.hourglass_top_rounded,
              iconColor: theme.colorScheme.primary,
              title: 'DAYA SIMPAN',
              body: fruitInfo.storageTips,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ScanResult item,
    String fruitTitle,
    Ripeness? ripeness,
  ) {
    final isRotten = ripeness == Ripeness.rotten;
    return Row(
      children: [
        Expanded(
          child: SoftButton(
            text: isRotten ? AppStrings.rottenRecycleButton : 'Resep Olahan',
            icon: isRotten ? Icons.compost_rounded : Icons.menu_book_rounded,
            onPressed: () {
              if (isRotten) {
                showRottenGuidanceSheet(context, fruitTitle);
              } else {
                context.push(
                  '/recipes?fruit=${item.fruitLabel}&ripeness=${item.ripenessLabel}',
                );
              }
            },
          ),
        ),
        const SizedBox(width: AppDimens.s12),
        Expanded(
          child: SoftButton(
            text: 'Tanya AI',
            icon: Icons.auto_awesome_rounded,
            onPressed: () {
              final contextStr = '$fruitTitle (${item.ripenessLabel})';
              ref
                  .read(chatNotifierProvider.notifier)
                  .setScanContext(contextStr);
              context.go('/chat');
            },
          ),
        ),
      ],
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  const _GuidanceSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: AppDimens.s8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.s4),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: harvest.muted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
