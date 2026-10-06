import 'dart:math';
import '../models/ride_quote_model.dart';
import '../models/ride_type.dart';

class RideFareCalculator {
  static Map<String, List<double>> knownCoordinates = {
    'narasaraopet': [16.2350, 80.0500],
    'guntur': [16.3067, 80.4365],
    'vijayawada': [16.5062, 80.6480],
    'tirupati': [13.6288, 79.4192],
    'hyderabad': [17.3850, 78.4867],
    'visakhapatnam': [17.6868, 83.2185],
    'chennai': [13.0827, 80.2707],
    'bengaluru': [12.9716, 77.5946],
  };

  static double getRouteDistanceKm(String pickup, String destination) {
    final pClean = pickup.toLowerCase().trim();
    final dClean = destination.toLowerCase().trim();

    double? pLat, pLng, dLat, dLng;

    for (var entry in knownCoordinates.entries) {
      if (pClean.contains(entry.key)) {
        pLat = entry.value[0];
        pLng = entry.value[1];
      }
      if (dClean.contains(entry.key)) {
        dLat = entry.value[0];
        dLng = entry.value[1];
      }
    }

    if (pLat != null && dLat != null) {
      final distance = _calculateHaversine(pLat, pLng!, dLat, dLng!);
      return max(2.5, (distance * 10).roundToDouble() / 10);
    }

    // Deterministic hash fallback
    final hash = (pClean.hashCode.abs() + dClean.hashCode.abs()) % 15;
    return max(3.5, 6.0 + hash);
  }

  static double _calculateHaversine(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  static int getEstimatedDurationMinutes(double distanceKm) {
    return max(5, (distanceKm * 2.2).round());
  }

  static double getDemandMultiplier({DateTime? dateTime}) {
    final dt = dateTime ?? DateTime.now();
    final hour = dt.hour;
    if ((hour >= 7 && hour <= 10) || (hour >= 17 && hour <= 21)) {
      return 1.15; // Peak hour
    }
    return 1.00;
  }

  static List<RideQuoteModel> calculateAllQuotes({
    required String pickup,
    required String destination,
    required int passengerCount,
    DateTime? dateTime,
  }) {
    final distanceKm = getRouteDistanceKm(pickup, destination);
    final durationMins = getEstimatedDurationMinutes(distanceKm);
    final multiplier = getDemandMultiplier(dateTime: dateTime);

    return RideType.values.map((type) {
      return calculateQuote(
        type: type,
        distanceKm: distanceKm,
        durationMins: durationMins,
        passengerCount: passengerCount,
        multiplier: multiplier,
      );
    }).toList();
  }

  static RideQuoteModel calculateQuote({
    required RideType type,
    required double distanceKm,
    required int durationMins,
    required int passengerCount,
    required double multiplier,
  }) {
    double baseFare;
    double perKm;
    double perMin;
    double platformFee;
    int arrivalMins;

    switch (type) {
      case RideType.bike:
        baseFare = 20.0;
        perKm = 6.0;
        perMin = 1.0;
        platformFee = 3.0;
        arrivalMins = 3;
        break;
      case RideType.auto:
        baseFare = 30.0;
        perKm = 9.0;
        perMin = 1.5;
        platformFee = 5.0;
        arrivalMins = 4;
        break;
      case RideType.miniCab:
        baseFare = 50.0;
        perKm = 12.0;
        perMin = 2.0;
        platformFee = 12.0;
        arrivalMins = 5;
        break;
      case RideType.sedanCab:
        baseFare = 80.0;
        perKm = 16.0;
        perMin = 2.5;
        platformFee = 18.0;
        arrivalMins = 6;
        break;
      case RideType.premiumCab:
        baseFare = 120.0;
        perKm = 22.0;
        perMin = 3.0;
        platformFee = 25.0;
        arrivalMins = 8;
        break;
    }

    final distanceFare = distanceKm * perKm;
    final timeFare = durationMins * perMin;
    final subtotal = baseFare + distanceFare + timeFare + platformFee;
    final estimatedTotal = (subtotal * multiplier).roundToDouble();

    final isAvailable = passengerCount <= type.maxPassengers;
    String? unavailableMessage;
    if (!isAvailable) {
      if (type == RideType.bike) {
        unavailableMessage = 'Max 1 passenger for Bike';
      } else if (type == RideType.auto) {
        unavailableMessage = 'Max 3 passengers for Auto';
      } else {
        unavailableMessage = 'Max 4 passengers for Cab';
      }
    }

    return RideQuoteModel(
      rideType: type,
      routeDistanceKm: distanceKm,
      estimatedDurationMinutes: durationMins,
      baseFare: baseFare,
      distanceFare: distanceFare,
      timeFare: timeFare,
      demandMultiplier: multiplier,
      platformFee: platformFee,
      estimatedTotal: estimatedTotal,
      driverArrivalMinutes: arrivalMins,
      isAvailable: isAvailable,
      unavailableMessage: unavailableMessage,
    );
  }
}
