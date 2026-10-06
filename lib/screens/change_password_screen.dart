import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _errorMessage = null);

      if (_newPassController.text != _confirmPassController.text) {
        setState(() => _errorMessage = 'New passwords do not match.');
        return;
      }

      final activeUser = AuthService().getActiveUserIdentifier();
      if (activeUser == null) {
        setState(() => _errorMessage = 'No active user session found.');
        return;
      }

      final success = await AuthService().changePassword(
        identifier: activeUser,
        currentPassword: _currentPassController.text,
        newPassword: _newPassController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = 'Current password is incorrect.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Change Password'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _currentPassController,
                        obscureText: _obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter current password' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _newPassController,
                        obscureText: _obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Min 8 chars, 1 uppercase, 1 number',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.length < 8) {
                            return 'Password must be at least 8 characters long.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPassController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Confirm new password' : null,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vanRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _handleChangePassword,
                  child: const Text('UPDATE PASSWORD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
