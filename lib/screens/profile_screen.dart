import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar_with_profile.dart';
import 'change_password_screen.dart';
import 'help_center_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailPhoneController;

  UserAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService().getCurrentUser();
    final name = _currentUser?.fullName ?? '';
    final contact = _currentUser?.email.isNotEmpty == true
        ? _currentUser!.email
        : (_currentUser?.mobile.isNotEmpty == true ? _currentUser!.mobile : 'user@travel.com');

    _nameController = TextEditingController(text: name);
    _emailPhoneController = TextEditingController(text: contact);
  }

  void _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid full name.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await AuthService().updateProfileName(newName);
    setState(() {
      _currentUser = AuthService().getCurrentUser();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile information updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBarWithProfile(
        title: 'My Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<UserAccount?>(
        valueListenable: AuthService.activeUserNotifier,
        builder: (context, user, child) {
          final activeName = user?.displayName ?? 'Traveller';
          final activeContact = user?.email.isNotEmpty == true
              ? user!.email
              : (user?.mobile.isNotEmpty == true ? user!.mobile : 'user@travel.com');
          final initials = user?.initials ?? 'T';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar Header Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                              child: Text(
                                initials,
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.vanRed,
                                child: const Icon(Icons.edit, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          activeName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeContact,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Section 1: Travel Statistics Grid
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Trips Booked', '12', Icons.flight_takeoff, Colors.blue)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Total Spent', '₹45,280', Icons.currency_rupee, Colors.green)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Member Since', 'Oct 2026', Icons.calendar_today, Colors.orange)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Tier Status', 'Silver Member', Icons.workspace_premium, Colors.purple)),
                  ],
                ),

                const SizedBox(height: 16),

                // Section 2: Personal Information Form
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personal Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailPhoneController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Email / Mobile (Session ID)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _saveProfile,
                            child: const Text('Save Profile Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Section 3: Security & Quick Actions
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_reset, color: AppColors.vanRed),
                        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Update account security password'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help_center, color: AppColors.primaryBlue),
                        title: const Text('Help & Customer Care', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('24/7 support & report issue'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings, color: Colors.grey),
                        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('App preferences & notifications'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
