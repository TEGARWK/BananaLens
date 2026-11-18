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
import '../widgets/fruit_image.dart';
import '../widgets/fruitlens_app_bar.dart';
import '../widgets/industrial_art.dart';
import '../widgets/nutrient_tile.dart';
import '../widgets/primary_button.dart';
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
    final ink = theme.colorScheme.onSurface;
    final ripeness = Ripeness.fromLabel(item.ripenessLabel);
    final fruitInfo = _fruitInfo;
    final fruitTitle = fruitInfo?.nameId ?? item.fruitLabel;

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.s12),
            child: Center(
              child: InkWell(
                onTap: () {
                  final prev = _isFavorite;
                  setState(() => _isFavorite = !prev);
                  if (item.id != null) {
                    ref
                        .read(historyListProvider.notifier)
                        .toggleFavorite(item.id!, prev);
                  }
                },
                borderRadius: BorderRadius.circular(AppDimens.rButton),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isFavorite
                        ? theme.colorScheme.primary
                        : harvest.primarySoft,
                    borderRadius: BorderRadius.circular(AppDimens.rButton),
                    border: Border.all(color: ink, width: 1.4),
                  ),
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isFavorite ? theme.colorScheme.error : ink,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: [
          _buildHeroSpecimen(theme, harvest, item, fruitTitle, ripeness),
          const SizedBox(height: AppDimens.s16),
          if (fruitInfo != null) _buildNutritionGrid(fruitInfo),
          _buildGuidanceCard(theme, harvest, fruitInfo, ripeness),
          _buildActionButtons(context, item, fruitTitle, ripeness),
          const SizedBox(height: AppDimens.s16),
        ],
      ),
    );
  }

  Widget _buildHeroSpecimen(
    ThemeData theme,
    HarvestColors harvest,
    ScanResult item,
    String fruitTitle,
    Ripeness? ripeness,
  ) {
    final ink = theme.colorScheme.onSurface;
    final pct = '${(item.confidence * 100).toStringAsFixed(0)}%';
    final (boxBg, boxFg) = switch (ripeness) {
      Ripeness.unripe => (const Color(0xFF3E7D28), Colors.white),
      Ripeness.rotten => (const Color(0xFFC43E2B), Colors.white),
      _ => (theme.colorScheme.primary, theme.colorScheme.onPrimary),
    };

    return IndustrialSpecimenCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const IndustrialTagChip(label: 'SCAN // RECORD', accent: true),
              Text(
                _formatFullDate(item.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: harvest.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          InkWell(
            onTap: () => _openFullscreenImage(
              context,
              item: item,
              fruitTitle: fruitTitle,
              ripeness: ripeness,
            ),
            borderRadius: BorderRadius.circular(AppDimens.rButton),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.rButton),
                border: Border.all(color: ink, width: 1.5),
              ),
              child: FruitImage(
                imagePath: item.imagePath,
                fruitLabel: item.fruitLabel,
                height: 124,
                radius: AppDimens.rButton - 1,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.s8),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _openFullscreenImage(
                context,
                item: item,
                fruitTitle: fruitTitle,
                ripeness: ripeness,
              ),
              borderRadius: BorderRadius.circular(AppDimens.rSharp),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s12,
                  vertical: AppDimens.s4 + 2,
                ),
                decoration: BoxDecoration(
                  color: harvest.primarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(color: ink, width: 1.3),
                  boxShadow: [
                    BoxShadow(
                      color: ink,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fullscreen_rounded, size: 16, color: ink),
                    const SizedBox(width: 5),
                    Text(
                      'Perbesar',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.s12),
          Row(
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s8),
                    if (ripeness != null) RipenessChip(ripeness: ripeness),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              InkWell(
                onTap: () => _showConfidenceBreakdownSheet(
                  context,
                  item: item,
                  ripeness: ripeness,
                ),
                borderRadius: BorderRadius.circular(AppDimens.rButton),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s12,
                    vertical: AppDimens.s8,
                  ),
                  decoration: BoxDecoration(
                    color: boxBg,
                    borderRadius: BorderRadius.circular(AppDimens.rButton),
                    border: Border.all(color: ink, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: ink,
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pct,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: boxFg,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.analytics_outlined,
                            size: 16,
                            color: boxFg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Akurasi Kematangan',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: boxFg,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
    final ink = theme.colorScheme.onSurface;
    if (ripeness == Ripeness.rotten) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.s16),
        child: IndustrialSpecimenCard(
          backgroundColor: harvest.rotten.withValues(alpha: 0.10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GuidanceSection(
                icon: Icons.warning_amber_rounded,
                iconBg: harvest.rotten.withValues(alpha: 0.18),
                iconColor: harvest.rotten,
                title: AppStrings.rottenAdviceTitle,
                body: AppStrings.rottenAdviceWarning,
                titleColor: harvest.rotten,
              ),
              const SizedBox(height: AppDimens.s12),
              Divider(height: 1, color: harvest.rotten.withValues(alpha: 0.3)),
              const SizedBox(height: AppDimens.s12),
              _GuidanceSection(
                icon: Icons.compost_rounded,
                iconBg: theme.colorScheme.primary.withValues(alpha: 0.5),
                iconColor: ink,
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
      child: IndustrialSpecimenCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GuidanceSection(
              icon: Icons.access_time_rounded,
              iconBg: theme.colorScheme.primary.withValues(alpha: 0.5),
              iconColor: ink,
              title: 'SARAN KONSUMSI',
              body: fruitInfo.benefits,
            ),
            const SizedBox(height: AppDimens.s12),
            Divider(height: 1, color: harvest.border),
            const SizedBox(height: AppDimens.s12),
            _GuidanceSection(
              icon: Icons.hourglass_top_rounded,
              iconBg: harvest.primarySoft,
              iconColor: ink,
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
          child: PrimaryButton(
            text: isRotten ? AppStrings.rottenRecycleButton : 'Resep Olahan',
            icon: isRotten ? Icons.compost_rounded : Icons.menu_book_rounded,
            onPressed: () {
              if (isRotten) {
                showRottenGuidanceSheet(context, fruitTitle);
              } else {
                final uri = Uri(
                  path: '/recipes',
                  queryParameters: <String, String>{
                    'fruit': item.fruitLabel,
                    'ripeness': item.ripenessLabel,
                  },
                ).toString();
                context.push(uri);
              }
            },
          ),
        ),
        const SizedBox(width: AppDimens.s12),
        Expanded(
          child: SoftButton(
            text: 'Tanya AI',
            icon: Icons.auto_awesome_rounded,
            fullWidth: true,
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

  void _showConfidenceBreakdownSheet(
    BuildContext context, {
    required ScanResult item,
    required Ripeness? ripeness,
  }) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final conf = item.confidence.clamp(0.0, 1.0);
    final pctInt = (conf * 100).round();
    final hasExactProbs =
        item.unripeProb != null ||
        item.ripeProb != null ||
        item.rottenProb != null;

    final activeKey = switch (ripeness) {
      Ripeness.unripe => 'unripe',
      Ripeness.ripe || Ripeness.overripe => 'ripe',
      Ripeness.rotten => 'rotten',
      null => item.ripenessLabel.toLowerCase(),
    };

    final unripeVal = (item.unripeProb ?? (activeKey == 'unripe' ? conf : 0.0))
        .clamp(0.0, 1.0);
    final ripeVal = (item.ripeProb ?? (activeKey == 'ripe' ? conf : 0.0)).clamp(
      0.0,
      1.0,
    );
    final rottenVal = (item.rottenProb ?? (activeKey == 'rotten' ? conf : 0.0))
        .clamp(0.0, 1.0);

    String formatProb(String key, double val) {
      if (hasExactProbs) return '${(val * 100).round()}%';
      return activeKey == key ? '$pctInt%' : '—';
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.rHero),
            ),
            border: Border(top: BorderSide(color: ink, width: 1.6)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimens.s20,
            AppDimens.s12,
            AppDimens.s20,
            AppDimens.s24,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: AppDimens.s16),
                    decoration: BoxDecoration(
                      color: ink.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const IndustrialTagChip(
                      label: 'MOD-AI // PROBABILITAS',
                      accent: true,
                    ),
                    Text(
                      '3-KELAS KEMATANGAN',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: harvest.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s12),
                Text(
                  'Rincian Persentase Kematangan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
                IndustrialSpecimenCard(
                  padding: const EdgeInsets.all(AppDimens.s16),
                  child: Column(
                    children: [
                      _RipenessBreakdownRow(
                        label: 'Mentah',
                        isDetected: activeKey == 'unripe',
                        fraction: unripeVal,
                        valueText: formatProb('unripe', unripeVal),
                        barColor: const Color(0xFF3E7D28),
                        badgeFg: Colors.white,
                      ),
                      const SizedBox(height: AppDimens.s12),
                      _RipenessBreakdownRow(
                        label: 'Matang',
                        isDetected: activeKey == 'ripe',
                        fraction: ripeVal,
                        valueText: formatProb('ripe', ripeVal),
                        barColor: theme.colorScheme.primary,
                        badgeFg: const Color(0xFF181A16),
                      ),
                      const SizedBox(height: AppDimens.s12),
                      _RipenessBreakdownRow(
                        label: 'Busuk',
                        isDetected: activeKey == 'rotten',
                        fraction: rottenVal,
                        valueText: formatProb('rotten', rottenVal),
                        barColor: const Color(0xFFC43E2B),
                        badgeFg: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.s12),
                Text(
                  hasExactProbs
                      ? 'Persentase diambil langsung dari hasil pemindaian model pada gambar ini.'
                      : 'Catatan: Riwayat lama sebelum pembaruan hanya menyimpan skor kelas utama ($pctInt%).',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: harvest.muted,
                  ),
                ),
                const SizedBox(height: AppDimens.s20),
                PrimaryButton(
                  text: 'Tutup',
                  height: 48,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFullscreenImage(
    BuildContext context, {
    required ScanResult item,
    required String fruitTitle,
    required Ripeness? ripeness,
  }) {
    final theme = Theme.of(context);
    final yellow = theme.colorScheme.primary;
    const darkBg = Color(0xFF121310);

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup foto fullscreen',
      barrierColor: darkBg.withValues(alpha: 0.94),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (BuildContext ctx, _, _) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const IndustrialTagChip(
                        label: 'INSPEKSI // FOTO',
                        accent: true,
                      ),
                      InkWell(
                        onTap: () => Navigator.of(ctx).pop(),
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: yellow,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rButton,
                            ),
                            border: Border.all(
                              color: const Color(0xFF181A16),
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF181A16),
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF181A16),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.s16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1D18),
                        borderRadius: BorderRadius.circular(AppDimens.rCard),
                        border: Border.all(color: yellow, width: 1.8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimens.rCard - 2,
                        ),
                        child: InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 4.0,
                          child: Center(
                            child: FruitImage(
                              imagePath: item.imagePath,
                              fruitLabel: item.fruitLabel,
                              fit: BoxFit.contain,
                              radius: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.s16),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.s12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1D18),
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      border: Border.all(
                        color: const Color(0xFF31342B),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fruitTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFFF2F3EE),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatFullDate(item.createdAt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF9A9F90),
                              ),
                            ),
                          ],
                        ),
                        if (ripeness != null) RipenessChip(ripeness: ripeness),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  const _GuidanceSection({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
    this.titleColor,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppDimens.rSharp),
                border: Border.all(color: ink, width: 1.2),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: AppDimens.s8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? ink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.s8),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ink.withValues(alpha: 0.85),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _RipenessBreakdownRow extends StatelessWidget {
  const _RipenessBreakdownRow({
    required this.label,
    required this.isDetected,
    required this.fraction,
    required this.valueText,
    required this.barColor,
    required this.badgeFg,
  });

  final String label;
  final bool isDetected;
  final double fraction;
  final String valueText;
  final Color barColor;
  final Color badgeFg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isDetected ? FontWeight.w800 : FontWeight.w600,
                    color: isDetected ? ink : harvest.muted,
                  ),
                ),
                if (isDetected) ...[
                  const SizedBox(width: AppDimens.s8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                      border: Border.all(color: ink, width: 1),
                    ),
                    child: Text(
                      'TERDETEKSI',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: badgeFg,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              valueText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDetected ? ink : harvest.muted,
                fontWeight: isDetected ? FontWeight.w800 : FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: harvest.primarySoft,
            borderRadius: BorderRadius.circular(AppDimens.rSharp),
            border: Border.all(
              color: isDetected ? ink : harvest.border,
              width: 1,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: fraction.clamp(0.0, 1.0),
              child: ColoredBox(
                color: barColor,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
