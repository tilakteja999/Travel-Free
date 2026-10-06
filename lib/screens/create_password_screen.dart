import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import 'home_screen.dart';
import 'otp_verification_screen.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String? fullName;
  final String identifier;
  final OtpFlow flow;

  const CreatePasswordScreen({
    super.key,
    this.fullName,
    required this.identifier,
    required this.flow,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  Map<String, bool> _requirements = {
    'Min 8 characters': false,
    'At least one uppercase letter (A-Z)': false,
    'At least one lowercase letter (a-z)': false,
    'At least one number (0-9)': false,
  };

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateRequirements);
  }

  void _updateRequirements() {
    setState(() {
      _requirements = AuthService.validatePasswordRequirements(_passwordController.text);
    });
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
    });

    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (pass.isEmpty) {
      setState(() {
        _errorMessage = 'Password field cannot be empty.';
      });
      return;
    }

    if (!AuthService.isPasswordValid(pass)) {
      final missing = _requirements.entries
          .where((e) => !e.value)
          .map((e) => e.key)
          .join(', ');
      setState(() {
        _errorMessage = 'Password requirement missing: $missing';
      });
      return;
    }

    if (confirmPass.isEmpty) {
      setState(() {
        _errorMessage = 'Please re-enter your password.';
      });
      return;
    }

    if (pass != confirmPass) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (widget.flow == OtpFlow.signup) {
      final name = widget.fullName ?? 'Traveller';
      await AuthService().registerUser(
        fullName: name,
        identifier: widget.identifier,
        password: pass,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Welcome to Travel Time.'),
          backgroundColor: AppColors.accentGreen,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate directly to Home Screen clearing backstack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      // Forgot Password Reset Flow
      await AuthService().resetPassword(widget.identifier, pass);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Please login with your new password.'),
          backgroundColor: AppColors.accentGreen,
          duration: Duration(seconds: 4),
        ),
      );

      // Return to Login
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSignup = widget.flow == OtpFlow.signup;

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
                // Top Nav
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        isSignup ? 'Create Password' : 'Reset Password',
                        style: const TextStyle(
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
                            Text(
                              isSignup ? 'Set Account Password' : 'New Password',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Secure password for ${widget.identifier}',
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            const SizedBox(height: 20),

                            // Enter Password Field
                            const Text(
                              'Enter Password',
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
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  border: InputBorder.none,
                                  hintText: 'Enter new password',
                                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Re-enter Password Field
                            const Text(
                              'Re-enter Password',
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
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  border: InputBorder.none,
                                  hintText: 'Re-enter password',
                                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Password Requirements Checklist
                            const Text(
                              'Password Requirements:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),

                            ..._requirements.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      entry.value ? Icons.check_circle : Icons.radio_button_unchecked,
                                      size: 16,
                                      color: entry.value ? Colors.green : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: entry.value ? Colors.green.shade800 : Colors.black87,
                                        fontWeight: entry.value ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Red Error Display
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 14),
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

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSubmit,
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
                                    : Text(
                                        isSignup ? 'CREATE ACCOUNT' : 'UPDATE PASSWORD',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
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
