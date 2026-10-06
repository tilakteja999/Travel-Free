import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import 'forgot_password_screen.dart';
import 'location_search_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _rememberedAccountIdentifier;
  UserAccount? _rememberedUser;
  bool _isSwitchingAccount = false;

  @override
  void initState() {
    super.initState();
    _checkRememberedAccount();
  }

  void _checkRememberedAccount() async {
    await AuthService().init();
    final lastAccount = AuthService().getLastAccountIdentifier();
    if (lastAccount != null && lastAccount.isNotEmpty) {
      final user = AuthService().findAccountByEmailOrMobile(lastAccount);
      setState(() {
        _rememberedAccountIdentifier = lastAccount;
        _rememberedUser = user;
      });
    }
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final identifier = _isRememberedMode
        ? (_rememberedUser?.identifier ?? _rememberedAccountIdentifier!)
        : _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Email or Mobile Number.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await AuthService().login(identifier, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LocationSearchScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Incorrect email/mobile number or password';
      });
    }
  }

  void _handleSwitchAccount() async {
    await AuthService().switchAccount();
    setState(() {
      _rememberedAccountIdentifier = null;
      _rememberedUser = null;
      _isSwitchingAccount = true;
      _errorMessage = null;
      _identifierController.clear();
      _passwordController.clear();
    });
  }

  bool get _isRememberedMode =>
      (_rememberedUser != null || _rememberedAccountIdentifier != null) && !_isSwitchingAccount;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Illustration (Globe, Beach, Sky)
          Positioned.fill(
            child: CustomPaint(
              painter: LoginBackgroundPainter(),
            ),
          ),

          // Suitcase & Camera graphic overlays at bottom right
          Positioned(
            right: 16,
            bottom: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Yellow Luggage
                Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.vanOrange,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Icon(Icons.beach_access, color: Colors.white, size: 36),
                      const SizedBox(height: 8),
                      const Icon(Icons.drag_handle, color: Colors.black26, size: 24),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 3D Camera Icon
                Container(
                  width: 80,
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81C784),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DD0E1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.pinkAccent, width: 3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Login Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Main White Phone Frame Card
                  Container(
                    width: size.width > 420 ? 380 : size.width * 0.88,
                    padding: const EdgeInsets.only(top: 45, left: 20, right: 20, bottom: 24),
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
                        const SizedBox(height: 10),

                        // Application Header Title
                        Center(
                          child: Text(
                            'Travel Time',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.vanRed,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_isRememberedMode) ...[
                          // Remembered User Mode ("Continue as Full Name")
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  'Continue as',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F2F2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: const Color(0xFF5A498A),
                                        child: Text(
                                          _rememberedUser?.initials ?? 'T',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _rememberedUser?.displayName ?? 'Traveller',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Password',
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: InputBorder.none,
                                hintText: 'Enter Password',
                                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
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
                        ] else ...[
                          // Full Login Form Mode
                          const Text(
                            'Email / Mobile Number',
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextField(
                              controller: _identifierController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: InputBorder.none,
                                hintText: 'e.g. user@travel.com or 9876543210',
                                hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Password',
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: InputBorder.none,
                                hintText: 'Enter Password',
                                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
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
                        ],

                        // Red Error Message Display
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
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppColors.vanRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Login / Continue Button
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C3240),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
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
                                      _isRememberedMode ? 'Continue' : 'LOGIN',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_isRememberedMode) ...[
                          // Switch Account Button
                          Center(
                            child: TextButton(
                              onPressed: _handleSwitchAccount,
                              child: const Text(
                                'Switch Account',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Don't have an account? Sign Up Link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.vanRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Avatar Graphic at top
                  Positioned(
                    top: -30,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3D8F8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _rememberedUser?.initials ?? 'T',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A498A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
