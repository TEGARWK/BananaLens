import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../core/utils/fruit_name_helper.dart';
import '../../data/models/recipe.dart';
import '../../providers/chat_notifier.dart';
import '../widgets/app_card.dart';
import '../widgets/fruit_vector_icon.dart';
import '../widgets/primary_button.dart';
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
                context.go('/recipes');
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
              recipe.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Panduan langkah demi langkah olahan sehat',
              style: theme.textTheme.labelSmall?.copyWith(
                color: harvest.muted,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: <Widget>[
          // 1. Metric Summary Card
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _InfoItem(
                  icon: Icons.timer_outlined,
                  iconColor: theme.colorScheme.primary,
                  label: 'Waktu Masak',
                  value: recipe.prepTime,
                ),
                Container(height: 38, width: 1, color: harvest.border),
                _InfoItem(
                  icon: Icons.bar_chart_rounded,
                  iconColor: harvest.accent,
                  label: 'Kesulitan',
                  value: recipe.difficulty,
                ),
                Container(height: 38, width: 1, color: harvest.border),
                Column(
                  children: <Widget>[
                    FruitVectorIcon(
                      fruitLabel: recipe.fruitLabel,
                      size: 28,
                      iconSize: 18,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      FruitNameHelper.toIndonesian(
                        recipe.fruitLabel,
                      ).toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${recipe.type.labelId} · ${recipe.ripenessBucket.labelId}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: harvest.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s16),

          if (recipe.safetyNotes != null &&
              recipe.safetyNotes!.trim().isNotEmpty) ...<Widget>[
            AppCard(
              color: harvest.overripe.withValues(alpha: 0.12),
              borderColor: harvest.overripe.withValues(alpha: 0.55),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.health_and_safety_rounded,
                    color: harvest.overripe,
                    size: 22,
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Catatan Keamanan Pengolahan',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: harvest.overripe,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppDimens.s4),
                        Text(
                          recipe.safetyNotes!,
                          style: theme.textTheme.bodySmall?.copyWith(
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

          // 2. Bahan-bahan yang Dibutuhkan (Interactive Checklist)
          Row(
            children: <Widget>[
              Icon(
                Icons.shopping_basket_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppDimens.s8),
              Text(
                'Bahan-bahan yang Dibutuhkan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          AppCard(
            child: Column(
              children: recipe.ingredients.asMap().entries.map((entry) {
                final idx = entry.key;
                final ing = entry.value;
                final isChecked = _checkedIngredients.contains(idx);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isChecked) {
                        _checkedIngredients.remove(idx);
                      } else {
                        _checkedIngredients.add(idx);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(AppDimens.s8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isChecked
                                ? theme.colorScheme.primary
                                : harvest.primarySoft,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isChecked
                                  ? theme.colorScheme.primary
                                  : harvest.border,
                              width: 1.5,
                            ),
                          ),
                          child: isChecked
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: theme.colorScheme.onPrimary,
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
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppDimens.s16),

          // 3. Langkah Pembuatan
          Row(
            children: <Widget>[
              Icon(
                Icons.soup_kitchen_outlined,
                size: 20,
                color: theme.colorScheme.primary,
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
          ...recipe.steps.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final step = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.s8),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppDimens.s8),
                      ),
                      child: Center(
                        child: Text(
                          '$idx',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
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
          AppCard(
            color: harvest.primarySoft.withValues(alpha: 0.5),
            borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.tips_and_updates_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppDimens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Tips Nutrisi Segar',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.s4),
                      Text(
                        'Konsumsi segera setelah dibuat untuk mendapatkan vitamin C dan enzim alami aktif secara maksimal tanpa oksidasi.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: harvest.muted,
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
              ref.read(chatNotifierProvider.notifier).setScanContext(prompt);
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
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Column(
      children: <Widget>[
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: harvest.muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
