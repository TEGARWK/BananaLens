import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// Clean 60-30-10 Editorial Bottom Navigation Bar with an integrated
/// center Scan FloatingActionButton.
///
/// - Uses flat surface + 1px warm sand hairline (no hard brutalist shadows).
/// - Hides cleanly when the software keyboard is open.
class MainScaffoldWithNav extends StatelessWidget {
  const MainScaffoldWithNav({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final currentIndex = navigationShell.currentIndex;
    final isDark = theme.brightness == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final isScanActive = currentIndex == 2;

    final scanBg = isScanActive
        ? (isDark ? theme.colorScheme.primary : AppColors.lSurfaceDark)
        : theme.colorScheme.primary;
    final scanFg = isScanActive
        ? (isDark ? theme.colorScheme.onPrimary : AppColors.lPrimary)
        : theme.colorScheme.onPrimary;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: navigationShell,
      bottomNavigationBar: isKeyboardOpen
          ? null
          : Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: harvest.border, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 66,
                  child: Row(
                    children: [
                      // Kiri 1: Beranda (Branch 0)
                      Expanded(
                        child: _NavTabItem(
                          icon: Icons.cottage_outlined,
                          activeIcon: Icons.cottage_rounded,
                          label: AppStrings.navHome,
                          isSelected: currentIndex == 0,
                          onTap: () => _onDestinationSelected(0),
                        ),
                      ),
                      // Kiri 2: Tanya AI (Branch 1)
                      Expanded(
                        child: _NavTabItem(
                          icon: Icons.auto_awesome_outlined,
                          activeIcon: Icons.auto_awesome_rounded,
                          label: AppStrings.navChat,
                          isSelected: currentIndex == 1,
                          onTap: () => _onDestinationSelected(1),
                        ),
                      ),
                      // Tengah: Tombol Scan FAB (Branch 2)
                      SizedBox(
                        width: 68,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isScanActive
                                  ? Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: FloatingActionButton(
                              onPressed: () => _onDestinationSelected(2),
                              elevation: 0,
                              highlightElevation: 0,
                              backgroundColor: scanBg,
                              foregroundColor: scanFg,
                              shape: const CircleBorder(),
                              tooltip: AppStrings.navScan,
                              child: const Icon(
                                Icons.center_focus_strong_rounded,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Kanan 1: Riwayat (Branch 3)
                      Expanded(
                        child: _NavTabItem(
                          icon: Icons.history_rounded,
                          activeIcon: Icons.history_rounded,
                          label: AppStrings.navHistory,
                          isSelected: currentIndex == 3,
                          onTap: () => _onDestinationSelected(3),
                        ),
                      ),
                      // Kanan 2: Profil (Branch 4)
                      Expanded(
                        child: _NavTabItem(
                          icon: Icons.person_outline_rounded,
                          activeIcon: Icons.person_rounded,
                          label: AppStrings.navProfile,
                          isSelected: currentIndex == 4,
                          onTap: () => _onDestinationSelected(4),
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

class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final color = isSelected ? ink : harvest.muted;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? harvest.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.rButton),
            ),
            child: Icon(isSelected ? activeIcon : icon, color: color, size: 20),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
