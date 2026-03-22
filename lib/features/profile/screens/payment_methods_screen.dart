import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

class PaymentMethodsScreen extends GetView<ProfileController> {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBgCard,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kTextPrim, size: 18),
          ),
        ),
        title: const Text(
          'Methodes de paiement',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kBlueLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.wallet(PhosphorIconsStyle.duotone),
                    color: kBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Gerez vos methodes de paiement pour recevoir vos revenus de reservations.',
                      style: TextStyle(
                        fontSize: 13,
                        color: kBlue,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 24),

            // Payment methods
            _buildPaymentCard(
              name: 'Wave',
              number: '**** **** **** 1234',
              color: kBlue,
              bgColor: kBlueLight,
              icon: PhosphorIcons.waves(PhosphorIconsStyle.duotone),
              isDefault: true,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: 14),

            _buildPaymentCard(
              name: 'Orange Money',
              number: '**** **** **** 5678',
              color: kOrange,
              bgColor: const Color(0xFFFFF3E0),
              icon: PhosphorIcons.phone(PhosphorIconsStyle.duotone),
              isDefault: false,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 350.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: 14),

            _buildPaymentCard(
              name: 'Free Money',
              number: '**** **** **** 9012',
              color: kGreen,
              bgColor: kGreenLight,
              icon: PhosphorIcons.money(PhosphorIconsStyle.duotone),
              isDefault: false,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: 28),

            // Add method button
            _buildAddMethodButton()
                .animate()
                .fadeIn(duration: 400.ms, delay: 650.ms)
                .slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required String name,
    required String number,
    required Color color,
    required Color bgColor,
    required IconData icon,
    required bool isDefault,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
        border: isDefault
            ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          // Method icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          // Method info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kTextPrim,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.checkCircle(
                                  PhosphorIconsStyle.duotone),
                              color: color,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Par defaut',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 14,
                    color: kTextSub,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Delete icon
          GestureDetector(
            onTap: () {
              Get.dialog(
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: kBgCard,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: kElevatedShadow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: kRedLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            PhosphorIcons.trash(PhosphorIconsStyle.duotone),
                            color: kRed,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Supprimer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: kTextPrim,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Voulez-vous supprimer $name ?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: kTextSub,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: Get.back,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: kBorder, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Annuler',
                                    style: TextStyle(
                                      color: kTextSub,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.snackbar(
                                      'Supprime',
                                      '$name a ete supprime',
                                      backgroundColor: kRed,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: 14,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kRed,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Supprimer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                barrierDismissible: true,
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kBgSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                PhosphorIcons.trash(PhosphorIconsStyle.duotone),
                color: kTextLight,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMethodButton() {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Bientot disponible',
          'L\'ajout de methode de paiement sera disponible prochainement',
          backgroundColor: kGold,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
        );
      },
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: kBorder,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: CustomPaint(
          painter: _DottedBorderPainter(),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kGreenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIcons.plus(PhosphorIconsStyle.duotone),
                    color: kGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Ajouter une methode',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kGreen,
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

class _DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 8.0;
    const dashSpace = 5.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(18),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0, metric.length);
        canvas.drawPath(
          metric.extractPath(start, end.toDouble()),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
