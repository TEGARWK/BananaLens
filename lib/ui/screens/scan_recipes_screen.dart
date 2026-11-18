import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/recipe.dart';
import '../../providers/recipe_gating_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/fruit_vector_icon.dart';
import '../widgets/shimmer_box.dart';

/// Dedicated screen displaying recipes generated live by Gemini AI at the top,
/// followed by curated local JSON/SQLite backup recipes below (and as offline fallback).
class ScanRecipesScreen extends ConsumerStatefulWidget {
  const ScanRecipesScreen({super.key, required this.args});

  final ScanRecipesArgs args;

  @override
  ConsumerState<ScanRecipesScreen> createState() => _ScanRecipesScreenState();
}

class _ScanRecipesScreenState extends ConsumerState<ScanRecipesScreen> {
  late RecipePreference _selectedPref;

  @override
  void initState() {
    super.initState();
    _selectedPref = widget.args.preference;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final activeArgs = widget.args.copyWith(preference: _selectedPref);
    final recipesAsync = ref.watch(scanRecipesProvider(activeArgs));
    final pct = (widget.args.outcome.ripenessConfidence * 100).toStringAsFixed(
      0,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(AppDimens.s8),
          child: IconButton(
            tooltip: 'Kembali',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: harvest.primarySoft,
              foregroundColor: theme.colorScheme.primary,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rekomendasi Resep ${widget.args.fruitName}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '${widget.args.bucket.labelId} · Keyakinan $pct%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: harvest.muted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Buat Variasi AI Baru',
            onPressed: () => ref.invalidate(scanRecipesProvider(activeArgs)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preference selector chips: Semua, Makanan, Minuman, Manis, Gurih, Praktis
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
                vertical: AppDimens.s4,
              ),
              itemCount: RecipePreference.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppDimens.s8),
              itemBuilder: (context, idx) {
                final pref = RecipePreference.values[idx];
                final isSelected = _selectedPref == pref;
                return ChoiceChip(
                  label: Text(pref.labelId),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (!selected && isSelected) return;
                    setState(() => _selectedPref = pref);
                  },
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : harvest.border,
                  ),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: recipesAsync.when(
              loading: () => const _ScanRecipesSkeleton(),
              error: (err, _) => ErrorState(
                message: 'Gagal memuat rekomendasi resep.',
                onRetry: () => ref.invalidate(scanRecipesProvider(activeArgs)),
              ),
              data: (result) {
                if (result.recipes.isEmpty) {
                  return const EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: 'Resep belum tersedia',
                    message:
                        'Belum ada resep yang tersedia untuk kombinasi buah dan kematangan ini.',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(AppDimens.screenPadding),
                  children: [
                    // Source indicator banner (Live Gemini AI vs Offline Backup)
                    AppCard(
                      color: result.isFromLiveAi
                          ? harvest.primarySoft
                          : harvest.accent.withValues(alpha: 0.12),
                      borderColor: result.isFromLiveAi
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : harvest.accent.withValues(alpha: 0.45),
                      child: Row(
                        children: [
                          Icon(
                            result.isFromLiveAi
                                ? Icons.auto_awesome_rounded
                                : Icons.offline_pin_rounded,
                            size: 20,
                            color: result.isFromLiveAi
                                ? theme.colorScheme.primary
                                : harvest.accent,
                          ),
                          const SizedBox(width: AppDimens.s12),
                          Expanded(
                            child: Text(
                              result.isFromLiveAi
                                  ? 'Resep dibuat khusus oleh AI sesuai tingkat kematangan (${widget.args.bucket.labelId}${_selectedPref == RecipePreference.any ? '' : ' · ${_selectedPref.labelId}'}).'
                                  : (result.fallbackReason ??
                                        'Menampilkan resep pilihan yang tersimpan di aplikasi.'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.s16),

                    if (result.aiRecipes.isNotEmpty) ...[
                      _SectionLabel(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Ide Resep Spesial AI',
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: AppDimens.s8),
                      ...result.aiRecipes.map(
                        (recipe) => _ScanRecipeCard(
                          recipe: recipe,
                          isAiGenerated: true,
                        ),
                      ),
                    ],

                    if (result.backupRecipes.isNotEmpty) ...[
                      if (result.aiRecipes.isNotEmpty)
                        const SizedBox(height: AppDimens.s8),
                      _SectionLabel(
                        icon: Icons.menu_book_rounded,
                        title: result.aiRecipes.isNotEmpty
                            ? 'Resep Pilihan Lainnya'
                            : 'Resep Pilihan Offline',
                        color: result.aiRecipes.isNotEmpty
                            ? harvest.muted
                            : harvest.accent,
                      ),
                      const SizedBox(height: AppDimens.s8),
                      ...result.backupRecipes.map(
                        (recipe) => _ScanRecipeCard(
                          recipe: recipe,
                          isAiGenerated: false,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanRecipesSkeleton extends StatelessWidget {
  const _ScanRecipesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        const ShimmerBox(height: 58, radius: AppDimens.rCard),
        const SizedBox(height: AppDimens.s16),
        const Align(
          alignment: Alignment.centerLeft,
          child: ShimmerBox(width: 170, height: 18, radius: AppDimens.s8),
        ),
        const SizedBox(height: AppDimens.s12),
        for (var i = 0; i < 4; i++) ...[
          const AppCard(
            child: Row(
              children: [
                ShimmerBox(width: 52, height: 52, radius: AppDimens.rCard),
                SizedBox(width: AppDimens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 180, height: 16, radius: 6),
                      SizedBox(height: AppDimens.s8),
                      Row(
                        children: [
                          ShimmerBox(
                            width: 64,
                            height: 18,
                            radius: AppDimens.rPill,
                          ),
                          SizedBox(width: AppDimens.s8),
                          ShimmerBox(width: 56, height: 14, radius: 6),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s12),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppDimens.s8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ScanRecipeCard extends StatelessWidget {
  const _ScanRecipeCard({required this.recipe, required this.isAiGenerated});

  final Recipe recipe;
  final bool isAiGenerated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final hasSafety =
        recipe.safetyNotes != null && recipe.safetyNotes!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s12),
      child: AppCard(
        onTap: () => context.push('/recipe-detail', extra: recipe),
        child: Row(
          children: [
            FruitVectorIcon(
              fruitLabel: recipe.fruitLabel,
              size: 52,
              isCircular: false,
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isAiGenerated) ...[
                        const SizedBox(width: AppDimens.s8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.s8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: harvest.accent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(
                              AppDimens.rPill,
                            ),
                            border: Border.all(
                              color: harvest.accent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 11,
                                color: harvest.accent,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'AI',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: harvest.accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppDimens.s4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.s8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: harvest.primarySoft,
                          borderRadius: BorderRadius.circular(AppDimens.rPill),
                        ),
                        child: Text(
                          recipe.type.labelId,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimens.s8),
                      Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: harvest.muted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        recipe.prepTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: harvest.muted,
                          fontSize: 11,
                        ),
                      ),
                      if (hasSafety) ...[
                        const SizedBox(width: AppDimens.s8),
                        Icon(
                          Icons.health_and_safety_rounded,
                          size: 14,
                          color: harvest.overripe,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.s8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: harvest.muted,
            ),
          ],
        ),
      ),
    );
  }
}
