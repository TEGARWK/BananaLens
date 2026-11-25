import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/recipe.dart';
import '../../providers/chat_notifier.dart';
import '../widgets/fruitlens_app_bar.dart';
import '../widgets/industrial_art.dart';
import '../widgets/primary_button.dart';
import '../widgets/recipe_detail_sections.dart';
import '../widgets/soft_button.dart';

/// Screen displaying the full instructions, interactive checklist, and cooking tips of a recipe.
class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({required this.recipe, super.key});

  final Recipe recipe;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late final Set<int> _checkedIngredients;

  @override
  void initState() {
    super.initState();
    _checkedIngredients = <int>{};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: FruitLensAppBar(
        title: recipe.title,
        subtitle: 'Panduan langkah demi langkah olahan sehat',
        showBackButton: true,
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/recipes');
          }
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            children: <Widget>[
              // 1. Header, Source Badge & Available Metadata
              RecipeDetailHeaderCard(recipe: recipe),
              const SizedBox(height: AppDimens.s16),

              if (recipe.safetyNotes != null &&
                  recipe.safetyNotes!.trim().isNotEmpty) ...<Widget>[
                IndustrialSpecimenCard(
                  backgroundColor: harvest.overripe.withValues(alpha: 0.12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: harvest.overripe.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(
                            AppDimens.rButton,
                          ),
                        ),
                        child: Icon(
                          Icons.health_and_safety_rounded,
                          color: harvest.overripe,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppDimens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Catatan Keamanan Pengolahan',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppDimens.s4),
                            Text(
                              recipe.safetyNotes!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
              ],

              // 2. Bahan-bahan yang Dibutuhkan (Interactive Checklist + Copy)
              RecipeIngredientsCard(
                ingredients: recipe.ingredients,
                checkedIndices: _checkedIngredients,
                onToggle: (idx) {
                  setState(() {
                    if (_checkedIngredients.contains(idx)) {
                      _checkedIngredients.remove(idx);
                    } else {
                      _checkedIngredients.add(idx);
                    }
                  });
                },
              ),
              const SizedBox(height: AppDimens.s16),

              // 3. Langkah Pembuatan
              Row(
                children: <Widget>[
                  Icon(
                    Icons.soup_kitchen_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Text(
                    'Langkah Pembuatan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s8),
              if (recipe.steps.isEmpty)
                IndustrialSpecimenCard(
                  child: Text(
                    'Langkah pembuatan belum tersedia untuk resep ini.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: harvest.muted,
                    ),
                  ),
                ),
              ...recipe.steps.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final step = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.s8),
                  child: IndustrialSpecimenCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rButton,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$idx',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.s12),
                        Expanded(
                          child: Text(
                            step,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppDimens.s12),

              // 4. Tips Ahli Nutrisi FruitLens
              IndustrialSpecimenCard(
                backgroundColor: theme.brightness == Brightness.dark
                    ? AppColors.dLeafSoft
                    : AppColors.lLeafSoft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.dLeafGreen
                            : AppColors.lLeafStrong,
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                      ),
                      child: Icon(
                        Icons.tips_and_updates_rounded,
                        size: 16,
                        color: theme.brightness == Brightness.dark
                            ? AppColors.dOnPrimary
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppDimens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Tips Nutrisi Segar',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppDimens.s4),
                          Text(
                            'Konsumsi segera setelah dibuat untuk mendapatkan vitamin C dan enzim alami aktif secara maksimal tanpa oksidasi.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.s20),

              // 5. Action Buttons: Tanya AI & Kembali
              PrimaryButton(
                text: 'Tanya AI Modifikasi Resep',
                icon: Icons.auto_awesome_rounded,
                onPressed: () {
                  final prompt =
                      'Halo, saya ingin membuat resep "${recipe.title}" dengan bahan utama ${recipe.fruitLabel}. Bisakah beri saran modifikasi atau pengganti bahan yang lebih sehat / rendah kalori?';
                  ref
                      .read(chatNotifierProvider.notifier)
                      .startNewChatAndSend(prompt);
                  context.go('/chat');
                },
              ),
              const SizedBox(height: AppDimens.s12),
              SoftButton(
                text: 'Kembali ke Daftar Resep',
                icon: Icons.arrow_back_rounded,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/recipes');
                  }
                },
              ),
              const SizedBox(height: AppDimens.s24),
            ],
          ),
        ),
      ),
    );
  }
}
