import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/qr_checkin_controller.dart';

class QrCheckInScreen extends StatefulWidget {
  const QrCheckInScreen({super.key});

  @override
  State<QrCheckInScreen> createState() => _QrCheckInScreenState();
}

class _QrCheckInScreenState extends State<QrCheckInScreen> {
  final QrCheckInController controller = Get.find<QrCheckInController>();
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _scannerStarted = true;
  bool _torchEnabled = false;

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  Future<void> _pauseScanner() async {
    if (!_scannerStarted) return;
    await scannerController.stop();
    if (mounted) {
      setState(() => _scannerStarted = false);
    }
  }

  Future<void> _resumeScanner() async {
    controller.resetScan();
    await scannerController.start();
    if (mounted) {
      setState(() => _scannerStarted = true);
    }
  }

  Future<void> _toggleTorch() async {
    await scannerController.toggleTorch();
    if (mounted) {
      setState(() => _torchEnabled = !_torchEnabled);
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'checked_in':
        return kGreen;
      case 'ready':
        return kBlue;
      case 'already_checked_in':
        return kGold;
      case 'not_confirmed':
        return kOrange;
      default:
        return kRed;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'checked_in':
        return PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone);
      case 'ready':
        return PhosphorIcons.qrCode(PhosphorIconsStyle.duotone);
      case 'already_checked_in':
        return PhosphorIcons.sealCheck(PhosphorIconsStyle.duotone);
      case 'not_confirmed':
        return PhosphorIcons.clockCountdown(PhosphorIconsStyle.duotone);
      default:
        return PhosphorIcons.warningCircle(PhosphorIconsStyle.duotone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: const Text(
          'Scanner réservation',
          style: TextStyle(
            color: kTextPrim,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: kBgCard,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: kCardShadow,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: MobileScanner(
                          controller: scannerController,
                          onDetect: (capture) async {
                            final code = capture.barcodes.first.rawValue;
                            if (code == null || code.isEmpty) return;
                            await _pauseScanner();
                            await controller.scanCode(code);
                          },
                        ),
                      ),
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _toggleTorch,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                _torchEnabled
                                    ? PhosphorIcons.flashlight(
                                        PhosphorIconsStyle.fill,
                                      )
                                    : PhosphorIcons.flashlight(
                                        PhosphorIconsStyle.duotone,
                                      ),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Cadrez le QR de la réservation pour vérifier la présence du joueur.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 18),
              Expanded(
                child: Obx(() {
                  final resultStatus = controller.status.value;
                  final reservation = controller.reservation.value;
                  final resultColor = _statusColor(resultStatus);
                  final canConfirm =
                      resultStatus == 'ready' && reservation != null;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kBgCard,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: kCardShadow,
                    ),
                    child: controller.isProcessing.value
                        ? const Center(
                            child: CircularProgressIndicator(color: kGreen),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: resultColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      _statusIcon(resultStatus),
                                      color: resultColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      controller.message.value.isEmpty
                                          ? 'Prêt à scanner'
                                          : controller.message.value,
                                      style: const TextStyle(
                                        color: kTextPrim,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (reservation != null) ...[
                                const SizedBox(height: 18),
                                _InfoRow(
                                  label: 'Client',
                                  value:
                                      reservation['clientName']?.toString() ??
                                      'Client MiniFoot',
                                ),
                                _InfoRow(
                                  label: 'Terrain',
                                  value:
                                      reservation['subTerrainName']
                                              ?.toString()
                                              .isNotEmpty ==
                                          true
                                      ? '${reservation['terrainName']} • ${reservation['subTerrainName']}'
                                      : reservation['terrainName']
                                                ?.toString() ??
                                            '',
                                ),
                                _InfoRow(
                                  label: 'Créneau',
                                  value:
                                      '${_formatDate(reservation['date'])} • ${reservation['startSlot']} - ${reservation['endSlot']}',
                                ),
                                _InfoRow(
                                  label: 'Référence',
                                  value:
                                      reservation['reference']?.toString() ??
                                      '',
                                ),
                                if (reservation['checkedInAt'] != null)
                                  _InfoRow(
                                    label: 'Déjà pointée',
                                    value: _formatDate(
                                      reservation['checkedInAt'],
                                    ),
                                  ),
                              ] else ...[
                                const Spacer(),
                                const Text(
                                  'Scannez un QR code pour voir les détails de la réservation avant confirmation.',
                                  style: TextStyle(
                                    color: kTextLight,
                                    fontSize: 13,
                                    height: 1.45,
                                  ),
                                ),
                                const Spacer(),
                              ],
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _resumeScanner,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: kGreen),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Rescanner',
                                        style: TextStyle(
                                          color: kGreen,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: canConfirm
                                          ? controller.isConfirming.value
                                                ? null
                                                : controller.confirmCheckIn
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kGreen,
                                        disabledBackgroundColor: kGreenLight,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: controller.isConfirming.value
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Confirmer',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ).animate().fadeIn(duration: 400.ms, delay: 120.ms);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: kTextLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: kTextPrim,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
