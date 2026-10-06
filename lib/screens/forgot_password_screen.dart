import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _identifierController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  void _handleSendOtp() {
    setState(() {
      _errorMessage = null;
    });

    final input = _identifierController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your registered Email address or Mobile number.';
      });
      return;
    }

    if (!AuthService().userExists(input)) {
      setState(() {
        _errorMessage = 'Account with this email/mobile does not exist.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final otpCode = AuthService().generateOtp(input);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password Reset OTP sent to $input: $otpCode'),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 6),
      ),
    );

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          identifier: input,
          flow: OtpFlow.forgotPassword,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Forgot Password',
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
                              'Reset Your Password',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Enter your registered Email or Mobile number. We will send you a verification code to reset your password.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Registered Email or Mobile Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF757575),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _identifierController,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  border: InputBorder.none,
                                  hintText: 'e.g. user@travel.com or 9876543210',
                                  hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                                  prefixIcon: Icon(Icons.lock_reset, color: Colors.white70),
                                ),
                              ),
                            ),

                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
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
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C3240),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Send Verification OTP',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color: AppColors.vanRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
