enum RideStatus {
  draft,
  quoteReady,
  searchingDriver,
  driverAssigned,
  driverArriving,
  driverArrived,
  tripStarted,
  tripCompleted,
  cancelled,
  noDriverFound,
}

extension RideStatusX on RideStatus {
  String get displayName {
    switch (this) {
      case RideStatus.draft:
        return 'Draft';
      case RideStatus.quoteReady:
        return 'Quote Ready';
      case RideStatus.searchingDriver:
        return 'Finding Driver';
      case RideStatus.driverAssigned:
        return 'Driver Assigned';
      case RideStatus.driverArriving:
        return 'Driver Arriving';
      case RideStatus.driverArrived:
        return 'Driver Arrived';
      case RideStatus.tripStarted:
        return 'Trip Started';
      case RideStatus.tripCompleted:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
      case RideStatus.noDriverFound:
        return 'No Driver Available';
    }
  }
}
