import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Green Header with Logo ──────────────────────────────────
            _buildHeader(),

            // ── Form Card (overlaps header) ─────────────────────────────
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                  decoration: BoxDecoration(
                    color: kBgCard,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: kElevatedShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Greeting ──
                      const Text(
                        'Bon retour !',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: kTextPrim,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 6),
                      const Text(
                        'Connectez-vous pour g\u00e9rer vos terrains',
                        style: TextStyle(
                          fontSize: 14,
                          color: kTextSub,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 28),

                      // ── Email Field ──
                      const _Label('Adresse email'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: kTextPrim, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'votre@email.com',
                          prefixIcon: Icon(
                            PhosphorIcons.envelope(PhosphorIconsStyle.duotone),
                            color: kTextLight,
                            size: 20,
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.15, end: 0),

                      const SizedBox(height: 20),

                      // ── Password Field ──
                      const _Label('Mot de passe'),
                      const SizedBox(height: 8),
                      Obx(() => TextField(
                            controller: passCtrl,
                            obscureText: controller.obscurePass.value,
                            style: const TextStyle(color: kTextPrim, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                              prefixIcon: Icon(
                                PhosphorIcons.lock(PhosphorIconsStyle.duotone),
                                color: kTextLight,
                                size: 20,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: controller.toggleObscure,
                                child: Icon(
                                  controller.obscurePass.value
                                      ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.duotone)
                                      : PhosphorIcons.eye(PhosphorIconsStyle.duotone),
                                  color: kTextLight,
                                  size: 20,
                                ),
                              ),
                            ),
                          )).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.15, end: 0),

                      const SizedBox(height: 12),

                      // ── Forgot Password ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: forgot password
                          },
                          child: const Text(
                            'Mot de passe oubli\u00e9 ?',
                            style: TextStyle(
                              fontSize: 13,
                              color: kGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                      const SizedBox(height: 28),

                      // ── Login Button ──
                      Obx(() => SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.login(emailCtrl.text, passCtrl.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kGreen,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: kGreen.withValues(alpha: 0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Se connecter',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          PhosphorIcons.signIn(PhosphorIconsStyle.duotone),
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          )).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // ── Divider "ou continuer avec" ──
                      Row(
                        children: [
                          const Expanded(child: Divider(color: kBorder)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ou continuer avec',
                              style: TextStyle(
                                fontSize: 13,
                                color: kTextLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: kBorder)),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

                      const SizedBox(height: 20),

                      // ── Google Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Google sign-in
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.googleLogo(PhosphorIconsStyle.duotone),
                                size: 22,
                                color: kTextPrim,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Google',
                                style: TextStyle(
                                  color: kTextPrim,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Register Link ──
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pas encore de compte ? ',
                    style: TextStyle(color: kTextSub, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: controller.goToRegister,
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(
                        color: kGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 550.ms),
          ],
        ),
      ),
    );
  }

  /// Construit le header vert courbe avec logo et nom de marque
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 60),
      decoration: const BoxDecoration(
        gradient: kGreenGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // ── Logo dans un cercle blanc ──
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/minifoot.png',
                width: 48,
                height: 48,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(height: 14),

          // ── Nom de la marque ──
          const Text(
            'MINIFOOT',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

          const SizedBox(height: 4),

          Text(
            'ESPACE PROPRI\u00c9TAIRE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 3,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
        ],
      ),
    );
  }
}

// ─── Label Widget ───────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: kTextSub,
        ),
      );
}
