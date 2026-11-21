import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import 'industrial_art.dart';

/// Hero Scan Card with direct camera and gallery actions in BananaLens Industrial style.
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
    final isDark = theme.brightness == Brightness.dark;
    final ink = theme.colorScheme.onSurface;
    final cardBg = isDark
        ? theme.colorScheme.surface
        : theme.colorScheme.primary;
    final textInk = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppDimens.rCard),
        border: Border.all(color: ink, width: 1.8),
        boxShadow: [BoxShadow(color: ink, offset: const Offset(4, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: 8,
            child: Transform.rotate(
              angle: -0.18,
              child: Opacity(
                opacity: isDark ? 0.22 : 0.25,
                child: const IndustrialBananaMark(size: 112),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.primary
                        : const Color(0xFF181A16),
                    borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  ),
                  child: Text(
                    'DETEKSI INSTAN // AI',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? theme.colorScheme.onPrimary
                          : const Color(0xFFF5D51E),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.s12),
                Text(
                  'Pindai Pisang',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: textInk,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppDimens.s4),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Text(
                    'Cek kematangan & saran olahan secara instan.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textInk.withValues(alpha: 0.82),
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
                Row(
                  children: [
                    Material(
                      color: isDark
                          ? theme.colorScheme.primary
                          : const Color(0xFF181A16),
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      child: InkWell(
                        onTap: onScanTap,
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.s16,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: isDark
                                    ? theme.colorScheme.onPrimary
                                    : const Color(0xFFF5D51E),
                                size: 18,
                              ),
                              const SizedBox(width: AppDimens.s8),
                              Text(
                                'Mulai Scan',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: isDark
                                      ? theme.colorScheme.onPrimary
                                      : const Color(0xFFF5D51E),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Material(
                      color: isDark
                          ? const Color(0xFF282B22)
                          : const Color(0xFFF5F6F1),
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      child: InkWell(
                        onTap: onGalleryTap,
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.s16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppDimens.rButton,
                            ),
                            border: Border.all(color: ink, width: 1.4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                color: ink,
                                size: 18,
                              ),
                              const SizedBox(width: AppDimens.s4),
                              Text(
                                'Galeri',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
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
