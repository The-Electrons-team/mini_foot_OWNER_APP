import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 30;
  bool _canResend = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSeconds--);
      if (_resendSeconds <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  void _onDigit(String val, int index) {
    if (val.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _errorMessage = null);

    // Auto-valider quand les 6 cases sont remplies
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      Future.delayed(const Duration(milliseconds: 200), _validate);
    }
  }

  Future<void> _validate() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Saisis les 6 chiffres du code');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simule appel API
    if (!mounted) return;
    setState(() => _isLoading = false);
    Get.offAllNamed(Routes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              PhosphorIcons.arrowLeft(PhosphorIconsStyle.duotone),
              color: kTextPrim,
              size: 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Icone
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kGreenLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.deviceMobile(PhosphorIconsStyle.duotone),
                  color: kGreen,
                  size: 36,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 28),

              const Text(
                'Verification OTP',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kTextPrim,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 10),

              Text(
                'Code envoye au\n\u{1F1F8}\u{1F1F3} +221 ${widget.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextSub,
                  fontSize: 14,
                  height: 1.6,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

              const SizedBox(height: 40),

              // 6 cases OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Container(
                    width: 48,
                    height: 58,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: kGreen,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: kBgSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: kBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: kGreen, width: 2),
                        ),
                      ),
                      onChanged: (val) => _onDigit(val, i),
                    ),
                  );
                }),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              // Erreur
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: kRed, fontSize: 13),
                ),
              ],

              const SizedBox(height: 36),

              // Bouton valider
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kGreen.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
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
                              'Valider le code',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone),
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Renvoyer
              GestureDetector(
                onTap: _canResend ? _startCountdown : null,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: _canResend ? kGreen : kTextLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    decoration: _canResend ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: kGreen,
                  ),
                  child: Text(
                    _canResend
                        ? 'Renvoyer le code'
                        : 'Renvoyer dans $_resendSeconds s',
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
