import 'package:flutter/material.dart';
import '../models/wishlist_item_model.dart';
import '../repositories/local_wishlist_repository.dart';
import '../services/auth_service.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistRepository _repository = LocalWishlistRepository();

  List<WishlistItemModel> _items = [];
  bool _isLoading = false;

  List<WishlistItemModel> get items => _items;
  bool get isLoading => _isLoading;

  String get _currentUserId => AuthService().getActiveUserIdentifier() ?? 'user@travel.com';

  Future<void> fetchWishlist() async {
    _isLoading = true;
    notifyListeners();

    _items = await _repository.getWishlistForUser(_currentUserId);
    _isLoading = false;
    notifyListeners();
  }

  bool isItemSaved(String itemId, WishlistItemType type) {
    return _items.any((i) => i.itemId == itemId && i.itemType == type);
  }

  Future<bool> toggleWishlist(WishlistItemModel item) async {
    final isAdded = await _repository.toggleWishlist(item);
    await fetchWishlist();
    return isAdded;
  }
}
