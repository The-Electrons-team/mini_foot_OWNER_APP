import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

class PaymentMethodsScreen extends GetView<ProfileController> {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: kTextPrim,
        ),
        title: const Text(
          'Reversements',
          style: TextStyle(
            color: kTextPrim,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
          children: [
            _buildIntro(),
            const SizedBox(height: 14),
            _PayoutMethodCard(
              title: 'Wave',
              subtitle: 'Numéro de réception Wave',
              color: const Color(0xFF00B0F0),
              bgColor: kBlueLight,
              method: 'WAVE',
              controller: controller.wavePhoneCtrl,
              selected: controller.preferredPayoutMethod.value == 'WAVE',
              onSelect: controller.selectPreferredPayoutMethod,
            ),
            const SizedBox(height: 12),
            _PayoutMethodCard(
              title: 'Orange Money',
              subtitle: 'Numéro Orange Money',
              color: kOrange,
              bgColor: const Color(0xFFFFF3E0),
              method: 'ORANGE_MONEY',
              controller: controller.orangePhoneCtrl,
              selected:
                  controller.preferredPayoutMethod.value == 'ORANGE_MONEY',
              onSelect: controller.selectPreferredPayoutMethod,
            ),
            const SizedBox(height: 12),
            _PayoutMethodCard(
              title: 'Yas Money',
              subtitle: 'Numéro Yas / Free Money',
              color: kGold,
              bgColor: kGoldLight,
              method: 'FREE_MONEY',
              controller: controller.freePhoneCtrl,
              selected: controller.preferredPayoutMethod.value == 'FREE_MONEY',
              onSelect: controller.selectPreferredPayoutMethod,
            ),
            const SizedBox(height: 18),
            _buildNotice(),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: controller.isSavingPayout.value
                    ? null
                    : controller.savePayoutInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kGreen.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: controller.isSavingPayout.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Enregistrer les coordonnées',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kGreenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: kGreen,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coordonnées de paiement',
                  style: TextStyle(
                    color: kTextPrim,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ces numéros serviront plus tard à orienter vos reversements.',
                  style: TextStyle(color: kTextSub, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBlueLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: kBlue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vous pouvez renseigner un ou plusieurs numéros. Sélectionnez la méthode préférée pour vos futurs reversements.',
              style: TextStyle(
                color: kBlue,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final String method;
  final TextEditingController controller;
  final bool selected;
  final ValueChanged<String> onSelect;

  const _PayoutMethodCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.method,
    required this.controller,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
        border: selected
            ? Border.all(color: color.withValues(alpha: 0.45), width: 1.4)
            : Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.phone_iphone_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: kTextPrim,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: kTextSub, fontSize: 12),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => onSelect(method),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? bgColor : kBgSurface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 15,
                        color: selected ? color : kTextLight,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        selected ? 'Préféré' : 'Choisir',
                        style: TextStyle(
                          color: selected ? color : kTextSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            decoration: InputDecoration(
              hintText: '77 000 00 00',
              prefixText: '+221 ',
              prefixStyle: const TextStyle(
                color: kTextPrim,
                fontWeight: FontWeight.w800,
              ),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: controller.clear,
                      icon: const Icon(Icons.close_rounded, color: kTextLight),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
