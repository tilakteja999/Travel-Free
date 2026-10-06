import 'ride_type.dart';

class RideDriverModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final RideType supportedRideType;
  final String vehicleName;
  final String vehicleNumber;
  final double rating;
  final int completedTrips;
  final String language;
  final double latitude;
  final double longitude;

  const RideDriverModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.supportedRideType,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.rating,
    required this.completedTrips,
    required this.language,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'supportedRideType': supportedRideType.name,
        'vehicleName': vehicleName,
        'vehicleNumber': vehicleNumber,
        'rating': rating,
        'completedTrips': completedTrips,
        'language': language,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory RideDriverModel.fromJson(Map<String, dynamic> json) => RideDriverModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        avatarUrl: json['avatarUrl'],
        supportedRideType: RideType.values.firstWhere(
          (e) => e.name == json['supportedRideType'],
          orElse: () => RideType.auto,
        ),
        vehicleName: json['vehicleName'] ?? '',
        vehicleNumber: json['vehicleNumber'] ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
        completedTrips: json['completedTrips'] ?? 500,
        language: json['language'] ?? 'Telugu, English, Hindi',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 16.2350,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 80.0500,
      );
}
