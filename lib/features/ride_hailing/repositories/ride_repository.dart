import '../models/ride_booking_model.dart';
import '../models/ride_feedback_model.dart';

abstract class RideRepository {
  Future<List<RideBookingModel>> getUserRides(String userId);
  Future<RideBookingModel?> getRideById(String userId, String rideId);
  Future<void> saveRide(RideBookingModel ride);
  Future<void> updateRideStatus(String userId, String rideId, RideBookingModel updated);

  Future<void> saveFeedback(RideFeedbackModel feedback);
  Future<RideFeedbackModel?> getFeedbackByRideId(String userId, String rideId);

  Future<List<String>> getChatMessages(String rideId);
  Future<void> addChatMessage(String rideId, String message);
}
