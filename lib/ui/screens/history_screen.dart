import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/ripeness.dart';
import '../../data/models/scan_result.dart';
import '../../providers/history_providers.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/fruit_image.dart';
import '../widgets/ripeness_chip.dart';
import '../widgets/shimmer_box.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ScanResult> _filterItems(List<ScanResult> items) {
    return items.where((item) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!item.fruitLabel.toLowerCase().contains(query)) {
          return false;
        }
      }

      return switch (_selectedFilter) {
        'ripe' => item.ripenessLabel == 'ripe',
        'unripe' => item.ripenessLabel == 'unripe',
        'overripe' => item.ripenessLabel == 'overripe',
        'rotten' => item.ripenessLabel == 'rotten',
        _ => true,
      };
    }).toList();
  }

  Future<void> _confirmDelete(BuildContext context, ScanResult item) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
        ),
        title: const Text('Hapus Riwayat?'),
        content: Text('Riwayat scan ${item.fruitLabel} akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
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
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Riwayat Scan'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: historyAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            children: [
              ShimmerBox(height: 48, radius: AppDimens.rPill),
              SizedBox(height: AppDimens.s16),
              ShimmerBox(height: 80, radius: AppDimens.rCard),
              SizedBox(height: AppDimens.s12),
              ShimmerBox(height: 80, radius: AppDimens.rCard),
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
              vertical: AppDimens.s8,
            ),
            children: [
              // 1. Kolom cari bentuk pil
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari riwayat buah...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppDimens.s12),

              // 2. Chip filter horizontal
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
                    _buildFilterChip('overripe', 'Terlalu matang'),
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
                        return false; // Notifier updates UI state
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
                      child: AppCard(
                        padding: const EdgeInsets.all(AppDimens.s12),
                        onTap: () =>
                            context.push('/history-detail', extra: item),
                        child: Row(
                          children: [
                            FruitImage(
                              imagePath: item.imagePath,
                              fruitLabel: item.fruitLabel,
                              width: 64,
                              height: 64,
                              radius: AppDimens.s12,
                            ),
                            const SizedBox(width: AppDimens.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatFruitName(item.fruitLabel),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: AppDimens.s4),
                                  Text(
                                    _formatDate(item.createdAt),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: harvest.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (ripeness != null)
                              RipenessChip(ripeness: ripeness),
                            const SizedBox(width: AppDimens.s4),
                            IconButton(
                              icon: Icon(
                                item.isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: item.isFavorite
                                    ? Colors.amber
                                    : harvest.muted,
                                size: 22,
                              ),
                              onPressed: () {
                                if (item.id != null) {
                                  ref
                                      .read(historyListProvider.notifier)
                                      .toggleFavorite(
                                        item.id!,
                                        item.isFavorite,
                                      );
                                }
                              },
                            ),
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
    final isSelected = _selectedFilter == key;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = key),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: isSelected ? theme.colorScheme.onPrimary : harvest.muted,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.rPill),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : harvest.border,
          width: 1,
        ),
      ),
      showCheckmark: false,
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
