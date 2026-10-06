enum RideCategory {
  autoBike,
  cab,
}

extension RideCategoryX on RideCategory {
  String get label {
    switch (this) {
      case RideCategory.autoBike:
        return 'Auto & Bike';
      case RideCategory.cab:
        return 'Cab';
    }
  }

  String get subtitle {
    switch (this) {
      case RideCategory.autoBike:
        return 'Quick rides for short city travel';
      case RideCategory.cab:
        return 'Comfortable cars for longer trips';
    }
  }
}
