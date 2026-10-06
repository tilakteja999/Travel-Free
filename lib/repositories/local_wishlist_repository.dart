import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist_item_model.dart';

abstract class WishlistRepository {
  Future<List<WishlistItemModel>> getWishlistForUser(String userId);
  Future<bool> toggleWishlist(WishlistItemModel item);
  Future<bool> isSaved(String userId, String itemId, WishlistItemType type);
}

class LocalWishlistRepository implements WishlistRepository {
  static const String _prefix = 'tt_wishlist_';

  String _key(String userId) => '$_prefix${userId.toLowerCase()}';

  @override
  Future<List<WishlistItemModel>> getWishlistForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));

    if (raw == null || raw.isEmpty) {
      final seeds = _generateSeedWishlist(userId);
      await _saveList(userId, seeds, prefs);
      return seeds;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) => WishlistItemModel.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> isSaved(String userId, String itemId, WishlistItemType type) async {
    final list = await getWishlistForUser(userId);
    return list.any((item) => item.itemId == itemId && item.itemType == type);
  }

  @override
  Future<bool> toggleWishlist(WishlistItemModel item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getWishlistForUser(item.userId);

    final exists = list.any((i) => i.itemId == item.itemId && i.itemType == item.itemType);
    if (exists) {
      list.removeWhere((i) => i.itemId == item.itemId && i.itemType == item.itemType);
      await _saveList(item.userId, list, prefs);
      return false; // Removed
    } else {
      list.insert(0, item);
      await _saveList(item.userId, list, prefs);
      return true; // Added
    }
  }

  Future<void> _saveList(String userId, List<WishlistItemModel> list, SharedPreferences prefs) async {
    final raw = jsonEncode(list.map((i) => i.toJson()).toList());
    await prefs.setString(_key(userId), raw);
  }

  List<WishlistItemModel> _generateSeedWishlist(String userId) {
    return [
      WishlistItemModel(
        id: 'wish_seed_1',
        userId: userId,
        itemType: WishlistItemType.place,
        itemId: 'Kotappakonda Sri Trikoteswara Swamy Temple',
        title: 'Kotappakonda Sri Trikoteswara Swamy Temple',
        subtitle: 'Hindu Temple & Hill Shrine • 12 km from Narasaraopet',
        imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1544717305-2782549b5136',
        priceOrFareSummary: 'Free Entry',
        rating: 4.8,
        savedAt: DateTime.now(),
      ),
      WishlistItemModel(
        id: 'wish_seed_2',
        userId: userId,
        itemType: WishlistItemType.hotel,
        itemId: 'Lotus Grand Hotel and Restaurant',
        title: 'Lotus Grand Hotel and Restaurant',
        subtitle: '10 KM from city center • Multi-cuisine dining',
        imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1566073771259-6a8506099945',
        priceOrFareSummary: '₹2,400 / night',
        rating: 4.5,
        savedAt: DateTime.now(),
      ),
    ];
  }
}
