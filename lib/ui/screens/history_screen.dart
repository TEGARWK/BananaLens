import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../core/utils/fruit_name_helper.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_result.dart';
import '../../providers/history_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/fruitlens_app_bar.dart';
import '../widgets/history_item_card.dart';
import '../widgets/shimmer_box.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key, this.initialFilter});

  final String? initialFilter;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const _validFilters = {'all', 'unripe', 'ripe', 'overripe', 'rotten'};

  String _selectedFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter;
    if (filter != null && _validFilters.contains(filter)) {
      _selectedFilter = filter;
    }
  }

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final filter = widget.initialFilter;
    if (filter != oldWidget.initialFilter &&
        filter != null &&
        _validFilters.contains(filter)) {
      setState(() => _selectedFilter = filter);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ScanResult> _filterItems(List<ScanResult> items) {
    return items.where((item) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final fruitId = FruitNameHelper.toIndonesian(
          item.fruitLabel,
        ).toLowerCase();
        final fruitEn = item.fruitLabel.toLowerCase();
        final ripenessId = switch (Ripeness.fromLabel(item.ripenessLabel)) {
          Ripeness.unripe => 'mentah',
          Ripeness.ripe => 'matang',
          Ripeness.overripe => 'matang banget terlalu matang',
          Ripeness.rotten => 'busuk',
          null => '',
        };
        final ripenessEn = item.ripenessLabel.toLowerCase();
        final matchesQuery =
            fruitId.contains(query) ||
            fruitEn.contains(query) ||
            ripenessId.contains(query) ||
            ripenessEn.contains(query);
        if (!matchesQuery) return false;
      }

      return switch (_selectedFilter) {
        'unripe' => item.ripenessLabel == 'unripe',
        'ripe' => item.ripenessLabel == 'ripe',
        'overripe' =>
          item.ripenessLabel == 'overripe' || item.ripenessLabel == 'very_ripe',
        'rotten' => item.ripenessLabel == 'rotten',
        _ => true,
      };
    }).toList();
  }

  Future<void> _confirmDelete(BuildContext context, ScanResult item) async {
    final confirmed = await showDeleteHistoryDialog(context, item);
    if (confirmed && item.id != null) {
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
              // 1. Kolom cari statis fokus status kematangan pisang
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Cari: Mentah, Matang, Matang Banget, Busuk...',
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

              // 2. Chip filter 4 kelas kematangan lengkap
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Semua'),
                    const SizedBox(width: AppDimens.s8),
                    _buildFilterChip('unripe', 'Mentah'),
                    const SizedBox(width: AppDimens.s8),
                    _buildFilterChip('ripe', 'Matang'),
                    const SizedBox(width: AppDimens.s8),
                    _buildFilterChip('overripe', 'Matang Banget'),
                    const SizedBox(width: AppDimens.s8),
                    _buildFilterChip('rotten', 'Busuk'),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.s12),

              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.s8),
                child: Text(
                  '${filteredItems.length} hasil pindai',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: harvest.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // 3. Daftar Kartu Riwayat
              if (filteredItems.isEmpty)
                const EmptyState(
                  title: 'Tidak Ditemukan',
                  message:
                      'Tidak ada riwayat yang cocok dengan kata kunci atau filter ini.',
                )
              else
                ...filteredItems.map(
                  (item) => HistoryItemCard(
                    item: item,
                    onTap: () => context.push('/history-detail', extra: item),
                    onRequestDelete: () => _confirmDelete(context, item),
                  ),
                ),
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
      'unripe' => (
        harvest.unripe,
        theme.brightness == Brightness.dark
            ? theme.colorScheme.onPrimary
            : Colors.white,
      ),
      'overripe' => (harvest.overripe, Colors.white),
      'rotten' => (harvest.rotten, Colors.white),
      _ => (theme.colorScheme.primary, theme.colorScheme.onPrimary),
    };

    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(AppDimens.rButton),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s12 + 2,
          vertical: AppDimens.s8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : harvest.primarySoft,
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          border: Border.all(
            color: isSelected ? selectedBg : harvest.border,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isSelected ? selectedFg : ink,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
