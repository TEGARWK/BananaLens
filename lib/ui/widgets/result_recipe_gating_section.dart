import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/recipe.dart';
import '../../data/models/scan_outcome.dart';
import '../../providers/recipe_gating_provider.dart';
import '../../services/recipe_gating_service.dart';
import 'industrial_art.dart';
import 'primary_button.dart';

/// Post-scan Recipe gating section on ResultScreen.
/// Evaluates safety/ripeness gating locally (0 LLM quota used) and navigates to
/// `/scan-recipes` only when the user taps "Rekomendasi Resep".
class ResultRecipeGatingSection extends ConsumerStatefulWidget {
  const ResultRecipeGatingSection({super.key, required this.outcome});

  final ScanSuccess outcome;

  @override
  ConsumerState<ResultRecipeGatingSection> createState() =>
      _ResultRecipeGatingSectionState();
}

class _ResultRecipeGatingSectionState
    extends ConsumerState<ResultRecipeGatingSection> {
  // 0 = "Tunggu matang", 1 = "Masak sekarang" for unripe edible fruits.
  int _unripeTabIndex = 0;

  void _openScanRecipes({
    required String fruitName,
    required RipenessBucket bucket,
  }) {
    context.push(
      '/scan-recipes',
      extra: ScanRecipesArgs(
        outcome: widget.outcome,
        bucket: bucket,
        fruitName: fruitName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gateAsync = ref.watch(recipeGateProvider(widget.outcome));

    return gateAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.s16),
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: context.harvest.primarySoft.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppDimens.rCard),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (result) => switch (result) {
        UnknownFruitResult() => const SizedBox.shrink(),
        RottenDiscardResult(:final fruitName) => _buildRottenCard(
          context,
          fruitName,
        ),
        UnripeWaitOnlyResult(:final fruitName, :final estimatedDays) =>
          _buildWaitOnlyCard(context, fruitName, estimatedDays),
        UnripeDualOptionResult(
          :final fruitName,
          :final estimatedDays,
          :final bucket,
        ) =>
          _buildDualOptionCard(context, fruitName, estimatedDays, bucket),
        RipeBucketReadyResult(:final fruitName, :final bucket) =>
          _buildRipeCtaCard(context, fruitName, bucket),
      },
    );
  }

  Widget _buildRottenCard(BuildContext context, String fruitName) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s16),
      child: IndustrialSpecimenCard(
        backgroundColor: Color.alphaBlend(
          errorColor.withValues(alpha: 0.12),
          theme.colorScheme.surface,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.dangerous_rounded, color: errorColor, size: 24),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buang saja, jangan dikonsumsi',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: errorColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s4),
                  Text(
                    '$fruitName menunjukkan tanda pembusukan dan tidak aman diolah menjadi makanan atau minuman.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.85,
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
    );
  }

  Widget _buildWaitOnlyCard(
    BuildContext context,
    String fruitName,
    String estimatedDays,
  ) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s16),
      child: IndustrialSpecimenCard(
        backgroundColor: Color.alphaBlend(
          harvest.unripe.withValues(alpha: 0.14),
          theme.colorScheme.surface,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.schedule_rounded,
              color: Color(0xFF3E7D28),
              size: 24,
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tunggu dulu sampai matang',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF3E7D28),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s4),
                  Text(
                    '$fruitName masih mentah dan belum layak diolah langsung. Perkiraan waktu matang: $estimatedDays.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.85,
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
    );
  }

  Widget _buildDualOptionCard(
    BuildContext context,
    String fruitName,
    String estimatedDays,
    RipenessBucket bucket,
  ) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opsi Olahan ($fruitName Mentah)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.s8),
          Row(
            children: [
              Expanded(
                child: _OptionTabButton(
                  label: 'Tunggu matang',
                  icon: Icons.schedule_rounded,
                  selected: _unripeTabIndex == 0,
                  onTap: () => setState(() => _unripeTabIndex = 0),
                ),
              ),
              const SizedBox(width: AppDimens.s8),
              Expanded(
                child: _OptionTabButton(
                  label: 'Masak sekarang',
                  icon: Icons.restaurant_rounded,
                  selected: _unripeTabIndex == 1,
                  onTap: () => setState(() => _unripeTabIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s12),
          if (_unripeTabIndex == 0)
            IndustrialSpecimenCard(
              backgroundColor: Color.alphaBlend(
                harvest.unripe.withValues(alpha: 0.14),
                theme.colorScheme.surface,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_bottom_rounded,
                    color: Color(0xFF3E7D28),
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: Text(
                      'Perkiraan $fruitName matang siap konsumsi langsung: $estimatedDays.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            IndustrialSpecimenCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$fruitName mentah bisa diolah dengan dimasak terlebih dahulu.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.85,
                      ),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s12),
                  PrimaryButton(
                    text: 'Rekomendasi Resep',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: () =>
                        _openScanRecipes(fruitName: fruitName, bucket: bucket),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRipeCtaCard(
    BuildContext context,
    String fruitName,
    RipenessBucket bucket,
  ) {
    final theme = Theme.of(context);
    final desc = bucket == RipenessBucket.veryRipe
        ? '$fruitName sangat matang cocok diolah menjadi smoothie, pancake, atau banana bread.'
        : '$fruitName matang pas cocok dinikmati segar atau diolah ringan seperti salad dan jus.';

    final ink = theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s16),
      child: IndustrialSpecimenCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppDimens.rSharp),
                    border: Border.all(color: ink, width: 1.2),
                  ),
                  child: Icon(Icons.auto_awesome_rounded, size: 16, color: ink),
                ),
                const SizedBox(width: AppDimens.s8),
                Expanded(
                  child: Text(
                    'Ide Olahan $fruitName',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppDimens.rSharp),
                    border: Border.all(color: ink, width: 1.2),
                  ),
                  child: Text(
                    bucket.labelId,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.s8),
            Text(
              desc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ink.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimens.s12),
            PrimaryButton(
              text: 'Rekomendasi Resep',
              icon: Icons.restaurant_menu_rounded,
              onPressed: () =>
                  _openScanRecipes(fruitName: fruitName, bucket: bucket),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTabButton extends StatelessWidget {
  const _OptionTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final ink = theme.colorScheme.onSurface;
    return Container(
      decoration: BoxDecoration(
        color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.rSharp),
        border: Border.all(
          color: selected ? ink : harvest.border,
          width: selected ? 1.5 : 1.0,
        ),
        boxShadow: selected
            ? [BoxShadow(color: ink, offset: const Offset(2, 2), blurRadius: 0)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.rSharp),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s12,
              vertical: AppDimens.s8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: AppDimens.s4),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
