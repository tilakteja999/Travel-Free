import '../models/travel_data.dart';

abstract class TransportRepository {
  Future<List<TransportItem>> getTransportOffers(String from, String to);
}

class MockTransportRepository implements TransportRepository {
  @override
  Future<List<TransportItem>> getTransportOffers(String from, String to) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return [
      TransportItem(
        name: 'Palnadu Express ($from → $to)',
        type: 'Train',
        numberOrVehicle: '12748 - Express',
        timing: '06:10 AM -> 11:45 AM (5h 35m)',
        price: '₹380',
        rating: 4.6,
        badgeText: 'Daily',
      ),
      TransportItem(
        name: 'APSRTC Garuda Super Luxury',
        type: 'Bus',
        numberOrVehicle: 'AP 07 Z 4512',
        timing: '08:30 AM -> 02:00 PM (5h 30m)',
        price: '₹550',
        rating: 4.7,
        badgeText: 'AC Seater',
      ),
    ];
  }
}
