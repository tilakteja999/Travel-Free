import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryItem {
  final String id;
  final String fromLocation;
  final String toLocation;
  final DateTime timestamp;

  SearchHistoryItem({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) => SearchHistoryItem(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fromLocation: json['fromLocation'] ?? '',
        toLocation: json['toLocation'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      );
}

class SearchHistoryService {
  static final SearchHistoryService _instance = SearchHistoryService._internal();
  factory SearchHistoryService() => _instance;
  SearchHistoryService._internal();

  static const String _prefixKey = 'travel_search_history_user_';

  String _getKey(String userIdentifier) {
    final cleanId = userIdentifier.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    return '$_prefixKey$cleanId';
  }

  // Get search history for specific user
  Future<List<SearchHistoryItem>> getHistory(String userIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(userIdentifier);
    final rawJson = prefs.getString(key);

    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => SearchHistoryItem.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  // Add search to history
  Future<void> addSearch({
    required String userIdentifier,
    required String fromLocation,
    required String toLocation,
  }) async {
    final cleanFrom = fromLocation.trim();
    final cleanTo = toLocation.trim();

    if (cleanFrom.isEmpty || cleanTo.isEmpty) return;

    final history = await getHistory(userIdentifier);

    // Avoid duplicate consecutive entry
    if (history.isNotEmpty) {
      final latest = history.first;
      if (latest.fromLocation.toLowerCase() == cleanFrom.toLowerCase() &&
          latest.toLocation.toLowerCase() == cleanTo.toLowerCase()) {
        return; // Don't add duplicate
      }
    }

    // Remove any previous identical search item
    history.removeWhere((item) =>
        item.fromLocation.toLowerCase() == cleanFrom.toLowerCase() &&
        item.toLocation.toLowerCase() == cleanTo.toLowerCase());

    // Insert new item at top
    final newItem = SearchHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromLocation: cleanFrom,
      toLocation: cleanTo,
      timestamp: DateTime.now(),
    );

    history.insert(0, newItem);

    // Limit to max 10 items
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await _saveHistory(userIdentifier, history);
  }

  // Delete individual item
  Future<void> deleteItem(String userIdentifier, String itemId) async {
    final history = await getHistory(userIdentifier);
    history.removeWhere((item) => item.id == itemId);
    await _saveHistory(userIdentifier, history);
  }

  // Clear all history for user
  Future<void> clearHistory(String userIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(userIdentifier);
    await prefs.remove(key);
  }

  Future<void> _saveHistory(String userIdentifier, List<SearchHistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(userIdentifier);
    final rawList = history.map((e) => e.toJson()).toList();
    await prefs.setString(key, jsonEncode(rawList));
  }
}
