class Review {
  final String id;
  final String placeOrHotelId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String reviewTitle;
  final String reviewText;
  final DateTime timestamp;
  int helpfulCount;
  final List<String> photos;
  final List<String> categoryTags;
  final bool isVerifiedGuest;

  Review({
    required this.id,
    required this.placeOrHotelId,
    required this.userName,
    this.userAvatar = '',
    required this.rating,
    required this.reviewTitle,
    required this.reviewText,
    required this.timestamp,
    this.helpfulCount = 0,
    List<String>? photos,
    List<String>? categoryTags,
    this.isVerifiedGuest = true,
  })  : photos = photos ?? [],
        categoryTags = categoryTags ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'placeOrHotelId': placeOrHotelId,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'reviewTitle': reviewTitle,
        'reviewText': reviewText,
        'timestamp': timestamp.toIso8601String(),
        'helpfulCount': helpfulCount,
        'photos': photos,
        'categoryTags': categoryTags,
        'isVerifiedGuest': isVerifiedGuest,
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] ?? '',
        placeOrHotelId: json['placeOrHotelId'] ?? '',
        userName: json['userName'] ?? 'Traveler',
        userAvatar: json['userAvatar'] ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        reviewTitle: json['reviewTitle'] ?? '',
        reviewText: json['reviewText'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        helpfulCount: json['helpfulCount'] ?? 0,
        photos: List<String>.from(json['photos'] ?? []),
        categoryTags: List<String>.from(json['categoryTags'] ?? []),
        isVerifiedGuest: json['isVerifiedGuest'] ?? true,
      );
}
