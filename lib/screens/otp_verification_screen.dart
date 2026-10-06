import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import 'create_password_screen.dart';

enum OtpFlow { signup, forgotPassword }

class OtpVerificationScreen extends StatefulWidget {
  final String? fullName;
  final String identifier;
  final OtpFlow flow;

  const OtpVerificationScreen({
    super.key,
    this.fullName,
    required this.identifier,
    required this.flow,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _digitControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _handleResendOtp() {
    if (!_canResend) return;

    final newCode = AuthService().generateOtp(widget.identifier);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New OTP sent to ${widget.identifier}: $newCode'),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 6),
      ),
    );

    _clearDigits();
    setState(() {
      _errorMessage = null;
    });
    _startCountdown();
  }

  void _clearDigits() {
    for (var controller in _digitControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  String _getEnteredOtp() {
    return _digitControllers.map((c) => c.text).join();
  }

  void _handleVerifyOtp() {
    setState(() {
      _errorMessage = null;
    });

    final otpEntered = _getEnteredOtp();
    if (otpEntered.length < 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the OTP.';
      });
      return;
    }

    final result = AuthService().verifyOtp(widget.identifier, otpEntered);

    if (result == OtpVerificationResult.expired) {
      setState(() {
        _errorMessage = 'OTP expired. Please request a new OTP.';
      });
      return;
    }

    if (result == OtpVerificationResult.incorrect) {
      setState(() {
        _errorMessage = 'Incorrect OTP. Please re-enter the OTP.';
      });
      return;
    }

    // Success -> Navigate to Create Password Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePasswordScreen(
          fullName: widget.fullName,
          identifier: widget.identifier,
          flow: widget.flow,
        ),
      ),
    );
  }

  String _formatMaskedIdentifier(String id) {
    if (AuthService.isEmailIdentifier(id)) {
      return id;
    } else if (id.length >= 10) {
      final masked = '*' * (id.length - 4) + id.substring(id.length - 4);
      return masked;
    }
    return id;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _digitControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: LoginBackgroundPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Nav Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Container(
                        width: size.width > 420 ? 380 : size.width * 0.9,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFDE5D53),
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Verify your account',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'We sent a verification code to:\n${_formatMaskedIdentifier(widget.identifier)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 6 Individual Digit Boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: 44,
                                  height: 52,
                                  child: TextField(
                                    controller: _digitControllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: const Color(0xFFF2F2F2),
                                      contentPadding: EdgeInsets.zero,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFCCCCCC),
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: AppColors.vanRed,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        if (index < 5) {
                                          _focusNodes[index + 1].requestFocus();
                                        } else {
                                          _focusNodes[index].unfocus();
                                        }
                                      } else {
                                        if (index > 0) {
                                          _focusNodes[index - 1].requestFocus();
                                        }
                                      }
                                    },
                                  ),
                                );
                              }),
                            ),

                            // Red Error Display
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade300),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Verify OTP Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _handleVerifyOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C3240),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  'VERIFY OTP',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Timer & Resend OTP Option
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _canResend
                                      ? 'Resend available'
                                      : 'Resend in ${_secondsRemaining}s',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _canResend ? Colors.green : Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _canResend ? _handleResendOtp : null,
                                  child: Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _canResend ? AppColors.vanRed : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 20),

                            // Change email/mobile option
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Change email/mobile number',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textDark,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
