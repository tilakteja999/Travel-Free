import 'ride_category.dart';

enum RideType {
  bike,
  auto,
  miniCab,
  sedanCab,
  premiumCab,
}

extension RideTypeX on RideType {
  RideCategory get category {
    switch (this) {
      case RideType.bike:
      case RideType.auto:
        return RideCategory.autoBike;

      case RideType.miniCab:
      case RideType.sedanCab:
      case RideType.premiumCab:
        return RideCategory.cab;
    }
  }

  String get label {
    switch (this) {
      case RideType.bike:
        return 'Bike';
      case RideType.auto:
        return 'Auto';
      case RideType.miniCab:
        return 'Mini Cab';
      case RideType.sedanCab:
        return 'Sedan';
      case RideType.premiumCab:
        return 'Premium Cab';
    }
  }

  String get description {
    switch (this) {
      case RideType.bike:
        return 'Fastest ride for one passenger';
      case RideType.auto:
        return 'Affordable ride for up to 3 passengers';
      case RideType.miniCab:
        return 'Affordable compact car';
      case RideType.sedanCab:
        return 'Comfortable sedan ride';
      case RideType.premiumCab:
        return 'Premium comfort ride';
    }
  }

  int get maxPassengers {
    switch (this) {
      case RideType.bike:
        return 1;
      case RideType.auto:
        return 3;
      case RideType.miniCab:
      case RideType.sedanCab:
      case RideType.premiumCab:
        return 4;
    }
  }
}
