import 'package:flutter/material.dart';
import '../models/itinerary_model.dart';
import '../repositories/local_itinerary_repository.dart';
import '../services/auth_service.dart';

class ItineraryProvider with ChangeNotifier {
  final ItineraryRepository _repository = LocalItineraryRepository();

  List<ItineraryModel> _itineraries = [];
  bool _isLoading = false;

  List<ItineraryModel> get itineraries => _itineraries;
  bool get isLoading => _isLoading;

  String get _currentUserId => AuthService().getActiveUserIdentifier() ?? 'user@travel.com';

  Future<void> fetchItineraries() async {
    _isLoading = true;
    notifyListeners();

    _itineraries = await _repository.getItinerariesForUser(_currentUserId);
    _isLoading = false;
    notifyListeners();
  }

  Future<ItineraryModel> saveItinerary(ItineraryModel itinerary) async {
    final saved = await _repository.saveItinerary(itinerary);
    await fetchItineraries();
    return saved;
  }

  Future<bool> deleteItinerary(String id) async {
    final success = await _repository.deleteItinerary(_currentUserId, id);
    if (success) {
      await fetchItineraries();
    }
    return success;
  }
}
