import 'ride_type.dart';

class RideQuoteModel {
  final RideType rideType;
  final double routeDistanceKm;
  final int estimatedDurationMinutes;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double demandMultiplier;
  final double platformFee;
  final double estimatedTotal;
  final int driverArrivalMinutes;
  final bool isAvailable;
  final String? unavailableMessage;

  const RideQuoteModel({
    required this.rideType,
    required this.routeDistanceKm,
    required this.estimatedDurationMinutes,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.demandMultiplier,
    required this.platformFee,
    required this.estimatedTotal,
    required this.driverArrivalMinutes,
    required this.isAvailable,
    this.unavailableMessage,
  });
}
