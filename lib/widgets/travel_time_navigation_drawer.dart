import 'package:flutter/material.dart';
import '../screens/booking_history_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/itinerary_screen.dart';
import '../screens/location_search_screen.dart';
import '../screens/login_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/wishlist_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class TravelTimeNavigationDrawer extends StatelessWidget {
  final String currentRoute;

  const TravelTimeNavigationDrawer({
    super.key,
    this.currentRoute = '',
  });

  void _showDemoInformation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.vanRed, size: 28),
                SizedBox(width: 10),
                Text(
                  'Demo Mode Disclosure',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Travel Time is a 100% client-side demo application.\n\n'
              '• All bookings, payments, drivers, seat/room locking, support chats, and tickets are simulated locally on this device/browser.\n'
              '• No real money is charged and no real travel tickets are issued.\n'
              '• Data is persisted locally in your browser/device storage.',
              style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Understood'),
              ),
            ),
          ],
        ),
      ),
    );
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
              if (!context.mounted) return;
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
  Widget build(BuildContext context) {
    final activeUser = AuthService().getActiveUserIdentifier() ?? 'user@travel.com';
    final name = activeUser.contains('@') ? activeUser.split('@').first : 'Traveler';
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'T';

    final size = MediaQuery.of(context).size;
    final drawerWidth = size.width > 480 ? 340.0 : size.width * 0.84;

    return Drawer(
      width: drawerWidth,
      child: Container(
        color: const Color(0xFFFFF8F0),
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Text(
                      firstLetter,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeUser,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                          child: const Text(
                            'View Profile →',
                            style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionLabel('EXPLORE'),
                  _buildTile(
                    context,
                    icon: Icons.search,
                    title: 'Search Destinations',
                    route: 'search',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LocationSearchScreen()),
                      );
                    },
                  ),

                  _buildSectionLabel('MY TRAVEL'),
                  _buildTile(
                    context,
                    icon: Icons.confirmation_number,
                    title: 'My Trips / Bookings',
                    route: 'bookings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookingHistoryScreen()),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.map,
                    title: 'My Itinerary',
                    route: 'itinerary',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ItineraryScreen()),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.favorite,
                    title: 'Wishlist & Saved',
                    route: 'wishlist',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WishlistScreen()),
                      );
                    },
                  ),

                  _buildSectionLabel('PREFERENCES'),
                  _buildTile(
                    context,
                    icon: Icons.notifications_active,
                    title: 'Notifications',
                    route: 'notifications',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.settings,
                    title: 'App Settings',
                    route: 'settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),

                  _buildSectionLabel('SUPPORT & INFO'),
                  _buildTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Customer Support',
                    route: 'help',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'Demo Mode Disclosures',
                    route: 'demo_info',
                    onTap: () {
                      Navigator.pop(context);
                      _showDemoInformation(context);
                    },
                  ),

                  const Divider(height: 20),

                  // Logout
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red, size: 22),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmLogout(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required VoidCallback onTap,
  }) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.vanRed : AppColors.textDark,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.vanRed : AppColors.textDark,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.vanRed.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 8,
    );
  }
}
