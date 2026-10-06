import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

enum PermissionType { location, notification, camera }

class PermissionHandler {
  static final PermissionHandler _instance = PermissionHandler._internal();
  factory PermissionHandler() => _instance;
  PermissionHandler._internal();

  static const String _keyLocation = 'perm_location_granted';
  static const String _keyNotification = 'perm_notification_granted';
  static const String _keyCamera = 'perm_camera_granted';

  Future<bool> requestPermission(BuildContext context, PermissionType type) async {
    final prefs = await SharedPreferences.getInstance();

    switch (type) {
      case PermissionType.location:
        return _handleLocationPermission(context, prefs);
      case PermissionType.notification:
        return _handleNotificationPermission(context, prefs);
      case PermissionType.camera:
        return _handleCameraPermission(context, prefs);
    }
  }

  Future<bool> _handleLocationPermission(BuildContext context, SharedPreferences prefs) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return false;
      _showRationaleDialog(
        context,
        title: 'Location Service Disabled',
        message: 'Travel Time needs GPS location to auto-detect your starting point (e.g. Narasaraopet). Please enable location services in your device settings.',
        type: PermissionType.location,
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      await prefs.setBool(_keyLocation, true);
      return true;
    }

    if (!context.mounted) return false;
    bool shouldProceed = await _showRationaleDialog(
      context,
      title: 'Location Permission Needed',
      message: 'Travel Time needs access to your GPS location to automatically set your starting point and find nearby stations.',
      type: PermissionType.location,
    );

    if (!shouldProceed) return false;

    permission = await Geolocator.requestPermission();
    final isGranted = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    await prefs.setBool(_keyLocation, isGranted);
    return isGranted;
  }

  Future<bool> _handleNotificationPermission(BuildContext context, SharedPreferences prefs) async {
    final alreadyGranted = prefs.getBool(_keyNotification) ?? false;
    if (alreadyGranted) return true;

    final shouldProceed = await _showRationaleDialog(
      context,
      title: 'Booking & Travel Alerts',
      message: 'Allow Travel Time to send you booking confirmation notices, seat updates, and travel departure reminders.',
      type: PermissionType.notification,
    );

    if (shouldProceed) {
      await prefs.setBool(_keyNotification, true);
      return true;
    }
    return false;
  }

  Future<bool> _handleCameraPermission(BuildContext context, SharedPreferences prefs) async {
    final shouldProceed = await _showRationaleDialog(
      context,
      title: 'Camera & Gallery Access',
      message: 'Travel Time needs camera and storage access so you can upload photos of tourist spots and hotel rooms in your reviews.',
      type: PermissionType.camera,
    );

    if (shouldProceed) {
      await prefs.setBool(_keyCamera, true);
      return true;
    }
    return false;
  }

  Future<bool> _showRationaleDialog(
    BuildContext context, {
    required String title,
    required String message,
    required PermissionType type,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              type == PermissionType.location
                  ? Icons.location_on
                  : type == PermissionType.notification
                      ? Icons.notifications_active
                      : Icons.camera_alt,
              color: AppColors.vanRed,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Deny', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow Access', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Widget buildPermissionDeniedBanner({
    required VoidCallback onOpenSettings,
    required VoidCallback onManualInput,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '📍 Location access denied. Please enable in Settings or enter manually.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onManualInput,
                child: const Text('Enter Manually', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onOpenSettings,
                child: const Text('Open Settings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
