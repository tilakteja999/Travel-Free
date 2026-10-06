import '../models/wishlist_item_model.dart';

abstract class WishlistRepository {
  Future<List<WishlistItemModel>> getUserWishlist(String userId);
  Future<bool> isItemSaved(String userId, WishlistItemType type, String itemId);
  Future<void> addToWishlist(WishlistItemModel item);
  Future<void> removeFromWishlist(String userId, WishlistItemType type, String itemId);
}
