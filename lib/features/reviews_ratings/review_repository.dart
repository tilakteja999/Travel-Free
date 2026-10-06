import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import 'review_model.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForPlace(String placeOrHotelId);
  Future<void> submitReview(Review review);
  Future<double> getAverageRating(String placeOrHotelId);
}

class MockReviewRepository implements ReviewRepository {
  static const String _keyReviewsPrefix = 'travel_reviews_id_';

  @override
  Future<List<Review>> getReviewsForPlace(String placeOrHotelId) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanId = placeOrHotelId.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final key = '$_keyReviewsPrefix$cleanId';
    final raw = prefs.getString(key);

    List<Review> userReviews = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        userReviews = list.map((item) => Review.fromJson(Map<String, dynamic>.from(item))).toList();
      } catch (e) {
        userReviews = [];
      }
    }

    // Default Seed Reviews
    final defaultReviews = [
      Review(
        id: 'rev_seed_1',
        placeOrHotelId: placeOrHotelId,
        userName: 'Ananya Rao',
        rating: 5.0,
        reviewTitle: 'Exceeded Expectations! Highly Recommended',
        reviewText: 'Beautiful experience with peaceful ambiance. Cleanliness and hospitality were top notch. Must visit with family!',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        helpfulCount: 24,
        categoryTags: ['Cleanliness', 'Location', 'Value for Money'],
        photos: ['https://images.weserv.nl/?url=https://images.unsplash.com/photo-1544717305-2782549b5136'],
      ),
      Review(
        id: 'rev_seed_2',
        placeOrHotelId: placeOrHotelId,
        userName: 'Vikram Verma',
        rating: 4.5,
        reviewTitle: 'Great Ambience & Helpful Staff',
        reviewText: 'Visited during the weekend. Very accessible, polite staff, and great scenic photo spots.',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        helpfulCount: 15,
        categoryTags: ['Location', 'Service'],
      ),
    ];

    return [...userReviews, ...defaultReviews];
  }

  @override
  Future<void> submitReview(Review review) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanId = review.placeOrHotelId.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final key = '$_keyReviewsPrefix$cleanId';

    final existing = await getReviewsForPlace(review.placeOrHotelId);

    // Prevent duplicate review by same user
    final activeUser = AuthService().getActiveUserIdentifier() ?? 'guest';
    existing.removeWhere((r) => r.userName.toLowerCase() == activeUser.toLowerCase());

    existing.insert(0, review);

    final rawList = existing.map((r) => r.toJson()).toList();
    await prefs.setString(key, jsonEncode(rawList));
  }

  @override
  Future<double> getAverageRating(String placeOrHotelId) async {
    final reviews = await getReviewsForPlace(placeOrHotelId);
    if (reviews.isEmpty) return 4.8;
    final total = reviews.map((r) => r.rating).reduce((a, b) => a + b);
    return total / reviews.length;
  }
}
