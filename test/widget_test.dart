import 'package:flutter_test/flutter_test.dart';
import 'package:travel/features/date_time_selection/travel_search_model.dart';
import 'package:travel/features/filters_sorting/filter_model.dart';
import 'package:travel/features/filters_sorting/filter_repository.dart';
import 'package:travel/models/travel_data.dart';

void main() {
  group('TravelSearchModel Date Tests', () {
    test('Hotel check-in 29 Oct 2026 and check-out 31 Oct 2026 produces 2 nights and 3 days', () {
      final checkIn = DateTime(2026, 10, 29);
      final checkOut = DateTime(2026, 10, 31);

      final model = TravelSearchModel(
        fromLocation: 'Narasaraopet',
        toLocation: 'Tirupati',
        hotelCheckIn: checkIn,
        hotelCheckOut: checkOut,
        searchType: 'hotel',
      );

      expect(model.hotelNights, equals(2));
      expect(model.hotelDays, equals(3));
      expect(
        TravelSearchModel.formatDateRange(model.hotelCheckIn, model.hotelCheckOut),
        equals('29 Oct 2026 - 31 Oct 2026 (2 Nights - 3 Days)'),
      );
    });

    test('Missing hotel dates produce null for hotelNights', () {
      const model = TravelSearchModel(
        fromLocation: 'Narasaraopet',
        toLocation: 'Tirupati',
        searchType: 'hotel',
      );

      expect(model.hotelNights, isNull);
      expect(model.hotelDays, isNull);
      expect(
        TravelSearchModel.formatDateRange(model.hotelCheckIn, model.hotelCheckOut),
        equals('Select check-in and check-out dates'),
      );
    });

    test('Selecting 29 Oct 2026 preserves date after copyWith', () {
      final dep = DateTime(2026, 10, 29);
      final model = TravelSearchModel(
        fromLocation: 'Narasaraopet',
        toLocation: 'Tirupati',
        departureDate: dep,
        searchType: 'transport',
      );

      final copied = model.copyWith(toLocation: 'Vijayawada');

      expect(copied.departureDate, equals(dep));
      expect(TravelSearchModel.formatTravelDate(copied.departureDate), equals('29 Oct 2026'));
    });
  });

  group('FilterRepository Tests', () {
    final List<HotelItem> mockHotels = [
      const HotelItem(
        title: 'Grand Palace Hotel',
        distance: '1.2 km',
        price: '₹3,500 / night',
        rating: 4.8,
        imageUrl: 'https://example.com/1.jpg',
        description: 'Luxury stay',
        roomCategories: [],
      ),
      const HotelItem(
        title: 'Budget Lodge',
        distance: '3.0 km',
        price: '₹1,200 / night',
        rating: 3.5,
        imageUrl: 'https://example.com/2.jpg',
        description: 'Affordable stay',
        roomCategories: [],
      ),
      const HotelItem(
        title: 'Luxury Resort',
        distance: '0.5 km',
        price: '₹8,000 / night',
        rating: 5.0,
        imageUrl: 'https://example.com/3.jpg',
        description: 'Premium resort',
        roomCategories: [],
      ),
    ];

    test('Applying price low-to-high sorts list correctly', () {
      const filter = FilterModel(sortBy: 'price_asc');
      final sorted = FilterRepository.applyHotelFilters(mockHotels, filter);

      expect(sorted[0].title, equals('Budget Lodge'));
      expect(sorted[1].title, equals('Grand Palace Hotel'));
      expect(sorted[2].title, equals('Luxury Resort'));
    });

    test('Applying price high-to-low sorts list correctly', () {
      const filter = FilterModel(sortBy: 'price_desc');
      final sorted = FilterRepository.applyHotelFilters(mockHotels, filter);

      expect(sorted[0].title, equals('Luxury Resort'));
      expect(sorted[1].title, equals('Grand Palace Hotel'));
      expect(sorted[2].title, equals('Budget Lodge'));
    });

    test('Applying star rating filter removes nonmatching hotels', () {
      const filter = FilterModel(selectedStars: {5});
      final filtered = FilterRepository.applyHotelFilters(mockHotels, filter);

      expect(filtered.length, equals(1));
      expect(filtered[0].title, equals('Luxury Resort'));
    });

    test('Active filter count is calculated correctly', () {
      const filter = FilterModel(
        minPrice: 1000,
        maxPrice: 5000,
        selectedStars: {4, 5},
        sortBy: 'price_asc',
      );

      expect(filter.hasActiveFilters, isTrue);
      expect(filter.activeFilterCount, equals(3));
    });
  });
}
