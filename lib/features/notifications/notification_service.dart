import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String category;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'category': category,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        category: json['category'] ?? 'general',
      );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _keyPrefs = 'travel_notification_prefs';
  static const String _keyNotificationsList = 'travel_notifications_list';

  bool enableBookingAlerts = true;
  bool enableTravelReminders = true;
  bool enablePromotionalNotifications = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_keyPrefs);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(rawJson);
        enableBookingAlerts = map['enableBookingAlerts'] ?? true;
        enableTravelReminders = map['enableTravelReminders'] ?? true;
        enablePromotionalNotifications = map['enablePromotionalNotifications'] ?? false;
      } catch (e) {
        // Fallback
      }
    }
  }

  Future<void> savePreferences({
    required bool bookingAlerts,
    required bool travelReminders,
    required bool promotional,
  }) async {
    enableBookingAlerts = bookingAlerts;
    enableTravelReminders = travelReminders;
    enablePromotionalNotifications = promotional;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyPrefs,
      jsonEncode({
        'enableBookingAlerts': enableBookingAlerts,
        'enableTravelReminders': enableTravelReminders,
        'enablePromotionalNotifications': enablePromotionalNotifications,
      }),
    );
  }

  // Trigger Notifications
  void showBookingConfirmation(BuildContext context, String bookingId, double amount) {
    if (!enableBookingAlerts) return;

    final title = '🎉 Booking Confirmed! #$bookingId';
    final body = 'Your travel booking of ₹${amount.toStringAsFixed(0)} is confirmed. View your e-ticket now.';

    _addNotificationToList(title, body, 'booking');
    _showInAppBanner(context, title, body, Colors.green.shade800);
  }

  void showPaymentSuccess(BuildContext context, double amount) {
    if (!enableBookingAlerts) return;

    final title = '✅ Payment Received';
    final body = 'Payment of ₹${amount.toStringAsFixed(0)} processed successfully.';

    _addNotificationToList(title, body, 'payment');
  }

  void showPaymentFailure(BuildContext context, String reason) {
    final title = '❌ Payment Failed';
    final body = 'Reason: $reason. Please retry or try another payment method.';

    _addNotificationToList(title, body, 'payment');
    _showInAppBanner(context, title, body, Colors.red.shade800);
  }

  void scheduleTravelReminder(BuildContext context, DateTime departureTime, String route) {
    if (!enableTravelReminders) return;

    final title = '⏰ Upcoming Trip Reminder';
    final body = 'Your trip for $route is coming up on ${departureTime.day}/${departureTime.month}. Reach station 30 mins prior.';

    _addNotificationToList(title, body, 'reminder');
  }

  void triggerTestAlert(BuildContext context) {
    const title = '🔔 Test Travel Alert';
    const body = 'Push Notifications and Travel Reminders are working perfectly on Travel Time!';

    _addNotificationToList(title, body, 'test');
    _showInAppBanner(context, title, body, AppColors.vanRed);
  }

  void _showInAppBanner(BuildContext context, String title, String body, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(body, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _addNotificationToList(String title, String body, String category) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyNotificationsList);
    List<dynamic> list = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        list = jsonDecode(raw);
      } catch (e) {
        list = [];
      }
    }

    final item = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      category: category,
    );

    list.insert(0, item.toJson());
    if (list.length > 20) list = list.sublist(0, 20);

    await prefs.setString(_keyNotificationsList, jsonEncode(list));
  }
}
