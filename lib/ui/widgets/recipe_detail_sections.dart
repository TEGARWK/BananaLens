import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../core/utils/fruit_name_helper.dart';
import '../../data/models/recipe.dart';
import 'fruit_vector_icon.dart';
import 'industrial_art.dart';

/// Header card displaying a neutral BananaLens illustration, recipe title,
/// explicit source badge (`Resep Lokal` vs `Resep AI`), and available metadata.
class RecipeDetailHeaderCard extends StatelessWidget {
  const RecipeDetailHeaderCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final isAi = recipe.source == RecipeSource.ai;
    final hasPrep = recipe.prepTime.trim().isNotEmpty;
    final hasDiff = recipe.difficulty.trim().isNotEmpty;

    return IndustrialSpecimenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: harvest.primarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.rCard),
                  border: Border.all(color: harvest.border),
                ),
                alignment: Alignment.center,
                child: FruitVectorIcon(
                  fruitLabel: recipe.fruitLabel,
                  ripeness: recipe.ripenessBucket.dbValue,
                  size: 38,
                  isCircular: false,
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: AppDimens.s8,
                      runSpacing: AppDimens.s4,
                      children: <Widget>[
                        _SourceBadge(
                          label: isAi ? 'Resep AI' : 'Resep Lokal',
                          icon: isAi
                              ? Icons.auto_awesome_rounded
                              : Icons.menu_book_rounded,
                          isAi: isAi,
                        ),
                        if (!isAi && recipe.isReviewed)
                          const _MetaPill(label: 'Terkurasi'),
                        _MetaPill(
                          label:
                              '${recipe.type.labelId} · ${recipe.ripenessBucket.labelId}',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.s8),
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FruitNameHelper.toIndonesian(recipe.fruitLabel),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: harvest.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasPrep || hasDiff) ...<Widget>[
            const SizedBox(height: AppDimens.s12),
            Divider(height: 1, color: harvest.border),
            const SizedBox(height: AppDimens.s12),
            Row(
              children: <Widget>[
                if (hasPrep)
                  Expanded(
                    child: _MetaItem(
                      icon: Icons.timer_outlined,
                      label: 'Waktu Masak',
                      value: recipe.prepTime,
                    ),
                  ),
                if (hasPrep && hasDiff)
                  Container(height: 34, width: 1, color: harvest.border),
                if (hasDiff)
                  Expanded(
                    child: _MetaItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Kesulitan',
                      value: recipe.difficulty,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({
    required this.label,
    required this.icon,
    required this.isAi,
  });

  final String label;
  final IconData icon;
  final bool isAi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final bg = isAi ? theme.colorScheme.primary : harvest.accent;
    final fg = isAi ? theme.colorScheme.onPrimary : harvest.onAccent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rSharp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: harvest.primarySoft,
        borderRadius: BorderRadius.circular(AppDimens.rSharp),
        border: Border.all(color: harvest.border),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 10.5,
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 18, color: theme.colorScheme.onSurface),
        const SizedBox(width: AppDimens.s8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: harvest.muted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Interactive ingredients checklist with preparation progress and clipboard copy.
class RecipeIngredientsCard extends StatelessWidget {
  const RecipeIngredientsCard({
    super.key,
    required this.ingredients,
    required this.checkedIndices,
    required this.onToggle,
  });

  final List<String> ingredients;
  final Set<int> checkedIndices;
  final ValueChanged<int> onToggle;

  Future<void> _copyIngredients(BuildContext context) async {
    final text = ingredients.map((item) => '- $item').join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daftar bahan disalin ke clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final total = ingredients.length;
    final checkedCount = checkedIndices.where((i) => i < total).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.shopping_basket_outlined,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: AppDimens.s8),
            Expanded(
              child: Text(
                'Bahan-bahan yang Dibutuhkan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (total > 0)
              TextButton.icon(
                onPressed: () => _copyIngredients(context),
                icon: const Icon(Icons.copy_rounded, size: 15),
                label: const Text('Salin'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s8,
                    vertical: 4,
                  ),
                  minimumSize: const Size(44, 36),
                ),
              ),
          ],
        ),
        if (total > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.s8),
            child: Text(
              '$checkedCount dari $total bahan disiapkan',
              style: theme.textTheme.labelSmall?.copyWith(
                color: harvest.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          const SizedBox(height: AppDimens.s8),
        IndustrialSpecimenCard(
          child: total == 0
              ? Text(
                  'Daftar bahan belum tersedia untuk resep ini.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: harvest.muted,
                  ),
                )
              : Column(
                  children: ingredients.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ing = entry.value;
                    final isChecked = checkedIndices.contains(idx);

                    return InkWell(
                      onTap: () => onToggle(idx),
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? (theme.brightness == Brightness.dark
                                            ? AppColors.dLeafGreen
                                            : AppColors.lLeafStrong)
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.rSharp,
                                  ),
                                  border: Border.all(
                                    color: isChecked
                                        ? (theme.brightness == Brightness.dark
                                              ? AppColors.dLeafGreen
                                              : AppColors.lLeafStrong)
                                        : harvest.border,
                                    width: 1.4,
                                  ),
                                ),
                                child: isChecked
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 15,
                                        color:
                                            theme.brightness == Brightness.dark
                                            ? AppColors.dOnPrimary
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppDimens.s12),
                              Expanded(
                                child: Text(
                                  ing,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isChecked
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                    decoration: isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isChecked
                                        ? harvest.muted
                                        : theme.textTheme.bodyMedium?.color,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
