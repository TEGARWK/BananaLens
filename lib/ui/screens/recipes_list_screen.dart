import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/recipe.dart';
import '../../providers/auth_providers.dart';
import '../../providers/service_providers.dart';
import '../widgets/app_card.dart';
import '../widgets/fruit_vector_icon.dart';
import '../widgets/shimmer_box.dart';

/// Screen displaying culinary healthy recipes curated for each fruit ripeness level.
class RecipesListScreen extends ConsumerStatefulWidget {
  const RecipesListScreen({this.fruitLabel, this.ripenessLabel, super.key});

  final String? fruitLabel;
  final String? ripenessLabel;

  @override
  ConsumerState<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends ConsumerState<RecipesListScreen> {
  String _selectedFruitFilter = 'Semua';

  static const List<_FruitFilterItem> _filters = <_FruitFilterItem>[
    _FruitFilterItem(label: 'Semua', name: 'Semua'),
    _FruitFilterItem(label: 'banana', name: 'Pisang'),
    _FruitFilterItem(label: 'apple', name: 'Apel'),
    _FruitFilterItem(label: 'avocado', name: 'Alpukat'),
    _FruitFilterItem(label: 'mango', name: 'Mangga'),
    _FruitFilterItem(label: 'watermelon', name: 'Semangka'),
    _FruitFilterItem(label: 'orange', name: 'Jeruk'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.fruitLabel != null && widget.fruitLabel!.isNotEmpty) {
      _selectedFruitFilter = widget.fruitLabel!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeRepo = ref.watch(recipeRepositoryProvider);
    final userProfile = ref.watch(authNotifierProvider).value;
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final future = widget.fruitLabel != null
        ? recipeRepo.getRecipesForFruit(
            widget.fruitLabel!,
            ripenessLabel: widget.ripenessLabel,
          )
        : recipeRepo.getAll();

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
              widget.fruitLabel != null
                  ? 'Resep Olahan ${_getFruitNameId(widget.fruitLabel!)}'
                  : 'Semua Resep Olahan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Inspirasi sehat & lezat tanpa bahan pengawet',
              style: theme.textTheme.labelSmall?.copyWith(
                color: harvest.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(AppDimens.screenPadding),
              child: Column(
                children: [
                  ShimmerBox(height: 120, radius: AppDimens.rCard),
                  SizedBox(height: AppDimens.s16),
                  ShimmerBox(height: 90, radius: AppDimens.rCard),
                  SizedBox(height: AppDimens.s12),
                  ShimmerBox(height: 90, radius: AppDimens.rCard),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                child: Text('Gagal memuat resep: ${snapshot.error}'),
              ),
            );
          }

          final allRecipes = snapshot.data ?? <Recipe>[];
          final filteredRecipes = _selectedFruitFilter == 'Semua'
              ? allRecipes
              : allRecipes.where((r) {
                  return r.fruitLabel.toLowerCase() ==
                      _selectedFruitFilter.toLowerCase();
                }).toList();

          return ListView(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            children: <Widget>[
              // 1. Culinary Hero Banner Card
              if (widget.fruitLabel == null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(AppDimens.s16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[harvest.accent, const Color(0xFFFF9E58)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.rHero),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: harvest.accent.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.s8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.rPill,
                                ),
                              ),
                              child: const Text(
                                'KREASI SEHAT ALAMI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimens.s8),
                            const Text(
                              'Optimalkan Nutrisi Buahmu',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: AppDimens.s4),
                            Text(
                              'Inspirasi smoothie, salad, dan camilan sesuai tingkat kematangan buah segar.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimens.s12),
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.s16),

                // 2. Fruit Categories Filter (Pill Chips)
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: AppDimens.s8),
                    itemBuilder: (BuildContext context, int idx) {
                      final item = _filters[idx];
                      final isSelected = _selectedFruitFilter == item.label;

                      return FilterChip(
                        avatar: item.label == 'Semua'
                            ? Icon(
                                Icons.grid_view_rounded,
                                size: 16,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : harvest.muted,
                              )
                            : FruitVectorIcon(
                                fruitLabel: item.label,
                                size: 22,
                                iconSize: 16,
                              ),
                        label: Text(item.name),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFruitFilter = item.label;
                          });
                        },
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : harvest.muted,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                        backgroundColor: theme.colorScheme.surface,
                        selectedColor: harvest.primarySoft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.rPill),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : harvest.border,
                          width: 1,
                        ),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
              ],

              // 3. Recipes List
              if (filteredRecipes.isEmpty)
                AppCard(
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.restaurant_menu_rounded,
                        size: 44,
                        color: harvest.muted,
                      ),
                      const SizedBox(height: AppDimens.s8),
                      Text(
                        'Belum ada resep untuk kategori ini',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimens.s4),
                      Text(
                        'Pilih kategori buah lain untuk melihat inspirasi olahan lezat.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: harvest.muted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredRecipes.map((recipe) {
                  final hasAllergyWarning = _checkAllergy(
                    recipe,
                    userProfile?.allergies,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.s12),
                    child: AppCard(
                      onTap: () {
                        context.push('/recipe-detail', extra: recipe);
                      },
                      child: Row(
                        children: <Widget>[
                          // 3D Fruit Illustration Thumbnail
                          FruitVectorIcon(
                            fruitLabel: recipe.fruitLabel,
                            size: 56,
                            isCircular: false,
                          ),
                          const SizedBox(width: AppDimens.s12),

                          // Content Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  recipe.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: AppDimens.s4),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: harvest.muted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      recipe.prepTime,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: harvest.muted,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                    ),
                                    const SizedBox(width: AppDimens.s12),
                                    Icon(
                                      Icons.bar_chart_rounded,
                                      size: 14,
                                      color: harvest.muted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      recipe.difficulty,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: harvest.muted,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimens.s8),
                                // Suitable Ripeness Chip Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.s8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: harvest.primarySoft,
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.rPill,
                                    ),
                                  ),
                                  child: Text(
                                    'Cocok: ${_formatRipenessTags(recipe.suitableRipeness)}',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (hasAllergyWarning != null) ...<Widget>[
                                  const SizedBox(height: AppDimens.s8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimens.s8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppDimens.s8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 13,
                                          color: theme.colorScheme.error,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Alergi: $hasAllergyWarning',
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                }),
              const SizedBox(height: AppDimens.s24),
            ],
          );
        },
      ),
    );
  }

  static String _getFruitNameId(String fruitLabel) {
    return switch (fruitLabel.toLowerCase()) {
      'banana' => 'Pisang',
      'apple' => 'Apel',
      'avocado' => 'Alpukat',
      'mango' => 'Mangga',
      'watermelon' => 'Semangka',
      'orange' => 'Jeruk',
      _ => fruitLabel.toUpperCase(),
    };
  }

  static String _formatRipenessTags(List<String> tags) {
    final mapped = tags.map((t) {
      return switch (t.toLowerCase()) {
        'ripe' => 'Matang',
        'unripe' => 'Mentah',
        'overripe' => 'Sangat Matang',
        'rotten' => 'Busuk',
        _ => t,
      };
    }).toList();
    return mapped.join(' & ');
  }

  static String? _checkAllergy(Recipe recipe, List<String>? userAllergies) {
    if (userAllergies == null || userAllergies.isEmpty) return null;
    for (final allergy in userAllergies) {
      final keyword = allergy.split(' ').first.toLowerCase();
      if (recipe.ingredients.any(
            (ing) => ing.toLowerCase().contains(keyword),
          ) ||
          recipe.fruitLabel.toLowerCase().contains(keyword)) {
        return allergy;
      }
    }
    return null;
  }
}

class _FruitFilterItem {
  const _FruitFilterItem({required this.label, required this.name});

  final String label;
  final String name;
}
