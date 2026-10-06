import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  void _handleSendOtp() {
    setState(() {
      _errorMessage = null;
    });

    final fullName = _fullNameController.text.trim();
    final input = _identifierController.text.trim();

    if (fullName.isEmpty || fullName.length < 2 || !RegExp(r'[a-zA-Z]').hasMatch(fullName)) {
      setState(() {
        _errorMessage = 'Please enter your full name.';
      });
      return;
    }

    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an Email address or Mobile number';
      });
      return;
    }

    final isEmail = AuthService.isEmailIdentifier(input);
    if (isEmail) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input)) {
        setState(() {
          _errorMessage = 'Please enter a valid email address';
        });
        return;
      }
    } else {
      if (!RegExp(r'^[0-9]{10}$').hasMatch(input)) {
        setState(() {
          _errorMessage = 'Please enter a valid 10-digit mobile number';
        });
        return;
      }
    }

    if (AuthService().userExists(input)) {
      setState(() {
        _errorMessage = 'An account with this email/mobile already exists';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Generate real OTP code
    final otpCode = AuthService().generateOtp(input);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification OTP sent to $input: $otpCode'),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 6),
      ),
    );

    setState(() {
      _isLoading = false;
    });

    // Navigate to OTP Verification Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          fullName: fullName,
          identifier: input,
          flow: OtpFlow.signup,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _identifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Painter matching Travel design
          Positioned.fill(
            child: CustomPaint(
              painter: LoginBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar with Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Create Account',
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
                            // Title & Subtitle
                            const Text(
                              'Sign Up for Travel Time',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Enter your Full Name and Email address or 10-digit Mobile number.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Full Name Label & Field
                            const Text(
                              'Full Name',
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
                                controller: _fullNameController,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  border: InputBorder.none,
                                  hintText: 'Enter your full name',
                                  hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                                  prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Email or Mobile Field Label
                            const Text(
                              'Email or Mobile Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // TextField
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
                                  hintText: 'e.g. user@email.com or 9876543210',
                                  hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                                  prefixIcon: Icon(Icons.contact_mail_outlined, color: Colors.white70),
                                ),
                              ),
                            ),

                            // Error Message in Red
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

                            // Continue / Send OTP Button
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
                                        'Continue / Send OTP',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Back to Login Link
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Already have an account? Login',
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
