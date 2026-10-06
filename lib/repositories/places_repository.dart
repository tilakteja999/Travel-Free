import '../models/travel_data.dart';

abstract class PlacesRepository {
  Future<List<PlaceItem>> getPlacesByDestination(String destinationName);
  Future<PlaceItem?> getPlaceById(String title);
}

class MockPlacesRepository implements PlacesRepository {
  // Direct, working, distinct image mapping for every tourist attraction
  static final Map<String, PlaceItem> _exactPlaceDatabase = {
    // 1. NARASARAOPET PLACES
    'kotappakonda': const PlaceItem(
      title: 'Kotappakonda Sri Trikoteswara Swamy Temple',
      category: 'Hindu Temple & Hill Shrine',
      distance: '12 km from Narasaraopet',
      rating: 4.8,
      reviewCount: '24.5K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1544717305-2782549b5136',
      openCloseTiming: '06:00 AM - 08:00 PM (Daily)',
      description: 'Famous hilltop temple dedicated to Lord Shiva as Trikoteswara Swamy on Trikuta Hills. Renowned for the massive Mahashivaratri Prabhalu festival.',
      whatToSee: [
        'Hilltop Shrine with Ghat Road Drive',
        'Panoramic Palnadu Plains Viewpoint',
        'Deer Park & Children Play Gardens',
        'Grand Mahashivaratri Prabhalu Festival Grounds',
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1544717305-2782549b5136',
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1609766857041-ed402ea8069a',
      ],
    ),
    'guthikonda': const PlaceItem(
      title: 'Guthikonda Bilam Cave Shrine',
      category: 'Limestone Cave & Pilgrimage',
      distance: '28 km from Narasaraopet',
      rating: 4.6,
      reviewCount: '12.1K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
      openCloseTiming: '08:00 AM - 05:30 PM (Daily)',
      description: 'Historic natural limestone cave system associated with ancient Maharshis, underground Shivling, and freedom fighters.',
      whatToSee: [
        'Limestone Cave Stalactite Formations',
        'Ancient Underground Shivling Shrine',
        'Trekking & Eco Exploration Trails',
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
      ],
    ),
    'amaravathi': const PlaceItem(
      title: 'Amaravathi Mahachaitya Stupa & Museum',
      category: 'Buddhist Heritage Site',
      distance: '45 km from Narasaraopet',
      rating: 4.7,
      reviewCount: '35.8K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1590059208019-15224887b38c',
      openCloseTiming: '09:00 AM - 05:00 PM (Closed Fridays)',
      description: 'Ancient 2000-year-old Buddhist stupa and archaeological museum preserving rare Satavahana limestone relief carvings.',
      whatToSee: [
        '2000-Year-Old Great Stupa Ruins',
        'Archaeological Museum Artifacts',
        '125-ft Dhyana Buddha Statue',
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1590059208019-15224887b38c',
      ],
    ),

    // 2. GUNTUR PLACES
    'kondaveedu': const PlaceItem(
      title: 'Kondaveedu Fort & Citadel',
      category: 'Historical Fortress',
      distance: '25 km from Guntur',
      rating: 4.7,
      reviewCount: '18.9K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1599839575945-a9e5af0c3fa5',
      openCloseTiming: '09:00 AM - 05:30 PM (Daily)',
      description: '14th-century hill fortress built by Prolaya Vema Reddi featuring ancient ramparts, towers, and scenic ghat road.',
      whatToSee: [
        'Gopuram Citadel Ruins',
        'Scenic Ghat Road Drive',
        'Sunset Vantage Point',
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1599839575945-a9e5af0c3fa5',
      ],
    ),
    'mangalagiri': const PlaceItem(
      title: 'Mangalagiri Panakala Lakshmi Narasimha Swamy Temple',
      category: 'Hindu Temple',
      distance: '21 km from Guntur',
      rating: 4.8,
      reviewCount: '42.6K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1609766857041-ed402ea8069a',
      openCloseTiming: '05:00 AM - 08:30 PM (Daily)',
      description: 'Ancient hill temple dedicated to Lord Narasimha where jaggery water (Panakam) is offered as divine prasadam.',
      whatToSee: [
        'Panakam Offering Mystery',
        '11-tier 153-ft Tower Gopuram',
        'Mangalagiri Handloom Market',
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1609766857041-ed402ea8069a',
      ],
    ),

    // 3. VIJAYAWADA PLACES
    'kanaka durga': const PlaceItem(
      title: 'Kanaka Durga Temple (Indrakeeladri Hill)',
      category: 'Hindu Temple',
      distance: '2.5 km from Vijayawada',
      rating: 4.9,
      reviewCount: '150K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1582510003544-4d00b7f74220',
      openCloseTiming: '04:00 AM - 10:00 PM (Daily)',
      description: 'Sacred shrine of Goddess Kanaka Durga situated on Indrakeeladri hill overlooking the Krishna River and Prakasam Barrage.',
      whatToSee: [
        'Indrakeeladri Hill Temple Gopuram',
        'Krishna River Ghats View',
        'Golden Temple Structure',
        'Dasara Navaratri Festival Celebrations',
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1582510003544-4d00b7f74220',
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1609766857041-ed402ea8069a',
      ],
    ),
    'undavalli': const PlaceItem(
      title: 'Undavalli Rock-Cut Caves',
      category: '7th-Century Cave Architecture',
      distance: '6.0 km from Vijayawada',
      rating: 4.7,
      reviewCount: '28.4K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      openCloseTiming: '09:00 AM - 05:30 PM (Daily)',
      description: '7th-century solid sandstone rock-cut cave temple featuring a giant 5-meter reclining Anantasayana Vishnu statue.',
      whatToSee: [
        '4-Story Rock Cut Architecture',
        'Giant Reclining Anantasayana Vishnu Statue',
        'Krishna River Viewpoint',
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      ],
    ),
    'prakasam barrage': const PlaceItem(
      title: 'Prakasam Barrage & Bhavani Island',
      category: 'River Barrage & Island Park',
      distance: '1.5 km from Vijayawada',
      rating: 4.6,
      reviewCount: '32.1K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      openCloseTiming: '06:00 AM - 09:00 PM (Daily)',
      description: '1223-meter long barrage across Krishna River connecting Krishna and Guntur districts, with speed boat rides to Bhavani Island.',
      whatToSee: [
        'Night LED Bridge Illumination',
        'Speed Boat Ride to Bhavani Island',
        'Water Sports & Eco Park',
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.weserv.nl/?url=https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      ],
    ),
  };

  @override
  Future<List<PlaceItem>> getPlacesByDestination(String destinationName) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final query = destinationName.trim().toLowerCase();

    final List<PlaceItem> results = [];

    _exactPlaceDatabase.forEach((key, place) {
      if (query.contains('narasaraopet') && (key == 'kotappakonda' || key == 'guthikonda' || key == 'amaravathi')) {
        results.add(place);
      } else if (query.contains('guntur') && (key == 'kondaveedu' || key == 'mangalagiri')) {
        results.add(place);
      } else if (query.contains('vijayawada') && (key == 'kanaka durga' || key == 'undavalli' || key == 'prakasam barrage')) {
        results.add(place);
      } else if (place.title.toLowerCase().contains(query) || place.distance.toLowerCase().contains(query)) {
        results.add(place);
      }
    });

    if (results.isNotEmpty) {
      return results;
    }

    // Default Tirupati Places fallback
    return TravelData.places;
  }

  @override
  Future<PlaceItem?> getPlaceById(String title) async {
    final places = await getPlacesByDestination('Vijayawada');
    try {
      return places.firstWhere((p) => p.title == title);
    } catch (e) {
      return null;
    }
  }
}
