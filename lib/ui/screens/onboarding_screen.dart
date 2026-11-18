import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';
import 'package:fruitlens/ui/widgets/onboarding_slide_content.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key tracking whether the user has completed onboarding.
const String kOnboardingSeenKey = 'fruitlens_onboarding_seen';

final onboardingSeenProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(kOnboardingSeenKey) ?? false;
});

/// Screen showcasing 3 illustrated slides introducing FruitLens capabilities.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingSlideData> _slides = <OnboardingSlideData>[
    OnboardingSlideData(
      eyebrow: 'PEMINDAI HYBRID AI',
      title: 'Deteksi Kematangan Seketika',
      description:
          'Potret atau pilih foto buah dari galeri. AI kami mengenali jenis dan 4 tingkat kematangan buahmu dalam hitungan detik.',
      imagePath: 'assets/images/onboarding/slide_scan.png',
      fallbackIcon: Icons.center_focus_strong_rounded,
    ),
    OnboardingSlideData(
      eyebrow: 'NUTRISI & KEAMANAN',
      title: 'Pantau Gizi & Peringatan Alergi',
      description:
          'Lihat takaran kalori, serat, gula, serta peringatan alergi otomatis sesuai profil kesehatanmu.',
      imagePath: 'assets/images/onboarding/slide_nutrition.png',
      fallbackIcon: Icons.health_and_safety_rounded,
    ),
    OnboardingSlideData(
      eyebrow: 'ASISTEN KULINER PINTAR',
      title: 'Ide Resep & Asisten AI',
      description:
          'Tanyakan tips penyimpanan agar buah tetap awet dan temukan ide olahan lezat sesuai kematangannya.',
      imagePath: 'assets/images/onboarding/slide_assistant.png',
      fallbackIcon: Icons.auto_awesome_rounded,
    ),
  ];

  Future<void> _completeOnboarding({String destination = '/auth'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingSeenKey, true);
    if (mounted) {
      context.go(destination);
    }
  }

  void _finishGuide() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _handleNextOrStart(bool isLoggedIn) {
    if (_currentPage == _slides.length - 1) {
      if (isLoggedIn) {
        _finishGuide();
      } else {
        _completeOnboarding(destination: '/auth?mode=register');
      }
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _slides.length - 1;
    final isLoggedIn = ref.watch(authNotifierProvider).asData?.value != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: isLoggedIn && context.canPop()
            ? IconButton(
                tooltip: 'Kembali',
                onPressed: _finishGuide,
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const IndustrialBananaMark(size: 28),
            const SizedBox(width: AppDimens.s8),
            Text(
              isLoggedIn ? 'Panduan Penggunaan' : AppStrings.appName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          if (!isLast)
            TextButton(
              onPressed: isLoggedIn
                  ? _finishGuide
                  : () => _completeOnboarding(),
              child: Text(
                isLoggedIn ? 'Tutup' : 'Lewati',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: context.harvest.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (int page) =>
                    setState(() => _currentPage = page),
                itemBuilder: (_, int i) =>
                    OnboardingSlidePage(slide: _slides[i]),
              ),
            ),
            OnboardingBottomBar(
              slideCount: _slides.length,
              currentIndex: _currentPage,
              isLoggedIn: isLoggedIn,
              onNextOrStart: () => _handleNextOrStart(isLoggedIn),
              onGoToAuth: () => _completeOnboarding(destination: '/auth'),
            ),
          ],
        ),
      ),
    );
  }
}
