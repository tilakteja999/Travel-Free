class RideFeedbackModel {
  final String id;
  final String rideBookingId;
  final String userId;
  final int overallRating;
  final int driverRating;
  final int cleanlinessRating;
  final int safetyRating;
  final int appExperienceRating;
  final String comment;
  final List<String> issueTags;
  final DateTime submittedAt;

  const RideFeedbackModel({
    required this.id,
    required this.rideBookingId,
    required this.userId,
    required this.overallRating,
    required this.driverRating,
    required this.cleanlinessRating,
    required this.safetyRating,
    required this.appExperienceRating,
    required this.comment,
    required this.issueTags,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'rideBookingId': rideBookingId,
        'userId': userId,
        'overallRating': overallRating,
        'driverRating': driverRating,
        'cleanlinessRating': cleanlinessRating,
        'safetyRating': safetyRating,
        'appExperienceRating': appExperienceRating,
        'comment': comment,
        'issueTags': issueTags,
        'submittedAt': submittedAt.toIso8601String(),
      };

  factory RideFeedbackModel.fromJson(Map<String, dynamic> json) => RideFeedbackModel(
        id: json['id'] ?? '',
        rideBookingId: json['rideBookingId'] ?? '',
        userId: json['userId'] ?? '',
        overallRating: json['overallRating'] ?? 5,
        driverRating: json['driverRating'] ?? 5,
        cleanlinessRating: json['cleanlinessRating'] ?? 5,
        safetyRating: json['safetyRating'] ?? 5,
        appExperienceRating: json['appExperienceRating'] ?? 5,
        comment: json['comment'] ?? '',
        issueTags: List<String>.from(json['issueTags'] ?? []),
        submittedAt: DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
      );
}
