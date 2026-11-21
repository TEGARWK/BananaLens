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

/// Horizontal scrolling section showing daily curated recipes.
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
                height: 140,
                child: Row(
                  children: [
                    Expanded(
                      child: ShimmerBox(height: 140, radius: AppDimens.rCard),
                    ),
                    SizedBox(width: AppDimens.s8),
                    Expanded(
                      child: ShimmerBox(height: 140, radius: AppDimens.rCard),
                    ),
                  ],
                ),
              );
            }

            final recipes = snapshot.data ?? <Recipe>[];
            if (recipes.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 212,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 4, right: 4),
                itemCount: recipes.length.clamp(0, 5),
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppDimens.s12),
                itemBuilder: (context, index) {
                  final recipe = recipes[index];

                  return SizedBox(
                    width: 220,
                    child: InkWell(
                      onTap: () =>
                          context.push('/recipe-detail', extra: recipe),
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                      child: IndustrialSpecimenCard(
                        padding: const EdgeInsets.all(AppDimens.s12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FruitVectorIcon(
                                  fruitLabel: recipe.fruitLabel,
                                  ripeness: recipe.ripenessBucket.dbValue,
                                  size: 36,
                                  isCircular: false,
                                ),
                                const SizedBox(width: AppDimens.s8),
                                Expanded(
                                  child: Text(
                                    recipe.prepTime,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: harvest.muted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.rSharp,
                                    ),
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    recipe.difficulty,
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              recipe.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: AppDimens.s4),
                            Text(
                              '${recipe.ripenessBucket.labelId} · ${recipe.ingredients.length} bahan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: harvest.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
