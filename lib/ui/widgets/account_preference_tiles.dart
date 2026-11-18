import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';

class _GoalOption {
  const _GoalOption(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}

const List<_GoalOption> _goalOptions = <_GoalOption>[
  _GoalOption(
    'Pola Hidup Sehat',
    'Keseimbangan vitamin & antioksidan harian',
    Icons.favorite_outline_rounded,
  ),
  _GoalOption(
    'Diet & Defisit Kalori',
    'Prioritas buah rendah gula & tinggi serat',
    Icons.local_fire_department_outlined,
  ),
  _GoalOption(
    'Bulking & Massa Otot',
    'Asupan energi padat untuk pemulihan',
    Icons.fitness_center_rounded,
  ),
];

/// Clean selectable cards for choosing the user's primary health goal.
class AccountGoalSelector extends StatelessWidget {
  const AccountGoalSelector({
    required this.selectedGoal,
    required this.onChanged,
    super.key,
  });

  final String selectedGoal;
  final ValueChanged<String> onChanged;

  /// Resolves an initial or unknown goal string into one of the valid options.
  static String normalize(String goal) {
    for (final option in _goalOptions) {
      if (option.title == goal) return option.title;
    }
    return _goalOptions.first.title;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final primary = theme.colorScheme.primary;

    return Column(
      children: [
        for (var i = 0; i < _goalOptions.length; i++) ...[
          _buildGoalCard(
            theme: theme,
            harvest: harvest,
            primary: primary,
            option: _goalOptions[i],
            selected: selectedGoal == _goalOptions[i].title,
          ),
          if (i < _goalOptions.length - 1) const SizedBox(height: AppDimens.s8),
        ],
      ],
    );
  }

  Widget _buildGoalCard({
    required ThemeData theme,
    required HarvestColors harvest,
    required Color primary,
    required _GoalOption option,
    required bool selected,
  }) {
    final ink = theme.colorScheme.onSurface;
    return Material(
      color: selected ? primary.withValues(alpha: 0.25) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.rButton),
      child: InkWell(
        onTap: () => onChanged(option.title),
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.s12,
            vertical: AppDimens.s12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rButton),
            border: Border.all(
              color: selected ? ink : harvest.border,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: primary,
                      offset: const Offset(0, 2.5),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? primary : harvest.primarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.s12),
                  border: Border.all(
                    color: selected ? ink : harvest.border,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  option.icon,
                  size: 19,
                  color: selected ? theme.colorScheme.onPrimary : ink,
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: harvest.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected ? primary : harvest.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clean multi-select allergen cards with high-contrast warning styling.
class AccountAllergySelector extends StatelessWidget {
  const AccountAllergySelector({
    required this.selectedAllergies,
    required this.onToggle,
    super.key,
  });

  final Set<String> selectedAllergies;
  final void Function(String allergen, bool selected) onToggle;

  static const List<String> commonAllergens = <String>[
    'Lateks (Alpukat/Pisang)',
    'Sitrus (Jeruk)',
    'Stroberi',
    'Nanas (Bromelain)',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final errorColor = theme.colorScheme.error;
    final errorBg = theme.colorScheme.errorContainer.withValues(alpha: 0.45);

    return Column(
      children: [
        for (var i = 0; i < commonAllergens.length; i++) ...[
          _buildAllergenTile(
            theme: theme,
            harvest: harvest,
            errorColor: errorColor,
            errorBg: errorBg,
            label: commonAllergens[i],
            active: selectedAllergies.contains(commonAllergens[i]),
          ),
          if (i < commonAllergens.length - 1)
            const SizedBox(height: AppDimens.s8),
        ],
      ],
    );
  }

  Widget _buildAllergenTile({
    required ThemeData theme,
    required HarvestColors harvest,
    required Color errorColor,
    required Color errorBg,
    required String label,
    required bool active,
  }) {
    return Material(
      color: active ? errorBg : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.rButton),
      child: InkWell(
        onTap: () => onToggle(label, !active),
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.s12,
            vertical: AppDimens.s12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rButton),
            border: Border.all(
              color: active
                  ? errorColor.withValues(alpha: 0.55)
                  : harvest.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                active ? Icons.warning_amber_rounded : Icons.shield_outlined,
                size: 20,
                color: active ? errorColor : harvest.muted,
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                active
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 20,
                color: active ? errorColor : harvest.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
