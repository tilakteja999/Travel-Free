class LocationModel {
  final String id;
  final String name;
  final String? fullAddress;
  final String? locality;
  final String? village;
  final String? town;
  final String? city;
  final String? mandal;
  final String? district;
  final String? state;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? category; // City, Tourist Place, Transport, Accommodation, Mandal, District
  final String? providerId;
  final String? image;
  final String? description;

  LocationModel({
    required this.id,
    required this.name,
    this.fullAddress,
    this.locality,
    this.village,
    this.town,
    this.city,
    this.mandal,
    this.district,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.category,
    this.providerId,
    this.image,
    this.description,
  });

  String get subtitle {
    final parts = [locality ?? city ?? town, district, state, country]
        .where((p) => p != null && p.isNotEmpty)
        .toSet()
        .toList();
    return parts.join(', ');
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        fullAddress: json['fullAddress'],
        locality: json['locality'],
        village: json['village'],
        town: json['town'],
        city: json['city'],
        mandal: json['mandal'],
        district: json['district'],
        state: json['state'],
        country: json['country'],
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        category: json['category'],
        providerId: json['providerId'],
        image: json['image'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fullAddress': fullAddress,
        'locality': locality,
        'village': village,
        'town': town,
        'city': city,
        'mandal': mandal,
        'district': district,
        'state': state,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        'providerId': providerId,
        'image': image,
        'description': description,
      };
}
