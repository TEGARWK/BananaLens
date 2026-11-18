import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'fruit_vector_icon.dart';
import 'soft_button.dart';

/// Hero Scan Card with direct camera and gallery actions.
class HomeHeroScanCard extends StatelessWidget {
  const HomeHeroScanCard({
    super.key,
    required this.onScanTap,
    required this.onGalleryTap,
  });

  final VoidCallback onScanTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundDecoration = isDark
        ? BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimens.rCard),
            border: Border.all(color: harvest.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          )
        : BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E9E5B), Color(0xFF1B6A3B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimens.rCard),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E9E5B).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          );

    final titleColor = isDark ? theme.colorScheme.onSurface : Colors.white;
    final subtitleColor = isDark
        ? harvest.muted
        : Colors.white.withValues(alpha: 0.88);

    return Container(
      decoration: backgroundDecoration,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -12,
            child: Transform.rotate(
              angle: -0.15,
              child: Opacity(
                opacity: isDark ? 0.35 : 0.85,
                child: const FruitVectorIcon(
                  fruitLabel: 'apple',
                  size: 115,
                  isCircular: false,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cek Kesegaran Buah',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.s8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    'Arahkan kamera ke buah untuk deteksi instan.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
                Row(
                  children: [
                    AccentButton(
                      text: 'Mulai Scan',
                      icon: Icons.camera_alt_rounded,
                      height: 48,
                      onPressed: onScanTap,
                    ),
                    const SizedBox(width: AppDimens.s8),
                    InkWell(
                      onTap: onGalleryTap,
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.s16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? harvest.primarySoft
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppDimens.rButton,
                          ),
                          border: Border.all(
                            color: isDark
                                ? harvest.border
                                : Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              color: isDark
                                  ? theme.colorScheme.primary
                                  : Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: AppDimens.s4),
                            Text(
                              'Galeri',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isDark
                                    ? theme.colorScheme.primary
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
