enum WishlistItemType {
  place,
  hotel,
  transportRoute,
}

class WishlistItemModel {
  final String id;
  final String userId;
  final WishlistItemType itemType;
  final String itemId;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String priceOrFareSummary;
  final double rating;
  final DateTime savedAt;

  const WishlistItemModel({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.priceOrFareSummary,
    this.rating = 4.5,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'itemType': itemType.name,
        'itemId': itemId,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'priceOrFareSummary': priceOrFareSummary,
        'rating': rating,
        'savedAt': savedAt.toIso8601String(),
      };

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) => WishlistItemModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        itemType: WishlistItemType.values.firstWhere(
          (e) => e.name == json['itemType'],
          orElse: () => WishlistItemType.place,
        ),
        itemId: json['itemId'] ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        priceOrFareSummary: json['priceOrFareSummary'] ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
        savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
      );
}
