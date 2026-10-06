import '../models/travel_data.dart';

abstract class HotelRepository {
  Future<List<HotelItem>> getHotelsByDestination(String destinationName);
  Future<HotelItem?> getHotelById(String title);
}

class MockHotelRepository implements HotelRepository {
  @override
  Future<List<HotelItem>> getHotelsByDestination(String destinationName) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final String query = destinationName.trim().toLowerCase();

    // NARASARAOPET HOTELS
    if (query.contains('narasaraopet')) {
      return [
        const HotelItem(
          title: 'Hotel Grand Palnadu',
          distance: 'Palnadu Road, Narasaraopet (1.2 KM)',
          rating: 4.6,
          price: '₹2,400 / night',
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Premier executive hotel in Narasaraopet offering air-conditioned suites, multi-cuisine restaurant, and 24-hour room service.',
          roomCategories: [
            RoomCategory(
              categoryName: 'Executive Deluxe AC Room',
              price: '₹2,400 / night',
              numericPrice: 2400.0,
              bedInfo: 'King Size Bed • 2 Adults',
              roomPhotos: [
                'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800',
                'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
              ],
              roomAmenities: [
                'Free High-Speed Wi-Fi',
                '24/7 Room Service',
                '24/7 Hot Water & Geyser',
                'Air Conditioning (AC)',
                'Flat LED TV',
              ],
            ),
            RoomCategory(
              categoryName: 'Royal Family Suite',
              price: '₹3,800 / night',
              numericPrice: 3800.0,
              bedInfo: '2 Double Beds • 4 Guests',
              roomPhotos: [
                'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
              ],
              roomAmenities: [
                'Free High-Speed Wi-Fi',
                '24/7 Room Service',
                '24/7 Hot Water Shower',
                'Air Conditioning (AC)',
                'Complimentary Breakfast',
              ],
            ),
          ],
        ),
        const HotelItem(
          title: 'Sri Surya Regency',
          distance: 'Clock Tower Center, Narasaraopet (0.5 KM)',
          rating: 4.4,
          price: '₹1,800 / night',
          imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
          description: 'Comfortable budget-friendly lodging situated in the heart of Narasaraopet close to railway and bus stations.',
          roomCategories: [
            RoomCategory(
              categoryName: 'Standard AC Room',
              price: '₹1,800 / night',
              numericPrice: 1800.0,
              bedInfo: 'Double Bed • 2 Guests',
              roomPhotos: [
                'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800',
              ],
              roomAmenities: [
                'Free Wi-Fi',
                '24/7 Hot Water',
                'Air Conditioning',
                '24/7 Room Service',
              ],
            ),
          ],
        ),
      ];
    }

    // GUNTUR HOTELS
    if (query.contains('guntur')) {
      return [
        const HotelItem(
          title: 'Ramee Grand Hotel Guntur',
          distance: 'Ring Road, Guntur (2.5 KM)',
          rating: 4.7,
          price: '₹3,500 / night',
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          description: 'Luxury hotel in Guntur featuring elegant accommodations, swimming pool, fine dining, and conference facilities.',
          roomCategories: [
            RoomCategory(
              categoryName: 'Deluxe Suite',
              price: '₹3,500 / night',
              numericPrice: 3500.0,
              bedInfo: '1 King Bed • 2 Guests',
              roomPhotos: [
                'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800',
              ],
              roomAmenities: [
                'Free Wi-Fi',
                '24/7 Room Service',
                'Hot Water',
                'AC',
                'TV',
                'Complimentary Breakfast',
              ],
            ),
          ],
        ),
      ];
    }

    // Default Tirupati Hotels
    return TravelData.hotels;
  }

  @override
  Future<HotelItem?> getHotelById(String title) async {
    final list = await getHotelsByDestination('Narasaraopet');
    try {
      return list.firstWhere((h) => h.title == title);
    } catch (e) {
      return null;
    }
  }
}
