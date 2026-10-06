import 'ride_driver_model.dart';
import 'ride_status.dart';
import 'ride_type.dart';

class RideBookingModel {
  final String id;
  final String userId;
  final RideStatus status;
  final RideType rideType;

  final String pickupName;
  final String destinationName;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;

  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? tripStartedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  final double routeDistanceKm;
  final int estimatedDurationMinutes;
  final double estimatedFare;
  final double? finalFare;

  final RideDriverModel? driver;
  final String paymentMethod;
  final String? cancellationReason;
  final double cancellationFee;
  final bool isDemoRide;

  const RideBookingModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.rideType,
    required this.pickupName,
    required this.destinationName,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.createdAt,
    this.acceptedAt,
    this.arrivedAt,
    this.tripStartedAt,
    this.completedAt,
    this.cancelledAt,
    required this.routeDistanceKm,
    required this.estimatedDurationMinutes,
    required this.estimatedFare,
    this.finalFare,
    this.driver,
    required this.paymentMethod,
    this.cancellationReason,
    this.cancellationFee = 0,
    this.isDemoRide = true,
  });

  RideBookingModel copyWith({
    String? id,
    String? userId,
    RideStatus? status,
    RideType? rideType,
    String? pickupName,
    String? destinationName,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? tripStartedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    double? routeDistanceKm,
    int? estimatedDurationMinutes,
    double? estimatedFare,
    double? finalFare,
    RideDriverModel? driver,
    String? paymentMethod,
    String? cancellationReason,
    double? cancellationFee,
    bool? isDemoRide,
  }) {
    return RideBookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      rideType: rideType ?? this.rideType,
      pickupName: pickupName ?? this.pickupName,
      destinationName: destinationName ?? this.destinationName,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      tripStartedAt: tripStartedAt ?? this.tripStartedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      routeDistanceKm: routeDistanceKm ?? this.routeDistanceKm,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      finalFare: finalFare ?? this.finalFare,
      driver: driver ?? this.driver,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationFee: cancellationFee ?? this.cancellationFee,
      isDemoRide: isDemoRide ?? this.isDemoRide,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'status': status.name,
        'rideType': rideType.name,
        'pickupName': pickupName,
        'destinationName': destinationName,
        'pickupLatitude': pickupLatitude,
        'pickupLongitude': pickupLongitude,
        'destinationLatitude': destinationLatitude,
        'destinationLongitude': destinationLongitude,
        'createdAt': createdAt.toIso8601String(),
        'acceptedAt': acceptedAt?.toIso8601String(),
        'arrivedAt': arrivedAt?.toIso8601String(),
        'tripStartedAt': tripStartedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
        'routeDistanceKm': routeDistanceKm,
        'estimatedDurationMinutes': estimatedDurationMinutes,
        'estimatedFare': estimatedFare,
        'finalFare': finalFare,
        'driver': driver?.toJson(),
        'paymentMethod': paymentMethod,
        'cancellationReason': cancellationReason,
        'cancellationFee': cancellationFee,
        'isDemoRide': isDemoRide,
      };

  factory RideBookingModel.fromJson(Map<String, dynamic> json) => RideBookingModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        status: RideStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => RideStatus.searchingDriver,
        ),
        rideType: RideType.values.firstWhere(
          (e) => e.name == json['rideType'],
          orElse: () => RideType.auto,
        ),
        pickupName: json['pickupName'] ?? '',
        destinationName: json['destinationName'] ?? '',
        pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble() ?? 16.2350,
        pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble() ?? 80.0500,
        destinationLatitude: (json['destinationLatitude'] as num?)?.toDouble() ?? 16.5062,
        destinationLongitude: (json['destinationLongitude'] as num?)?.toDouble() ?? 80.6480,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        acceptedAt: DateTime.tryParse(json['acceptedAt'] ?? ''),
        arrivedAt: DateTime.tryParse(json['arrivedAt'] ?? ''),
        tripStartedAt: DateTime.tryParse(json['tripStartedAt'] ?? ''),
        completedAt: DateTime.tryParse(json['completedAt'] ?? ''),
        cancelledAt: DateTime.tryParse(json['cancelledAt'] ?? ''),
        routeDistanceKm: (json['routeDistanceKm'] as num?)?.toDouble() ?? 12.5,
        estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 25,
        estimatedFare: (json['estimatedFare'] as num?)?.toDouble() ?? 150.0,
        finalFare: (json['finalFare'] as num?)?.toDouble(),
        driver: json['driver'] != null ? RideDriverModel.fromJson(Map<String, dynamic>.from(json['driver'])) : null,
        paymentMethod: json['paymentMethod'] ?? 'Cash (Demo)',
        cancellationReason: json['cancellationReason'],
        cancellationFee: (json['cancellationFee'] as num?)?.toDouble() ?? 0.0,
        isDemoRide: json['isDemoRide'] ?? true,
      );
}
