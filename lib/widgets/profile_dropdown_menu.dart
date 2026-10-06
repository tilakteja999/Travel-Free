import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileDropdownMenu extends StatelessWidget {
  final UserAccount? user;
  final String? userEmail;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onBookingsTap;
  final VoidCallback onLogoutTap;

  const ProfileDropdownMenu({
    super.key,
    this.user,
    this.userEmail,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onBookingsTap,
    required this.onLogoutTap,
  });

  String _formatMaskedPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length >= 10) {
      final last4 = clean.substring(clean.length - 4);
      return '+91 ******$last4';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'Traveller';
    final email = user?.email.isNotEmpty == true ? user!.email : (userEmail ?? '');
    final mobile = user?.mobile.isNotEmpty == true ? _formatMaskedPhone(user!.mobile) : '';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 230,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Full Name & Contact Info Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (mobile.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      mobile,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade300),

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'My Profile',
              onTap: onProfileTap,
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: onSettingsTap,
            ),
            _buildMenuItem(
              context,
              icon: Icons.book_online_outlined,
              title: 'My Bookings',
              onTap: onBookingsTap,
            ),
            Divider(height: 1, color: Colors.grey.shade300),

            // Logout (Red Color)
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: onLogoutTap,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: isDestructive ? Colors.red : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}
