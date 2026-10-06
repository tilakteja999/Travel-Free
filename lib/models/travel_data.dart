class RoomCategory {
  final String categoryName;
  final String price;
  final double numericPrice;
  final String bedInfo;
  final List<String> roomPhotos;
  final List<String> roomAmenities;

  const RoomCategory({
    required this.categoryName,
    required this.price,
    required this.numericPrice,
    required this.bedInfo,
    required this.roomPhotos,
    required this.roomAmenities,
  });
}

class PlaceItem {
  final String title;
  final String category;
  final String distance;
  final double rating;
  final String reviewCount;
  final String imageUrl;
  final String openCloseTiming;
  final String description;
  final List<String> whatToSee;
  final List<String> placeImages;

  const PlaceItem({
    required this.title,
    required this.category,
    required this.distance,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.openCloseTiming,
    required this.description,
    required this.whatToSee,
    required this.placeImages,
  });
}

class HotelItem {
  final String title;
  final String distance;
  final double rating;
  final String price;
  final String imageUrl;
  final String description;
  final List<RoomCategory> roomCategories;

  const HotelItem({
    required this.title,
    required this.distance,
    required this.rating,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.roomCategories,
  });
}

class TransportItem {
  final String name;
  final String type;
  final String numberOrVehicle;
  final String timing;
  final String price;
  final double rating;
  final String badgeText;

  const TransportItem({
    required this.name,
    required this.type,
    required this.numberOrVehicle,
    required this.timing,
    required this.price,
    required this.rating,
    required this.badgeText,
  });
}

class TouristGuide {
  final String name;
  final String serviceType;
  final String phone;
  final double rating;
  final String reviews;
  final String languages;
  final String experience;

  const TouristGuide({
    required this.name,
    required this.serviceType,
    required this.phone,
    required this.rating,
    required this.reviews,
    required this.languages,
    required this.experience,
  });
}

class TravelData {
  static const List<PlaceItem> places = [
    PlaceItem(
      title: 'Sri Venkateswara Swamy Temple\n(Tirumala Tirupati Devasthanams)',
      category: 'Hindu temple',
      distance: '22.4 km',
      rating: 4.8,
      reviewCount: '150K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1609766857041-ed402ea8069a',
      openCloseTiming: '03:00 AM - 11:30 PM (Open Daily)',
      description:
          'Sri Venkateswara Swamy Temple is an ancient hill temple situated atop Tirumala hills in Tirupati. Dedicated to Lord Venkateswara, it features magnificent Dravidian architecture, golden Vimanam dome, sacred holy tanks, and rich spiritual heritage.',
      whatToSee: [
        'Ananda Nilayam Golden Vimanam Tower',
        'Sacred Swami Pushkarini Holy Water Tank',
        'Vaikuntam Queue Complex & Darshan Hall',
        'World Famous Laddu Prasadam Counter',
        'Mahadwaram Main Temple Entrance Gate'
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1609766857041-ed402ea8069a',
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1544717305-2782549b5136',
      ],
    ),
    PlaceItem(
      title: 'Sri Padmavati Ammavaari Temple, Tiruchanur',
      category: 'Hindu temple',
      distance: '4.8 km',
      rating: 4.7,
      reviewCount: '78.4K',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1544717305-2782549b5136',
      openCloseTiming: '05:00 AM - 09:00 PM (Daily)',
      description:
          'Dedicated to Goddess Padmavati, the divine consort of Lord Venkateswara. Tradition mandates visiting this temple in Tiruchanur before ascending Tirumala hills for complete pilgrimage blessings.',
      whatToSee: [
        'Padma Sarovaram Holy Temple Lake',
        'Golden Lotus shrine sculptures',
        'Daily Abhishekam ceremonies',
        'Ornate Gopuram entrance towers'
      ],
      placeImages: [
        'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1544717305-2782549b5136',
      ],
    ),
  ];

  static const List<HotelItem> hotels = [
    HotelItem(
      title: 'Lotus Grand Hotel and Restaurant',
      distance: '10 KM',
      rating: 4.5,
      price: '₹2,400 / night',
      imageUrl: 'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1566073771259-6a8506099945',
      description:
          'Lotus Grand Hotel offers executive lodging with multi-cuisine dining, 24/7 hot water, high-speed Wi-Fi, and personalized room service.',
      roomCategories: [
        RoomCategory(
          categoryName: 'Standard / Normal AC Room',
          price: '₹2,400 / night',
          numericPrice: 2400.0,
          bedInfo: 'Queen Bed • 2 Adults',
          roomPhotos: [
            'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1618773928121-c32242e63f39',
            'https://images.weserv.nl/?url=https://images.unsplash.com/photo-1582719478250-c89cae4dc85b',
          ],
          roomAmenities: [
            '24/7 Hot Water & Geyser',
            'Free High-Speed Wi-Fi',
            'Air Conditioning (A/C)',
            '24/7 Room Service & Dining',
            'Smart TV with Cable',
          ],
        ),
      ],
    ),
  ];

  static const List<TransportItem> trains = [
    TransportItem(
      name: 'Train 1 (Visakha Express)',
      type: 'Train',
      numberOrVehicle: '12862 - Superfast Express',
      timing: '08:15 AM -> 04:30 PM (8h 15m)',
      price: '₹450',
      rating: 4.5,
      badgeText: 'Daily',
    ),
  ];

  static const List<TouristGuide> guides = [
    TouristGuide(
      name: 'Ramesh Sharma',
      serviceType: 'Certified Spiritual & Heritage Guide',
      phone: '+91 98765 43210',
      rating: 4.9,
      reviews: '1.2K',
      languages: 'Telugu, English, Hindi',
      experience: '12 Years',
    ),
  ];
}
