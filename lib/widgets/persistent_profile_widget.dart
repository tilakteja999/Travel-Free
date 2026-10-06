import 'package:flutter/material.dart';
import '../screens/booking_history_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'profile_dropdown_menu.dart';

class PersistentProfileWidget extends StatefulWidget {
  final String? userEmail;
  final String? userName;

  const PersistentProfileWidget({
    super.key,
    this.userEmail,
    this.userName,
  });

  @override
  State<PersistentProfileWidget> createState() => _PersistentProfileWidgetState();
}

class _PersistentProfileWidgetState extends State<PersistentProfileWidget> {
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final currentUser = AuthService().getCurrentUser();

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Translucent Barrier to dismiss dropdown on outside tap
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Positioned Dropdown Menu
          Positioned(
            top: offset.dy + renderBox.size.height + 6,
            right: MediaQuery.of(context).size.width - offset.dx - renderBox.size.width,
            child: ProfileDropdownMenu(
              user: currentUser,
              userEmail: widget.userEmail,
              onProfileTap: () {
                _closeDropdown();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              onSettingsTap: () {
                _closeDropdown();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              onBookingsTap: () {
                _closeDropdown();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingHistoryScreen()),
                );
              },
              onLogoutTap: () {
                _closeDropdown();
                _confirmLogout(context);
              },
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    if (mounted) {
      setState(() => _isDropdownOpen = false);
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of Travel Time?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserAccount?>(
      valueListenable: AuthService.activeUserNotifier,
      builder: (context, user, child) {
        final initials = user?.initials ?? 'T';
        final firstName = user?.firstName ?? (widget.userName ?? 'Traveller');
        final screenWidth = MediaQuery.of(context).size.width;

        final showFirstNameOnly = screenWidth >= 360 && screenWidth < 600;
        final showLabel = screenWidth >= 360;
        final displayName = showFirstNameOnly ? firstName : (user?.displayName ?? firstName);

        return InkWell(
          onTap: _toggleDropdown,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBlue, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User Avatar Circle
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth >= 600 ? 140 : 85),
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(
                  _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
