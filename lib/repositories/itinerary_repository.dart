import '../models/itinerary_model.dart';

abstract class ItineraryRepository {
  Future<List<ItineraryModel>> getUserItineraries(String userId);
  Future<ItineraryModel?> getItineraryById(String userId, String id);
  Future<void> saveItinerary(ItineraryModel itinerary);
  Future<void> deleteItinerary(String userId, String id);
}
