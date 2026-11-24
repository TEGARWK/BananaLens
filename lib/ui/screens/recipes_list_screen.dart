import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../core/utils/fruit_name_helper.dart';
import '../../data/models/recipe.dart';
import '../../providers/auth_providers.dart';
import '../../providers/chat_notifier.dart';
import '../../providers/service_providers.dart';
import '../widgets/error_state.dart';
import '../widgets/fruit_vector_icon.dart';
import '../widgets/fruitlens_app_bar.dart';
import '../widgets/industrial_art.dart';
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
  String _selectedFilter = 'all';

  static const List<_RecipeFilterItem> _filters = <_RecipeFilterItem>[
    _RecipeFilterItem(
      key: 'all',
      label: 'Semua',
      icon: Icons.grid_view_rounded,
    ),
    _RecipeFilterItem(key: 'unripe', label: 'Mentah', icon: Icons.eco_rounded),
    _RecipeFilterItem(
      key: 'ripe',
      label: 'Matang',
      icon: Icons.check_circle_outline_rounded,
    ),
    _RecipeFilterItem(
      key: 'very_ripe',
      label: 'Matang Banget',
      icon: Icons.local_fire_department_rounded,
    ),
    _RecipeFilterItem(
      key: 'food',
      label: 'Makanan',
      icon: Icons.restaurant_rounded,
    ),
    _RecipeFilterItem(
      key: 'drink',
      label: 'Minuman',
      icon: Icons.local_cafe_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.ripenessLabel != null && widget.ripenessLabel!.isNotEmpty) {
      final norm = widget.ripenessLabel!.trim().toLowerCase();
      if (norm == 'overripe' || norm == 'very_ripe') {
        _selectedFilter = 'very_ripe';
      } else if (norm == 'unripe' || norm == 'ripe') {
        _selectedFilter = norm;
      }
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
      appBar: FruitLensAppBar(
        title: widget.fruitLabel != null
            ? 'Resep Olahan ${FruitNameHelper.toIndonesian(widget.fruitLabel!)}'
            : 'Semua Resep Olahan',
        subtitle: 'Inspirasi sehat & lezat tanpa bahan pengawet',
        showBackButton: true,
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
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
              child: ErrorState(
                title: 'Gagal Memuat Resep',
                message:
                    'Terjadi kendala saat membaca daftar resep: ${snapshot.error}',
                onRetry: () => setState(() {}),
              ),
            );
          }

          final allRecipes = snapshot.data ?? <Recipe>[];
          final filteredRecipes = _applyFilter(allRecipes);

          return ListView(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            children: <Widget>[
              // 1. Culinary Hero Banner Card
              if (widget.fruitLabel == null) ...<Widget>[
                IndustrialSpecimenCard(
                  backgroundColor: harvest.primarySoft,
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
                                color: theme.brightness == Brightness.dark
                                    ? AppColors.dLeafSoft
                                    : AppColors.lLeafSoft,
                                borderRadius: BorderRadius.circular(
                                  AppDimens.rSharp,
                                ),
                              ),
                              child: Text(
                                'KREASI SEHAT ALAMI',
                                style: TextStyle(
                                  color: theme.brightness == Brightness.dark
                                      ? AppColors.dLeafGreen
                                      : AppColors.lLeafStrong,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimens.s8),
                            Text(
                              'Optimalkan Nutrisi Pisangmu',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: AppDimens.s4),
                            Text(
                              'Inspirasi smoothie, camilan, dan olahan lezat sesuai tingkat kematangan pisang.',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimens.s12),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(
                            AppDimens.rButton,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.s16),

                // 2. Fruit Categories Filter (Industrial Chips, Touch target >= 44dp)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 3, right: 3),
                    itemCount: _filters.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: AppDimens.s8),
                    itemBuilder: (BuildContext context, int idx) {
                      final item = _filters[idx];
                      final isSelected = _selectedFilter == item.key;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = item.key;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.s12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : harvest.primarySoft,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rButton,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : harvest.border,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: 15,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
              ],

              // 3. Recipes List
              if (filteredRecipes.isEmpty)
                IndustrialSpecimenCard(
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
                        'Pilih filter kematangan atau kategori olahan lain untuk melihat inspirasi resep pisang.',
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
                    child: InkWell(
                      onTap: () {
                        context.push('/recipe-detail', extra: recipe);
                      },
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                      child: IndustrialSpecimenCard(
                        child: Row(
                          children: <Widget>[
                            // 3D Fruit Illustration Thumbnail
                            FruitVectorIcon(
                              fruitLabel: recipe.fruitLabel,
                              ripeness: recipe.ripenessBucket.dbValue,
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
                                        AppDimens.rSharp,
                                      ),
                                      border: Border.all(color: harvest.border),
                                    ),
                                    child: Text(
                                      'Cocok: ${_formatRipenessTags(recipe.suitableRipeness)}',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
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
                                        color: theme.colorScheme.error
                                            .withValues(alpha: 0.1),
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
                    ),
                  );
                }),
              const SizedBox(height: AppDimens.s4),
              // AI Recipe Creator CTA Banner
              InkWell(
                onTap: () {
                  final filterContext = switch (_selectedFilter) {
                    'unripe' => 'pisang mentah',
                    'ripe' => 'pisang matang',
                    'very_ripe' => 'pisang matang banget',
                    'drink' => 'pisang untuk minuman segar',
                    'food' => 'pisang untuk makanan atau camilan',
                    _ => 'pisang',
                  };
                  final prompt =
                      'Saya punya bahan $filterContext di rumah. Tolong buatkan 1 ide kreasi olahan sehat yang mudah dibuat dengan bahan sederhana.';
                  ref
                      .read(chatNotifierProvider.notifier)
                      .startNewChatAndSend(prompt);
                  context.go('/chat');
                },
                borderRadius: BorderRadius.circular(AppDimens.rSharp),
                child: IndustrialSpecimenCard(
                  backgroundColor: harvest.primarySoft,
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(AppDimens.s12),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.primary
                              : AppColors.lSurfaceDark,
                          borderRadius: BorderRadius.circular(
                            AppDimens.rButton,
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onPrimary
                              : AppColors.lPrimary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppDimens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Mau Resep Kustom? Tanya AI',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kreasikan ide masakan sehat sesuai bahan yang ada di kulkasmu.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: harvest.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.s24),
            ],
          );
        },
      ),
    );
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

  List<Recipe> _applyFilter(List<Recipe> recipes) {
    return switch (_selectedFilter) {
      'unripe' =>
        recipes
            .where((r) => r.ripenessBucket == RipenessBucket.unripe)
            .toList(),
      'ripe' =>
        recipes.where((r) => r.ripenessBucket == RipenessBucket.ripe).toList(),
      'very_ripe' =>
        recipes
            .where((r) => r.ripenessBucket == RipenessBucket.veryRipe)
            .toList(),
      'food' => recipes.where((r) => r.type == RecipeType.food).toList(),
      'drink' => recipes.where((r) => r.type == RecipeType.drink).toList(),
      _ => recipes,
    };
  }
}

class _RecipeFilterItem {
  const _RecipeFilterItem({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}
