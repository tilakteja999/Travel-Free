import 'package:flutter/material.dart';
import '../features/notifications/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _enableBookingAlerts = true;
  bool _enableTravelReminders = true;
  bool _enablePromotional = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    await NotificationService().init();
    setState(() {
      _enableBookingAlerts = NotificationService().enableBookingAlerts;
      _enableTravelReminders = NotificationService().enableTravelReminders;
      _enablePromotional = NotificationService().enablePromotionalNotifications;
    });
  }

  void _savePrefs() async {
    await NotificationService().savePreferences(
      bookingAlerts: _enableBookingAlerts,
      travelReminders: _enableTravelReminders,
      promotional: _enablePromotional,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Notification & Alert Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Booking Confirmations', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Receive instant alerts when ticket or room is booked'),
                    value: _enableBookingAlerts,
                    activeColor: AppColors.vanRed,
                    onChanged: (val) {
                      setState(() => _enableBookingAlerts = val);
                      _savePrefs();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Travel Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Receive departure reminders 24h & 2h before trip'),
                    value: _enableTravelReminders,
                    activeColor: AppColors.vanRed,
                    onChanged: (val) {
                      setState(() => _enableTravelReminders = val);
                      _savePrefs();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Promotions & Discounts', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Receive hotel deals, holiday offers & festive discounts'),
                    value: _enablePromotional,
                    activeColor: AppColors.vanRed,
                    onChanged: (val) {
                      setState(() => _enablePromotional = val);
                      _savePrefs();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Send Test Alert Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vanRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  NotificationService().triggerTestAlert(context);
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('🔔 Send Test Alert', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
