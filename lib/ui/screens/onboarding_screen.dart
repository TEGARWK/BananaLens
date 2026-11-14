import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
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
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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

  void _handleNextOrStart() {
    if (_currentPage == _slides.length - 1) {
      _completeOnboarding(destination: '/auth?mode=register');
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.eco_rounded, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: AppDimens.s8),
            Text(
              'FruitLens',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          if (!isLast)
            TextButton(
              onPressed: () => _completeOnboarding(),
              child: Text(
                'Lewati',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: context.harvest.muted,
                  fontWeight: FontWeight.w600,
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
              onNextOrStart: _handleNextOrStart,
              onGoToAuth: () => _completeOnboarding(destination: '/auth'),
            ),
          ],
        ),
      ),
    );
  }
}
