import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// Fresh Harvest / Night Harvest Bottom Navigation Bar with an integrated
/// center FloatingActionButton that sits cleanly inside the bar.
///
/// Fixes:
/// 1. Center scan FAB does not protrude upward into the chat input field.
/// 2. Hides navigation bar cleanly when the software keyboard appears so it
///    does not float above the keyboard or push the chat input awkwardly high.
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
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 64,
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
                      // Tengah: Tombol Scan FAB (Branch 2) terintegrasi rapi di dalam bar
                      SizedBox(
                        width: 68,
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.onSurface,
                                  offset: const Offset(0, 2.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: FloatingActionButton(
                              onPressed: () => _onDestinationSelected(2),
                              elevation: 0,
                              highlightElevation: 0,
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.rSharp),
              border: isSelected ? Border.all(color: ink, width: 1.2) : null,
            ),
            child: Icon(isSelected ? activeIcon : icon, color: color, size: 20),
          ),
          const SizedBox(height: 2),
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
