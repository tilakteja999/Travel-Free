class LatLngPoint {
  final double latitude;
  final double longitude;

  const LatLngPoint(this.latitude, this.longitude);
}

class SimulatedRideTrackingService {
  static LatLngPoint interpolate(LatLngPoint start, LatLngPoint end, double fraction) {
    final clamped = fraction.clamp(0.0, 1.0);
    final lat = start.latitude + (end.latitude - start.latitude) * clamped;
    final lng = start.longitude + (end.longitude - start.longitude) * clamped;
    return LatLngPoint(lat, lng);
  }

  static double calculateDistanceKm(LatLngPoint p1, LatLngPoint p2) {
    final dLat = (p2.latitude - p1.latitude).abs();
    final dLng = (p2.longitude - p1.longitude).abs();
    return ((dLat + dLng) * 111.0).clamp(0.1, 50.0);
  }
}
