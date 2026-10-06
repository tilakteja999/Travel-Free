import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ride_booking_model.dart';
import '../models/ride_feedback_model.dart';
import 'ride_repository.dart';

class LocalRideRepository implements RideRepository {
  static const String _keyRidePrefix = 'tt_rides_';
  static const String _keyFeedbackPrefix = 'tt_ride_feedback_';
  static const String _keyChatPrefix = 'tt_ride_chat_';

  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<List<RideBookingModel>> getUserRides(String userId) async {
    await _init();
    final cleanUserId = userId.isEmpty ? 'guest' : userId.replaceAll(' ', '_');
    final raw = _prefs?.getString('$_keyRidePrefix$cleanUserId');
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        return decoded
            .map((item) => RideBookingModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<RideBookingModel?> getRideById(String userId, String rideId) async {
    final rides = await getUserRides(userId);
    for (var r in rides) {
      if (r.id == rideId) return r;
    }
    return null;
  }

  @override
  Future<void> saveRide(RideBookingModel ride) async {
    await _init();
    final cleanUserId = ride.userId.isEmpty ? 'guest' : ride.userId.replaceAll(' ', '_');
    final rides = await getUserRides(cleanUserId);
    final index = rides.indexWhere((r) => r.id == ride.id);
    if (index >= 0) {
      rides[index] = ride;
    } else {
      rides.insert(0, ride);
    }

    final rawJson = jsonEncode(rides.map((r) => r.toJson()).toList());
    await _prefs?.setString('$_keyRidePrefix$cleanUserId', rawJson);
  }

  @override
  Future<void> updateRideStatus(String userId, String rideId, RideBookingModel updated) async {
    await saveRide(updated);
  }

  @override
  Future<void> saveFeedback(RideFeedbackModel feedback) async {
    await _init();
    final cleanUserId = feedback.userId.isEmpty ? 'guest' : feedback.userId.replaceAll(' ', '_');
    final key = '$_keyFeedbackPrefix${cleanUserId}_${feedback.rideBookingId}';
    await _prefs?.setString(key, jsonEncode(feedback.toJson()));
  }

  @override
  Future<RideFeedbackModel?> getFeedbackByRideId(String userId, String rideId) async {
    await _init();
    final cleanUserId = userId.isEmpty ? 'guest' : userId.replaceAll(' ', '_');
    final key = '$_keyFeedbackPrefix${cleanUserId}_$rideId';
    final raw = _prefs?.getString(key);
    if (raw != null && raw.isNotEmpty) {
      try {
        return RideFeedbackModel.fromJson(jsonDecode(raw));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<List<String>> getChatMessages(String rideId) async {
    await _init();
    final key = '$_keyChatPrefix$rideId';
    final raw = _prefs?.getStringList(key);
    if (raw != null) return raw;
    return [
      'Driver: Hi, I am on my way to your pickup location.',
      'Driver: I will reach your pickup point in a few minutes.'
    ];
  }

  @override
  Future<void> addChatMessage(String rideId, String message) async {
    await _init();
    final key = '$_keyChatPrefix$rideId';
    final current = await getChatMessages(rideId);
    current.add(message);
    await _prefs?.setStringList(key, current);
  }
}
