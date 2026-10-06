import '../models/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<BookingModel?> getBookingById(String userId, String bookingId);
  Future<void> saveBooking(BookingModel booking);
  Future<void> updateBookingStatus(String userId, String bookingId, BookingStatus newStatus, {String? reason, double? refund});
}
