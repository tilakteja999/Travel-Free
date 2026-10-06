import 'package:flutter/foundation.dart';
import '../models/ride_booking_model.dart';
import '../models/ride_category.dart';
import '../models/ride_quote_model.dart';
import '../models/ride_status.dart';
import '../models/ride_type.dart';
import '../repositories/local_ride_repository.dart';
import '../repositories/ride_repository.dart';
import '../services/ride_fare_calculator.dart';
import '../services/simulated_driver_service.dart';

class RideProvider extends ChangeNotifier {
  final RideRepository _repository = LocalRideRepository();

  RideCategory _selectedCategory = RideCategory.autoBike;
  RideType? _selectedRideType;
  List<RideQuoteModel> _quotes = [];
  bool _isLoadingQuotes = false;

  RideBookingModel? _activeBooking;
  List<RideBookingModel> _userRides = [];

  RideCategory get selectedCategory => _selectedCategory;
  RideType? get selectedRideType => _selectedRideType;
  List<RideQuoteModel> get quotes => _quotes;
  bool get isLoadingQuotes => _isLoadingQuotes;
  RideBookingModel? get activeBooking => _activeBooking;
  List<RideBookingModel> get userRides => _userRides;

  void selectCategory(RideCategory category) {
    _selectedCategory = category;
    // Auto-select first available ride type in category
    final available = _quotes.where((q) => q.rideType.category == category && q.isAvailable).toList();
    if (available.isNotEmpty) {
      _selectedRideType = available.first.rideType;
    } else {
      _selectedRideType = null;
    }
    notifyListeners();
  }

  void selectRideType(RideType type) {
    _selectedRideType = type;
    _selectedCategory = type.category;
    notifyListeners();
  }

  void loadQuotes({
    required String pickup,
    required String destination,
    required int passengerCount,
    RideCategory? defaultCategory,
  }) {
    _isLoadingQuotes = true;
    notifyListeners();

    if (defaultCategory != null) {
      _selectedCategory = defaultCategory;
    }

    _quotes = RideFareCalculator.calculateAllQuotes(
      pickup: pickup,
      destination: destination,
      passengerCount: passengerCount,
    );

    final visible = _quotes.where((q) => q.rideType.category == _selectedCategory && q.isAvailable).toList();
    if (visible.isNotEmpty) {
      _selectedRideType = visible.first.rideType;
    } else {
      _selectedRideType = null;
    }

    _isLoadingQuotes = false;
    notifyListeners();
  }

  Future<RideBookingModel> createBooking({
    required String userId,
    required RideType rideType,
    required String pickup,
    required String destination,
    required RideQuoteModel quote,
    String paymentMethod = 'Cash (Demo)',
  }) async {
    final rideId = 'TRV-RIDE-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final booking = RideBookingModel(
      id: rideId,
      userId: userId,
      status: RideStatus.searchingDriver,
      rideType: rideType,
      pickupName: pickup,
      destinationName: destination,
      pickupLatitude: 16.2350,
      pickupLongitude: 80.0500,
      destinationLatitude: 16.5062,
      destinationLongitude: 80.6480,
      createdAt: DateTime.now(),
      routeDistanceKm: quote.routeDistanceKm,
      estimatedDurationMinutes: quote.estimatedDurationMinutes,
      estimatedFare: quote.estimatedTotal,
      paymentMethod: paymentMethod,
      isDemoRide: true,
    );

    _activeBooking = booking;
    await _repository.saveRide(booking);
    notifyListeners();
    return booking;
  }

  Future<void> simulateDriverAssignment(String rideId) async {
    if (_activeBooking == null || _activeBooking!.id != rideId) return;

    final driver = SimulatedDriverService.findMatchingDriver(_activeBooking!.rideType);
    if (driver != null) {
      _activeBooking = _activeBooking!.copyWith(
        status: RideStatus.driverAssigned,
        acceptedAt: DateTime.now(),
        driver: driver,
      );
      await _repository.saveRide(_activeBooking!);
      notifyListeners();
    } else {
      _activeBooking = _activeBooking!.copyWith(
        status: RideStatus.noDriverFound,
      );
      await _repository.saveRide(_activeBooking!);
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus(RideStatus newStatus) async {
    if (_activeBooking == null) return;

    DateTime? arrived, started, completed, cancelled;
    if (newStatus == RideStatus.driverArrived) arrived = DateTime.now();
    if (newStatus == RideStatus.tripStarted) started = DateTime.now();
    if (newStatus == RideStatus.tripCompleted) completed = DateTime.now();
    if (newStatus == RideStatus.cancelled) cancelled = DateTime.now();

    _activeBooking = _activeBooking!.copyWith(
      status: newStatus,
      arrivedAt: arrived ?? _activeBooking!.arrivedAt,
      tripStartedAt: started ?? _activeBooking!.tripStartedAt,
      completedAt: completed ?? _activeBooking!.completedAt,
      cancelledAt: cancelled ?? _activeBooking!.cancelledAt,
      finalFare: newStatus == RideStatus.tripCompleted ? _activeBooking!.estimatedFare : _activeBooking!.finalFare,
    );

    await _repository.saveRide(_activeBooking!);
    notifyListeners();
  }

  Future<void> cancelBooking(String reason, double fee) async {
    if (_activeBooking == null) return;

    _activeBooking = _activeBooking!.copyWith(
      status: RideStatus.cancelled,
      cancelledAt: DateTime.now(),
      cancellationReason: reason,
      cancellationFee: fee,
    );

    await _repository.saveRide(_activeBooking!);
    notifyListeners();
  }

  Future<void> loadUserRides(String userId) async {
    _userRides = await _repository.getUserRides(userId);
    notifyListeners();
  }
}
