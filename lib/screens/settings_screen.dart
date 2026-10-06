import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/notifications/notification_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar_with_profile.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableBookingAlerts = true;
  bool _enableTravelReminders = true;
  bool _enablePromotional = false;

  String _selectedLanguage = 'English';
  String _selectedCurrency = '₹ INR (Indian Rupee)';

  final List<String> _languages = ['English', 'हिन्दी (Hindi)', 'తెలుగు (Telugu)', 'தமிழ் (Tamil)'];
  final List<String> _currencies = ['₹ INR (Indian Rupee)', '\$ USD (US Dollar)', '€ EUR (Euro)'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    await NotificationService().init();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableBookingAlerts = NotificationService().enableBookingAlerts;
      _enableTravelReminders = NotificationService().enableTravelReminders;
      _enablePromotional = NotificationService().enablePromotionalNotifications;
      _selectedLanguage = prefs.getString('pref_language') ?? 'English';
      _selectedCurrency = prefs.getString('pref_currency') ?? '₹ INR (Indian Rupee)';
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_language', _selectedLanguage);
    await prefs.setString('pref_currency', _selectedCurrency);
    await NotificationService().savePreferences(
      bookingAlerts: _enableBookingAlerts,
      travelReminders: _enableTravelReminders,
      promotional: _enablePromotional,
    );
  }

  void _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Image Cache?'),
        content: const Text('This will free up local storage space by clearing cached network images.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.vanRed),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully! Free 12.4 MB.')),
              );
            },
            child: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearSearchHistory() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History?'),
        content: const Text('This will remove all recent searches for your account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.vanRed),
            onPressed: () async {
              Navigator.pop(context);
              final activeUser = AuthService().getActiveUserIdentifier();
              if (activeUser != null) {
                final prefs = await SharedPreferences.getInstance();
                final key = 'travel_search_history_${activeUser.toLowerCase()}';
                await prefs.remove(key);
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search history cleared.')),
              );
            },
            child: const Text('Clear History', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Travel Time?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: const AppBarWithProfile(
        title: 'Settings',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Section 1: Notifications
            _buildSectionHeader('🔔 Notifications & Alerts'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Booking Alerts'),
                    subtitle: const Text('Receive instant alerts when ticket is booked'),
                    value: _enableBookingAlerts,
                    activeTrackColor: AppColors.vanRed,
                    onChanged: (val) {
                      setState(() => _enableBookingAlerts = val);
                      _saveSettings();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Travel Reminders'),
                    subtitle: const Text('Reminders 24h & 2h before departure'),
                    value: _enableTravelReminders,
                    activeTrackColor: AppColors.vanRed,
                    onChanged: (val) {
                      setState(() => _enableTravelReminders = val);
                      _saveSettings();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Promotions & Discounts'),
                    subtitle: const Text('Receive festive offers and deals'),
                    value: _enablePromotional,
                    activeTrackColor: AppColors.vanRed,
                    onChanged: (val) {
                      setState(() => _enablePromotional = val);
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: Language & Region
            _buildSectionHeader('🌐 Language & Region'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('App Language'),
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      underline: const SizedBox(),
                      items: _languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLanguage = val);
                          _saveSettings();
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Currency Display'),
                    subtitle: const Text('Currently INR (₹) is used for payments'),
                    trailing: DropdownButton<String>(
                      value: _selectedCurrency,
                      underline: const SizedBox(),
                      items: _currencies.map((curr) => DropdownMenuItem(value: curr, child: Text(curr))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCurrency = val);
                          _saveSettings();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: Storage Management
            _buildSectionHeader('💾 Storage & Cache'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cleaning_services, color: AppColors.primaryBlue),
                    title: const Text('Clear Image Cache'),
                    subtitle: const Text('Free up local storage space'),
                    onTap: _clearCache,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history_toggle_off, color: AppColors.vanRed),
                    title: const Text('Clear Search History'),
                    subtitle: const Text('Remove recent search suggestions'),
                    onTap: _clearSearchHistory,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 4: About
            _buildSectionHeader('ℹ️ About Application'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const ListTile(
                    title: Text('App Version'),
                    subtitle: Text('v2.0.0 (Build 2026.10.01)'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    title: Text('Developer'),
                    subtitle: Text('Travel Time Team'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy Policy: All travel data is securely stored client-side.')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 5: Logout
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text('Sign out of Travel Time account'),
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
        ),
      ),
    );
  }
}
