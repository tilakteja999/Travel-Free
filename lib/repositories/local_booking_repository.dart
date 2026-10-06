import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';
import '../services/auth_service.dart';
import '../services/local_availability_service.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getBookingsForUser(String userId);
  Future<BookingModel> saveBooking(BookingModel booking);
  Future<bool> cancelBooking(String userId, String bookingId, String reason);
  Future<void> updateBookingStatus(String userId, String bookingId, BookingStatus newStatus);
}

class LocalBookingRepository implements BookingRepository {
  static const String _prefix = 'tt_bookings_';

  String _key(String userId) => '$_prefix${userId.toLowerCase()}';

  @override
  Future<List<BookingModel>> getBookingsForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));

    if (raw == null || raw.isEmpty) {
      // Return default seed bookings if empty
      final seeds = _generateSeedBookings(userId);
      await _saveList(userId, seeds, prefs);
      return seeds;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<BookingModel> saveBooking(BookingModel booking) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBookingsForUser(booking.userId);

    final String refId = booking.bookingId.isNotEmpty
        ? booking.bookingId
        : _generateBookingId(booking.bookingType);

    final String txnId = booking.localTransactionId ?? 'DEMO-TXN-${Random().nextInt(89999999) + 10000000}';

    final updatedBooking = booking.copyWith(
      status: booking.status,
      localTransactionId: txnId,
    );

    list.removeWhere((b) => b.bookingId == refId);
    list.insert(0, updatedBooking);

    await _saveList(booking.userId, list, prefs);

    // Lock seat or room availability locally
    if (updatedBooking.status == BookingStatus.confirmed) {
      final availability = LocalAvailabilityService();
      if (updatedBooking.bookingType == BookingType.hotel && updatedBooking.selectedRoomIds.isNotEmpty) {
        for (var room in updatedBooking.selectedRoomIds) {
          await availability.lockRoom(room);
        }
      } else if (updatedBooking.selectedSeatIds.isNotEmpty) {
        for (var seat in updatedBooking.selectedSeatIds) {
          await availability.lockSeat(seat);
        }
      }
    }

    return updatedBooking;
  }

  @override
  Future<bool> cancelBooking(String userId, String bookingId, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBookingsForUser(userId);

    final index = list.indexWhere((b) => b.bookingId == bookingId);
    if (index == -1) return false;

    final target = list[index];
    if (target.status == BookingStatus.completed) return false;

    final double refund = target.totalAmount; // 100% refund in demo
    final cancelledBooking = target.copyWith(
      status: BookingStatus.cancelled,
      cancellationReason: reason,
      refundEstimate: refund,
    );

    list[index] = cancelledBooking;
    await _saveList(userId, list, prefs);

    // Release seat/room inventory
    final availability = LocalAvailabilityService();
    if (target.selectedRoomIds.isNotEmpty) {
      for (var room in target.selectedRoomIds) {
        await availability.releaseRoom(room);
      }
    }
    if (target.selectedSeatIds.isNotEmpty) {
      for (var seat in target.selectedSeatIds) {
        await availability.releaseSeat(seat);
      }
    }

    return true;
  }

  @override
  Future<void> updateBookingStatus(String userId, String bookingId, BookingStatus newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBookingsForUser(userId);

    final index = list.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      list[index] = list[index].copyWith(status: newStatus);
      await _saveList(userId, list, prefs);
    }
  }

  Future<void> _saveList(String userId, List<BookingModel> list, SharedPreferences prefs) async {
    final raw = jsonEncode(list.map((b) => b.toJson()).toList());
    await prefs.setString(_key(userId), raw);
  }

  String _generateBookingId(BookingType type) {
    final rand = Random().nextInt(89999) + 10000;
    switch (type) {
      case BookingType.hotel:
        return 'TRV-HTL-$rand';
      case BookingType.auto:
      case BookingType.cab:
        return 'TRV-RIDE-$rand';
      default:
        return 'TRV-TRA-$rand';
    }
  }

  List<BookingModel> _generateSeedBookings(String userId) {
    return [
      BookingModel(
        bookingId: 'TRV-TRA-84920',
        userId: userId,
        bookingType: BookingType.train,
        status: BookingStatus.confirmed,
        fromLocation: 'Narasaraopet',
        toLocation: 'Tirupati',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        departureDateTime: DateTime.now().add(const Duration(days: 12)),
        passengers: const [
          PassengerModel(name: 'Tilak Teja', age: 24, gender: 'Male', seatOrRoomCode: 'B1-19'),
          PassengerModel(name: 'Ananya Rao', age: 22, gender: 'Female', seatOrRoomCode: 'B1-20'),
        ],
        selectedSeatIds: const ['B1-19', 'B1-20'],
        baseFare: 2400.0,
        taxes: 120.0,
        convenienceFee: 15.0,
        totalAmount: 2535.0,
        paymentMethod: 'UPI (Demo)',
        localTransactionId: 'DEMO-TXN-84920123',
      ),
      BookingModel(
        bookingId: 'TRV-HTL-19402',
        userId: userId,
        bookingType: BookingType.hotel,
        status: BookingStatus.completed,
        fromLocation: 'Vijayawada',
        toLocation: 'Vijayawada',
        hotelId: 'lotus_grand',
        hotelName: 'Lotus Grand Hotel & Restaurant',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        checkInDate: DateTime.now().subtract(const Duration(days: 20)),
        checkOutDate: DateTime.now().subtract(const Duration(days: 18)),
        passengers: const [
          PassengerModel(name: 'Tilak Teja', age: 24, gender: 'Male', seatOrRoomCode: 'Room 101'),
        ],
        selectedRoomIds: const ['Room 101'],
        baseFare: 4800.0,
        taxes: 240.0,
        convenienceFee: 15.0,
        totalAmount: 5055.0,
        paymentMethod: 'Card (Demo)',
        localTransactionId: 'DEMO-TXN-19402981',
      ),
    ];
  }
}
