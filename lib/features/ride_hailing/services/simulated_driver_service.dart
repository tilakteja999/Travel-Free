import 'dart:math';
import '../models/ride_driver_model.dart';
import '../models/ride_type.dart';

class SimulatedDriverService {
  static final List<RideDriverModel> demoDrivers = [
    const RideDriverModel(
      id: 'drv_bike_1',
      name: 'Kiran',
      supportedRideType: RideType.bike,
      vehicleName: 'Hero Splendor Plus (Black)',
      vehicleNumber: 'AP 07 BK 1234',
      rating: 4.7,
      completedTrips: 620,
      language: 'Telugu, English',
      latitude: 16.2370,
      longitude: 80.0520,
    ),
    const RideDriverModel(
      id: 'drv_auto_1',
      name: 'Ravi Kumar',
      supportedRideType: RideType.auto,
      vehicleName: 'Bajaj RE Auto (Yellow/Green)',
      vehicleNumber: 'AP 07 TX 4582',
      rating: 4.8,
      completedTrips: 1284,
      language: 'Telugu, Hindi, English',
      latitude: 16.2380,
      longitude: 80.0530,
    ),
    const RideDriverModel(
      id: 'drv_mini_1',
      name: 'Suresh Reddy',
      supportedRideType: RideType.miniCab,
      vehicleName: 'Maruti WagonR (White)',
      vehicleNumber: 'AP 16 AB 9274',
      rating: 4.7,
      completedTrips: 956,
      language: 'Telugu, English',
      latitude: 16.2390,
      longitude: 80.0540,
    ),
    const RideDriverModel(
      id: 'drv_sedan_1',
      name: 'Anil Kumar',
      supportedRideType: RideType.sedanCab,
      vehicleName: 'Maruti Dzire (Silver)',
      vehicleNumber: 'TS 09 CD 4521',
      rating: 4.9,
      completedTrips: 2105,
      language: 'Telugu, Hindi, English',
      latitude: 16.2400,
      longitude: 80.0550,
    ),
    const RideDriverModel(
      id: 'drv_premium_1',
      name: 'Prakash',
      supportedRideType: RideType.premiumCab,
      vehicleName: 'Toyota Innova Crysta (Black)',
      vehicleNumber: 'AP 09 PR 7890',
      rating: 4.9,
      completedTrips: 1876,
      language: 'Telugu, English, Hindi',
      latitude: 16.2410,
      longitude: 80.0560,
    ),
  ];

  static RideDriverModel? findMatchingDriver(RideType rideType) {
    final matches = demoDrivers.where((d) => d.supportedRideType == rideType).toList();
    if (matches.isNotEmpty) {
      return matches[Random().nextInt(matches.length)];
    }
    return null;
  }
}
