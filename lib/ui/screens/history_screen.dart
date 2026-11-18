import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_result.dart';
import '../../providers/history_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/fruit_image.dart';
import '../widgets/fruitlens_app_bar.dart';
import '../widgets/industrial_art.dart';
import '../widgets/ripeness_chip.dart';
import '../widgets/shimmer_box.dart';
import '../widgets/soft_button.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  Timer? _hintTimer;
  int _hintIndex = 0;

  static const List<String> _searchHints = <String>[
    'Cari buah berdasarkan kematangan...',
    'Cari: Pisang, Matang, Mentah...',
    'Ketik nama buah atau status busuk...',
  ];

  @override
  void initState() {
    super.initState();
    _startHintTimer();
  }

  @override
  void reassemble() {
    super.reassemble();
    _startHintTimer();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted || _searchQuery.isNotEmpty) return;
      setState(() => _hintIndex = (_hintIndex + 1) % _searchHints.length);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<ScanResult> _filterItems(List<ScanResult> items) {
    return items.where((item) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final fruitId = _formatFruitName(item.fruitLabel).toLowerCase();
        final fruitEn = item.fruitLabel.toLowerCase();
        final ripenessId = switch (Ripeness.fromLabel(item.ripenessLabel)) {
          Ripeness.unripe => 'mentah',
          Ripeness.ripe => 'matang',
          Ripeness.overripe => 'terlalu matang',
          Ripeness.rotten => 'busuk',
          null => '',
        };
        final ripenessEn = item.ripenessLabel.toLowerCase();
        final matchesQuery =
            fruitId.contains(query) ||
            fruitEn.contains(query) ||
            ripenessId.contains(query) ||
            ripenessEn.contains(query);
        if (!matchesQuery) {
          return false;
        }
      }

      return switch (_selectedFilter) {
        'ripe' => item.ripenessLabel == 'ripe',
        'unripe' => item.ripenessLabel == 'unripe',
        'rotten' => item.ripenessLabel == 'rotten',
        _ => true,
      };
    }).toList();
  }

  Future<void> _confirmDelete(BuildContext context, ScanResult item) async {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

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
                  const IndustrialTagChip(label: 'HAPUS // RIWAYAT'),
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
                'Riwayat scan ${_formatFruitName(item.fruitLabel)} akan dihapus permanen.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: harvest.muted,
                ),
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
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                        boxShadow: [
                          BoxShadow(
                            color: ink,
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.rButton,
                            ),
                            side: BorderSide(color: ink, width: 1.5),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Hapus'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && item.id != null) {
      await ref.read(historyListProvider.notifier).delete(item.id!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Riwayat dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const FruitLensAppBar(
        title: 'Riwayat Scan',
        leadingIcon: Icons.history_rounded,
      ),
      body: historyAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            children: [
              ShimmerBox(height: 48, radius: AppDimens.rButton),
              SizedBox(height: AppDimens.s16),
              ShimmerBox(height: 84, radius: AppDimens.rCard),
              SizedBox(height: AppDimens.s12),
              ShimmerBox(height: 84, radius: AppDimens.rCard),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Gagal memuat riwayat: $err',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        data: (allItems) {
          if (allItems.isEmpty) {
            return EmptyState(
              icon: Icons.history_rounded,
              title: AppStrings.historyTitle,
              message: AppStrings.historySubtitle,
              actionText: 'Mulai Pindai Sekarang',
              onAction: () => context.go('/scan'),
            );
          }

          final filteredItems = _filterItems(allItems);

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding,
              vertical: AppDimens.s12,
            ),
            children: [
              // 1. Kolom cari bergaya instrumen
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: _searchHints[_hintIndex],
                  prefixIcon: Icon(Icons.search_rounded, color: ink, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 18, color: ink),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppDimens.s12),

              // 2. Chip filter horizontal (tanpa "Terlalu matang")
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Semua'),
                    const SizedBox(width: AppDimens.s8),
                    _buildFilterChip('ripe', 'Matang'),
                    const SizedBox(width: AppDimens.s8),
                    _buildFilterChip('unripe', 'Mentah'),
                    const SizedBox(width: AppDimens.s8),
                    _buildFilterChip('rotten', 'Busuk'),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.s16),

              // 3. Daftar Kartu Riwayat dengan Dismissible swipe-to-delete
              if (filteredItems.isEmpty)
                const EmptyState(
                  title: 'Tidak Ditemukan',
                  message:
                      'Tidak ada riwayat yang cocok dengan kata kunci atau filter ini.',
                )
              else
                ...filteredItems.map((item) {
                  final ripeness = Ripeness.fromLabel(item.ripenessLabel);
                  final itemKey = ValueKey(
                    item.id ?? item.createdAt.toIso8601String(),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.s12),
                    child: Dismissible(
                      key: itemKey,
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        await _confirmDelete(context, item);
                        return false;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppDimens.s20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(AppDimens.rCard),
                          border: Border.all(color: ink, width: 1.5),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: theme.colorScheme.onError,
                          size: 26,
                        ),
                      ),
                      child: InkWell(
                        onTap: () =>
                            context.push('/history-detail', extra: item),
                        borderRadius: BorderRadius.circular(AppDimens.rCard),
                        child: IndustrialSpecimenCard(
                          padding: const EdgeInsets.all(AppDimens.s12),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.s12,
                                  ),
                                  border: Border.all(color: ink, width: 1.2),
                                ),
                                child: FruitImage(
                                  imagePath: item.imagePath,
                                  fruitLabel: item.fruitLabel,
                                  width: 60,
                                  height: 60,
                                  radius: AppDimens.s12 - 1,
                                ),
                              ),
                              const SizedBox(width: AppDimens.s12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatFruitName(item.fruitLabel),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: AppDimens.s4),
                                    Text(
                                      _formatDate(item.createdAt),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(color: harvest.muted),
                                    ),
                                  ],
                                ),
                              ),
                              if (ripeness != null)
                                RipenessChip(ripeness: ripeness),
                              const SizedBox(width: AppDimens.s4),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                ),
                                color: harvest.muted,
                                onPressed: () => _confirmDelete(context, item),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final isSelected = _selectedFilter == key;

    final (selectedBg, selectedFg) = switch (key) {
      'unripe' => (const Color(0xFF3E7D28), Colors.white),
      'rotten' => (const Color(0xFFC43E2B), Colors.white),
      _ => (theme.colorScheme.primary, theme.colorScheme.onPrimary),
    };

    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(AppDimens.rSharp),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s12 + 2,
          vertical: AppDimens.s8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : harvest.primarySoft,
          borderRadius: BorderRadius.circular(AppDimens.rSharp),
          border: Border.all(
            color: isSelected ? ink : harvest.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ink,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isSelected ? selectedFg : harvest.muted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatFruitName(String label) {
    return switch (label.toLowerCase()) {
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
      _ =>
        label.isNotEmpty
            ? '${label[0].toUpperCase()}${label.substring(1)}'
            : label,
    };
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = dt.hour.toString().padLeft(2, '0');

    if (diff.inDays == 0 && now.day == dt.day) {
      return 'Hari ini, $hourStr:$minuteStr';
    } else if (diff.inDays <= 1 && now.day - dt.day == 1) {
      return 'Kemarin, $hourStr:$minuteStr';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
