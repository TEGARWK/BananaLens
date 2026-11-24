import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/recipe.dart';
import '../../providers/service_providers.dart';
import 'fruit_vector_icon.dart';
import 'industrial_art.dart';
import 'section_header.dart';
import 'shimmer_box.dart';

/// Horizontal scrolling editorial recipe cards on the Home screen.
/// Uses [IntrinsicHeight] so cards hug their content cleanly with zero dead space.
class HomeRecipesSection extends ConsumerWidget {
  const HomeRecipesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final recipeRepo = ref.watch(recipeRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Resep Rekomendasi',
          actionText: 'Lihat semua',
          onAction: () => context.go('/recipes'),
        ),
        const SizedBox(height: AppDimens.s8),
        FutureBuilder<List<Recipe>>(
          future: recipeRepo.getAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 148,
                child: Row(
                  children: [
                    Expanded(
                      child: ShimmerBox(height: 148, radius: AppDimens.rCard),
                    ),
                    SizedBox(width: AppDimens.s8),
                    Expanded(
                      child: ShimmerBox(height: 148, radius: AppDimens.rCard),
                    ),
                  ],
                ),
              );
            }

            final recipes = (snapshot.data ?? <Recipe>[]).take(5).toList();
            if (recipes.isEmpty) return const SizedBox.shrink();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 2, right: 2),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int index = 0; index < recipes.length; index++) ...[
                      _HomeRecipeCard(
                        recipe: recipes[index],
                        isHighlight: index.isEven,
                        theme: theme,
                        harvest: harvest,
                        onTap: () => context.push(
                          '/recipe-detail',
                          extra: recipes[index],
                        ),
                      ),
                      if (index < recipes.length - 1)
                        const SizedBox(width: AppDimens.s12),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HomeRecipeCard extends StatelessWidget {
  const _HomeRecipeCard({
    required this.recipe,
    required this.isHighlight,
    required this.theme,
    required this.harvest,
    required this.onTap,
  });

  final Recipe recipe;
  final bool isHighlight;
  final ThemeData theme;
  final HarvestColors harvest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 236,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.rCard),
        child: IndustrialSpecimenCard(
          padding: const EdgeInsets.all(AppDimens.s12),
          cornerStyle: ScannerCornerStyle.topRight1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.s8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isHighlight
                          ? theme.colorScheme.primary.withValues(alpha: 0.22)
                          : harvest.primarySoft,
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                    ),
                    child: Row(
                      children: [
                        FruitVectorIcon(
                          fruitLabel: recipe.fruitLabel,
                          ripeness: recipe.ripenessBucket.dbValue,
                          size: 30,
                          isCircular: false,
                        ),
                        const SizedBox(width: AppDimens.s8),
                        Expanded(
                          child: Text(
                            recipe.prepTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: harvest.muted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.s4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: harvest.accent,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rSharp,
                            ),
                          ),
                          child: Text(
                            recipe.difficulty.toUpperCase(),
                            maxLines: 1,
                            style: TextStyle(
                              color: harvest.onAccent,
                              fontSize: 8.8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.s12),
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: harvest.primarySoft,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rSharp,
                            ),
                          ),
                          child: Text(
                            recipe.ripenessBucket.labelId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '· ${recipe.type.labelId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: harvest.muted,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: AppDimens.s12),
                  Divider(height: 1, color: harvest.border),
                  const SizedBox(height: AppDimens.s8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${recipe.ingredients.length} bahan pilihan',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: harvest.muted,
                          fontSize: 11,
                        ),
                      ),
                      Icon(
                        Icons.north_east_rounded,
                        size: 15,
                        color: harvest.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
