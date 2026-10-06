import 'dart:convert';

class ItineraryModel {
  final String id;
  final String userId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> linkedBookingIds;
  final List<String> savedPlaceIds;
  final Map<String, String> dayNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDemoItinerary;

  const ItineraryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.linkedBookingIds = const [],
    this.savedPlaceIds = const [],
    this.dayNotes = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isDemoItinerary = true,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'linkedBookingIds': linkedBookingIds,
        'savedPlaceIds': savedPlaceIds,
        'dayNotes': dayNotes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDemoItinerary': isDemoItinerary,
      };

  factory ItineraryModel.fromJson(Map<String, dynamic> json) => ItineraryModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        title: json['title'] ?? '',
        destination: json['destination'] ?? '',
        startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now().add(const Duration(days: 3)),
        linkedBookingIds: List<String>.from(json['linkedBookingIds'] ?? []),
        savedPlaceIds: List<String>.from(json['savedPlaceIds'] ?? []),
        dayNotes: Map<String, String>.from(json['dayNotes'] ?? {}),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
        isDemoItinerary: json['isDemoItinerary'] ?? true,
      );

  ItineraryModel copyWith({
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? linkedBookingIds,
    List<String>? savedPlaceIds,
    Map<String, String>? dayNotes,
    DateTime? updatedAt,
  }) {
    return ItineraryModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      linkedBookingIds: linkedBookingIds ?? this.linkedBookingIds,
      savedPlaceIds: savedPlaceIds ?? this.savedPlaceIds,
      dayNotes: dayNotes ?? this.dayNotes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isDemoItinerary: isDemoItinerary,
    );
  }
}
