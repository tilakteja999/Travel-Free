import '../services/local_availability_service.dart';

abstract class AvailabilityRepository {
  Future<Set<String>> getBookedSeats(String transportId, String date, String routeKey);
  Future<void> bookSeats(String transportId, String date, String routeKey, List<String> seatNumbers, String bookingId);
  Future<void> releaseSeats(String transportId, String date, String routeKey, List<String> seatNumbers);

  Future<Set<String>> getBookedRooms(String hotelId, String checkInDate);
  Future<void> bookRooms(String hotelId, String checkInDate, List<String> roomNumbers, String bookingId);
  Future<void> releaseRooms(String hotelId, String checkInDate, List<String> roomNumbers);
}

class LocalAvailabilityRepository implements AvailabilityRepository {
  final LocalAvailabilityService _service = LocalAvailabilityService();

  @override
  Future<Set<String>> getBookedSeats(String transportId, String date, String routeKey) {
    return _service.getBookedSeats(transportId, date, routeKey);
  }

  @override
  Future<void> bookSeats(String transportId, String date, String routeKey, List<String> seatNumbers, String bookingId) {
    return _service.bookSeats(transportId, date, routeKey, seatNumbers, bookingId);
  }

  @override
  Future<void> releaseSeats(String transportId, String date, String routeKey, List<String> seatNumbers) {
    return _service.releaseSeats(transportId, date, routeKey, seatNumbers);
  }

  @override
  Future<Set<String>> getBookedRooms(String hotelId, String checkInDate) {
    return _service.getBookedRooms(hotelId, checkInDate);
  }

  @override
  Future<void> bookRooms(String hotelId, String checkInDate, List<String> roomNumbers, String bookingId) {
    return _service.bookRooms(hotelId, checkInDate, roomNumbers, bookingId);
  }

  @override
  Future<void> releaseRooms(String hotelId, String checkInDate, List<String> roomNumbers) {
    return _service.releaseRooms(hotelId, checkInDate, roomNumbers);
  }
}
