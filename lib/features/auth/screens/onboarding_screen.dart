import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      imagePath: 'assets/images/terrain.webp',
      title: 'Gérez vos terrains',
      subtitle:
          'Ajoutez et configurez vos terrains de foot en quelques clics. Horaires, tarifs, réservations — tout est centralisé.',
      imageType: _ImageType.terrain,
    ),
    _Slide(
      imagePath: 'assets/images/minifoot.png',
      title: 'Suivez vos revenus',
      subtitle:
          'Visualisez vos performances financières en temps réel avec des statistiques claires et détaillées.',
      imageType: _ImageType.logo,
    ),
    _Slide(
      imagePath: 'assets/images/ballon.png',
      title: 'Tout au même endroit',
      subtitle:
          'Une plateforme unique pour gérer vos terrains, réservations, paiements et communications.',
      imageType: _ImageType.ball,
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offNamed(Routes.login);
    }
  }

  void _skip() => Get.offNamed(Routes.login);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button top-right ──
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 28),
                child: _page < _slides.length - 1
                    ? GestureDetector(
                        onTap: _skip,
                        child: const Text(
                          'Passer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kTextSub,
                          ),
                        ),
                      )
                    : const SizedBox(height: 20),
              ),
            ),

            // ── PageView ──
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlidePage(
                  slide: _slides[i],
                  screenHeight: size.height,
                ),
              ),
            ),

            // ── Dot indicators (smooth_page_indicator) ──
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: SmoothPageIndicator(
                controller: _ctrl,
                count: _slides.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: kGreen,
                  dotColor: kBorder,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3.5,
                  spacing: 6,
                ),
              ),
            ),

            // ── Main button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _page < _slides.length - 1 ? 'Suivant' : 'Commencer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ─── Image type enum ────────────────────────────────────────────────────────

enum _ImageType { terrain, logo, ball }

// ─── Data Model ─────────────────────────────────────────────────────────────

class _Slide {
  final String imagePath;
  final String title;
  final String subtitle;
  final _ImageType imageType;

  const _Slide({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.imageType,
  });
}

// ─── Slide Page Widget ──────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  final double screenHeight;

  const _SlidePage({required this.slide, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // ── Image area (top ~55%) ──
          SizedBox(
            height: screenHeight * 0.45,
            child: Center(
              child: _buildImageArea(),
            ),
          ),

          const SizedBox(height: 32),

          // ── Title ──
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kTextPrim,
              height: 1.3,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 16),

          // ── Subtitle ──
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: kTextSub,
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    switch (slide.imageType) {
      case _ImageType.terrain:
        // Terrain photo in a rounded container with green overlay
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Image.asset(
                slide.imagePath,
                width: double.infinity,
                height: screenHeight * 0.38,
                fit: BoxFit.cover,
              ),
              // Green gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        kGreen.withValues(alpha: 0.15),
                        kGreen.withValues(alpha: 0.40),
                      ],
                    ),
                  ),
                ),
              ),
              // Small icon badge in corner
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.stadium_rounded,
                    color: kGreen,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms);

      case _ImageType.logo:
        // Minifoot logo centered with decorative background
        return Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kGreenLight,
            boxShadow: [
              BoxShadow(
                color: kGreen.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              slide.imagePath,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms);

      case _ImageType.ball:
        // Animation Lottie du ballon qui rebondit
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer decorative ring
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: kGreen.withValues(alpha: 0.12),
                  width: 2,
                ),
              ),
            ),
            // Inner circle background
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGreenLight,
                boxShadow: [
                  BoxShadow(
                    color: kGreen.withValues(alpha: 0.10),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Lottie animation
            Lottie.asset(
              'assets/lottie/football_bounce.json',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms);
    }
  }
}
