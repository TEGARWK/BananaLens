import 'package:flutter/material.dart';

import 'package:fruitlens/core/theme/app_colors.dart';
import 'package:fruitlens/core/theme/app_radius.dart';
import 'package:fruitlens/core/theme/app_spacing.dart';

/// Screen showcasing design tokens and theme integration for verification.
class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ripeness = theme.extension<RipenessColors>() ?? RipenessColors.light;

    return Scaffold(
      appBar: AppBar(title: const Text('Design System Preview')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          Text(
            'Identitas Visual: FruitLens',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Segar, bersih, hangat, dan informatif',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 1. Brand Palette
          Text(
            'Palet Brand & Surface',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _ColorChip(
                name: 'Primary',
                color: colorScheme.primary,
                onColor: colorScheme.onPrimary,
              ),
              _ColorChip(
                name: 'Secondary',
                color: colorScheme.secondary,
                onColor: colorScheme.onSecondary,
              ),
              _ColorChip(
                name: 'Tertiary',
                color: colorScheme.tertiary,
                onColor: colorScheme.onTertiary,
              ),
              _ColorChip(
                name: 'Surface',
                color: colorScheme.surface,
                onColor: colorScheme.onSurface,
                hasBorder: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Status Kematangan (Semantik)
          Text(
            'Status Kematangan (Semantik + Ikon)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: _RipenessBadge(
                  label: 'Mentah',
                  icon: Icons.eco,
                  containerColor: ripeness.unripeContainer,
                  contentColor: ripeness.onUnripeContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _RipenessBadge(
                  label: 'Matang',
                  icon: Icons.check_circle_outline,
                  containerColor: ripeness.ripeContainer,
                  contentColor: ripeness.onRipeContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _RipenessBadge(
                  label: 'Lewat Matang',
                  icon: Icons.warning_amber_rounded,
                  containerColor: ripeness.overripeContainer,
                  contentColor: ripeness.onOverripeContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _RipenessBadge(
                  label: 'Busuk',
                  icon: Icons.cancel_outlined,
                  containerColor: ripeness.rottenContainer,
                  contentColor: ripeness.onRottenContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 3. Buttons & Target Sentuh (>= 48dp)
          Text(
            'Komponen Tombol (Min. 48dp)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Scan Buah'),
              ),
              FilledButton(
                onPressed: () {},
                child: const Text('Filled Action'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined Action'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 4. Kartu Informasi (Subtle, Anti-Slop)
          Text(
            'Kartu Informasi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Apel Fuji',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _RipenessBadge(
                        label: 'Matang',
                        icon: Icons.check_circle_outline,
                        containerColor: ripeness.ripeContainer,
                        contentColor: ripeness.onRipeContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Kalori 52 kkal per 100g. Kaya akan serat dan vitamin C. Cocok untuk konsumsi langsung atau campuran salad buah segar.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 5. Input Field
          Text(
            'Field Pencarian / Masukan',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Cari buah, nutrisi, atau resep...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.name,
    required this.color,
    required this.onColor,
    this.hasBorder = false,
  });

  final String name;
  final Color color;
  final Color onColor;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mdSm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.roundedMd,
        border: hasBorder
            ? Border.all(color: Theme.of(context).colorScheme.outlineVariant)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            name,
            style: TextStyle(
              color: onColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
            style: TextStyle(
              color: onColor.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RipenessBadge extends StatelessWidget {
  const _RipenessBadge({
    required this.label,
    required this.icon,
    required this.containerColor,
    required this.contentColor,
  });

  final String label;
  final IconData icon;
  final Color containerColor;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: AppRadius.roundedSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 14, color: contentColor),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: contentColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
