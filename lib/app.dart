import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/router/app_router.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/core/theme/theme_controller.dart';
import 'package:fruitlens/ui/screens/splash_screen.dart';

/// Root application widget wired to [GoRouter] and [AppTheme].
class FruitLensApp extends ConsumerWidget {
  const FruitLensApp({this.enableSplash = false, super.key});

  /// Shows the animated brand launch splash overlay on cold app start.
  final bool enableSplash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: enableSplash
          ? (context, child) =>
                _SplashOverlayGate(child: child ?? const SizedBox.shrink())
          : null,
    );
  }
}

class _SplashOverlayGate extends StatefulWidget {
  const _SplashOverlayGate({required this.child});

  final Widget child;

  @override
  State<_SplashOverlayGate> createState() => _SplashOverlayGateState();
}

class _SplashOverlayGateState extends State<_SplashOverlayGate> {
  bool _fadingOut = false;
  bool _dismissed = false;

  void _startFadeOut() {
    if (!mounted || _fadingOut) return;
    setState(() => _fadingOut = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _fadingOut,
            child: AnimatedOpacity(
              opacity: _fadingOut ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOut,
              onEnd: () {
                if (_fadingOut && mounted) {
                  setState(() => _dismissed = true);
                }
              },
              child: SplashScreen(onCompleted: _startFadeOut),
            ),
          ),
        ),
      ],
    );
  }
}
