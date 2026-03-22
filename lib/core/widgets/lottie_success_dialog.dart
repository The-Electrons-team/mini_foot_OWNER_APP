import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

/// Affiche un dialog avec animation Lottie de succes
/// Utilise : Get.dialog(LottieSuccessDialog(message: 'Reservation confirmee !'));
class LottieSuccessDialog extends StatelessWidget {
  final String message;
  final String? subtitle;
  final Duration autoClose;

  const LottieSuccessDialog({
    super.key,
    required this.message,
    this.subtitle,
    this.autoClose = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    // Auto-fermeture apres le delai
    Future.delayed(autoClose, () {
      if (Get.isDialogOpen ?? false) Get.back();
    });

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: kElevatedShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/success_check.json',
              width: 100,
              height: 100,
              repeat: false,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextPrim,
                decoration: TextDecoration.none,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: kTextSub,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
