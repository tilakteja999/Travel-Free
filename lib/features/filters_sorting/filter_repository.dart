import '../../models/travel_data.dart';
import 'filter_model.dart';

class FilterRepository {
  static List<HotelItem> applyHotelFilters(List<HotelItem> hotels, FilterModel filters) {
    List<HotelItem> filtered = hotels.where((hotel) {
      // Parse price
      final digits = hotel.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double priceVal = double.tryParse(digits) ?? 0.0;

      if (priceVal < filters.minPrice || priceVal > filters.maxPrice) {
        return false;
      }

      // Star rating filter
      if (filters.selectedStars.isNotEmpty) {
        final stars = hotel.rating.floor();
        if (!filters.selectedStars.contains(stars)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    switch (filters.sortBy) {
      case 'price_asc':
        filtered.sort((a, b) {
          final pA = double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          final pB = double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          return pA.compareTo(pB);
        });
        break;
      case 'price_desc':
        filtered.sort((a, b) {
          final pA = double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          final pB = double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          return pB.compareTo(pA);
        });
        break;
      case 'rating_desc':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return filtered;
  }

  static List<PlaceItem> applyPlaceFilters(List<PlaceItem> places, FilterModel filters) {
    List<PlaceItem> filtered = List.from(places);

    if (filters.selectedStars.isNotEmpty) {
      filtered = filtered.where((p) => filters.selectedStars.contains(p.rating.floor())).toList();
    }

    if (filters.sortBy == 'rating_desc') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return filtered;
  }

  static List<TransportItem> applyTransportFilters(List<TransportItem> items, FilterModel filters) {
    List<TransportItem> filtered = items.where((item) {
      final digits = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double priceVal = double.tryParse(digits) ?? 0.0;

      if (priceVal < filters.minPrice || priceVal > filters.maxPrice) {
        return false;
      }

      if (filters.isAcOnly) {
        final text = '${item.name} ${item.badgeText} ${item.numberOrVehicle}'.toLowerCase();
        if (!text.contains('ac') && !text.contains('air condition')) {
          return false;
        }
      }

      if (filters.isSleeperOnly) {
        final text = '${item.name} ${item.badgeText} ${item.numberOrVehicle}'.toLowerCase();
        if (!text.contains('sleeper')) {
          return false;
        }
      }

      if (filters.transportType != null && filters.transportType!.isNotEmpty) {
        if (item.type.toLowerCase() != filters.transportType!.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();

    switch (filters.sortBy) {
      case 'price_asc':
        filtered.sort((a, b) {
          final pA = double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          final pB = double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          return pA.compareTo(pB);
        });
        break;
      case 'price_desc':
        filtered.sort((a, b) {
          final pA = double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          final pB = double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          return pB.compareTo(pA);
        });
        break;
      case 'rating_desc':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return filtered;
  }
}
