import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../repositories/local_booking_repository.dart';
import '../services/auth_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingRepository _repository = LocalBookingRepository();

  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  String get _currentUserId => AuthService().getActiveUserIdentifier() ?? 'user@travel.com';

  Future<void> fetchBookings() async {
    _isLoading = true;
    notifyListeners();

    _bookings = await _repository.getBookingsForUser(_currentUserId);
    _isLoading = false;
    notifyListeners();
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    final saved = await _repository.saveBooking(booking);
    await fetchBookings();
    return saved;
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    final success = await _repository.cancelBooking(_currentUserId, bookingId, reason);
    if (success) {
      await fetchBookings();
    }
    return success;
  }

  Future<void> completeRideBooking({
    required String bookingId,
    required String fromLocation,
    required String toLocation,
    required double totalAmount,
    required String vehicleType,
  }) async {
    final rideBooking = BookingModel(
      bookingId: bookingId,
      userId: _currentUserId,
      bookingType: vehicleType.toLowerCase().contains('auto') ? BookingType.auto : BookingType.cab,
      status: BookingStatus.completed,
      fromLocation: fromLocation,
      toLocation: toLocation,
      createdAt: DateTime.now(),
      departureDateTime: DateTime.now(),
      passengers: const [PassengerModel(name: 'Traveler', age: 25, gender: 'Male')],
      baseFare: totalAmount - 15.0,
      convenienceFee: 15.0,
      totalAmount: totalAmount,
      paymentMethod: 'UPI (Demo)',
      localTransactionId: 'DEMO-RIDE-${DateTime.now().millisecondsSinceEpoch}',
    );

    await createBooking(rideBooking);
  }
}
