import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/itinerary_model.dart';

abstract class ItineraryRepository {
  Future<List<ItineraryModel>> getItinerariesForUser(String userId);
  Future<ItineraryModel> saveItinerary(ItineraryModel itinerary);
  Future<bool> deleteItinerary(String userId, String id);
}

class LocalItineraryRepository implements ItineraryRepository {
  static const String _prefix = 'tt_itineraries_';

  String _key(String userId) => '$_prefix${userId.toLowerCase()}';

  @override
  Future<List<ItineraryModel>> getItinerariesForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));

    if (raw == null || raw.isEmpty) {
      final seeds = _generateSeedItineraries(userId);
      await _saveList(userId, seeds, prefs);
      return seeds;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) => ItineraryModel.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ItineraryModel> saveItinerary(ItineraryModel itinerary) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getItinerariesForUser(itinerary.userId);

    list.removeWhere((i) => i.id == itinerary.id);
    list.insert(0, itinerary);

    await _saveList(itinerary.userId, list, prefs);
    return itinerary;
  }

  @override
  Future<bool> deleteItinerary(String userId, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getItinerariesForUser(userId);

    final beforeCount = list.length;
    list.removeWhere((i) => i.id == id);

    if (list.length < beforeCount) {
      await _saveList(userId, list, prefs);
      return true;
    }
    return false;
  }

  Future<void> _saveList(String userId, List<ItineraryModel> list, SharedPreferences prefs) async {
    final raw = jsonEncode(list.map((i) => i.toJson()).toList());
    await prefs.setString(_key(userId), raw);
  }

  List<ItineraryModel> _generateSeedItineraries(String userId) {
    final now = DateTime.now();
    return [
      ItineraryModel(
        id: 'itin_seed_1',
        userId: userId,
        title: 'Tirupati Temple Heritage Tour',
        destination: 'Tirupati',
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 13)),
        linkedBookingIds: const ['TRV-TRA-84920'],
        savedPlaceIds: const ['Sri Venkateswara Swamy Temple', 'Sri Padmavati Temple'],
        dayNotes: const {
          'Day 1': 'Board Palnadu Express from Narasaraopet at 08:15 AM. Hotel Check-in at 02:00 PM.',
          'Day 2': 'Tirumala Temple VIP Darshan & Laddu Prasadam collection.',
          'Day 3': 'Visit Sri Padmavati Ammavaari Temple in Tiruchanur.',
        },
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
    ];
  }
}
