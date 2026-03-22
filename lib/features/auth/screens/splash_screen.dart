import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _loadingCtrl;

  late Animation<double> _bgExpand;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _loadingFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // ── Background circle expand ──
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bgExpand = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOutCubic),
    );

    // ── Logo fade + elastic scale ──
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    // ── Text animations ──
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Shimmer effect on logo ──
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // ── Loading animation ──
    _loadingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingCtrl, curve: Curves.easeOut),
    );

    // Start animation sequence
    _bgCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _textCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _loadingCtrl.forward();
    });

    // Navigate after 3.5s
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) Get.offNamed(Routes.onboarding);
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _shimmerCtrl.dispose();
    _loadingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxRadius = size.height * 1.2;

    return Scaffold(
      backgroundColor: kGreen,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF008C47),
                  Color(0xFF006F39),
                  Color(0xFF005A2E),
                ],
              ),
            ),
          ),

          // ── Expanding circle from center ──
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, _) => Center(
              child: Container(
                width: maxRadius * _bgExpand.value,
                height: maxRadius * _bgExpand.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
          ),

          // ── Decorative pattern (subtle circles) ──
          Positioned.fill(
            child: CustomPaint(
              painter: _SplashPatternPainter(),
            ),
          ),

          // ── Decorative floating shapes ──
          Positioned(
            top: size.height * 0.08,
            right: -30,
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, _) => Opacity(
                opacity: _bgExpand.value * 0.08,
                child: Transform.rotate(
                  angle: math.pi / 6,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.12,
            left: -20,
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, _) => Opacity(
                opacity: _bgExpand.value * 0.06,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Lottie football animation ──
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _logoFade.value,
                    child: Lottie.asset(
                      'assets/lottie/football_bounce.json',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Logo with glow ──
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.25),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/images/minifoot.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Title: MINIFOOT ──
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, _) => SlideTransition(
                    position: _textSlide,
                    child: Opacity(
                      opacity: _textFade.value,
                      child: const Text(
                        'MINIFOOT',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          letterSpacing: 5,
                          shadows: [
                            Shadow(
                              color: Color(0x40000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Subtitle badge ──
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, _) => SlideTransition(
                    position: _subtitleSlide,
                    child: Opacity(
                      opacity: _subtitleFade.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          'ESPACE PROPRIÉTAIRE',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 56),

                // ── Loading indicator ──
                AnimatedBuilder(
                  animation: _loadingCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _loadingFade.value,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 180,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chargement...',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Version at bottom ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: AnimatedBuilder(
              animation: _loadingCtrl,
              builder: (_, _) => Opacity(
                opacity: _loadingFade.value * 0.5,
                child: const Text(
                  'v1.2.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtle decorative pattern ──────────────────────────────────────────────

class _SplashPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 50.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final offset = (y ~/ spacing).isOdd ? spacing / 2 : 0.0;
        canvas.drawCircle(Offset(x + offset, y), 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
