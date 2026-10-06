import 'dart:async';
import '../models/location_model.dart';

abstract class LocationRepository {
  Future<List<LocationModel>> searchLocations(String query);
  Future<LocationModel?> getLocationById(String id);
}

class MockLocationRepository implements LocationRepository {
  // Comprehensive Andhra Pradesh & India Development Dataset
  final List<LocationModel> _database = [
    LocationModel(
      id: 'loc_01',
      name: 'Narasaraopet',
      locality: 'Narasaraopet Town',
      district: 'Palnadu',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 16.2354,
      longitude: 80.0494,
      category: 'Town',
      description: 'Major commercial hub and educational center in Palnadu district.',
    ),
    LocationModel(
      id: 'loc_02',
      name: 'Narasaraopet Railway Station',
      locality: 'Station Road',
      town: 'Narasaraopet',
      district: 'Palnadu',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 16.2380,
      longitude: 80.0520,
      category: 'Railway Station',
    ),
    LocationModel(
      id: 'loc_03',
      name: 'Guntur',
      city: 'Guntur',
      district: 'Guntur',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 16.3067,
      longitude: 80.4365,
      category: 'City',
      description: 'Famous for chili market, spices, and historic heritage.',
    ),
    LocationModel(
      id: 'loc_04',
      name: 'Vijayawada',
      city: 'Vijayawada',
      district: 'NTR',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 16.5062,
      longitude: 80.6480,
      category: 'City',
      description: 'Major commercial city on Krishna River, home to Kanaka Durga Temple.',
    ),
    LocationModel(
      id: 'loc_05',
      name: 'Tirupati',
      city: 'Tirupati',
      district: 'Tirupati',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 13.6288,
      longitude: 79.4192,
      category: 'City',
      description: 'World-renowned spiritual destination at the foot of Tirumala Hills.',
    ),
    LocationModel(
      id: 'loc_06',
      name: 'Tirumala',
      locality: 'Tirumala Hills',
      city: 'Tirupati',
      district: 'Tirupati',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 13.6833,
      longitude: 79.3500,
      category: 'Tourist Place',
      description: 'Sacred hill town hosting the Sri Venkateswara Swamy Temple.',
    ),
    LocationModel(
      id: 'loc_07',
      name: 'Visakhapatnam',
      city: 'Visakhapatnam',
      district: 'Visakhapatnam',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 17.6868,
      longitude: 83.2185,
      category: 'City',
      description: 'Coastal port city with picturesque beaches and Araku valley proximity.',
    ),
    LocationModel(
      id: 'loc_08',
      name: 'Tenali',
      town: 'Tenali',
      district: 'Guntur',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 16.2430,
      longitude: 80.6400,
      category: 'Town',
    ),
    LocationModel(
      id: 'loc_09',
      name: 'Amaravati',
      city: 'Amaravati',
      district: 'Guntur',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 16.5131,
      longitude: 80.5165,
      category: 'City',
      description: 'Capital region and ancient Buddhist stupa pilgrimage site.',
    ),
    LocationModel(
      id: 'loc_10',
      name: 'Araku Valley',
      town: 'Araku',
      district: 'Alluri Sitharama Raju',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 18.3273,
      longitude: 82.8775,
      category: 'Tourist Place',
      description: 'Scenic hill station known for coffee plantations and Borra Caves.',
    ),
    LocationModel(
      id: 'loc_11',
      name: 'Srisailam',
      town: 'Srisailam',
      district: 'Nandyal',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 16.0748,
      longitude: 78.8687,
      category: 'Tourist Place',
      description: 'Holy shrine on Nallamala Hills housing Mallikarjuna Jyotirlinga.',
    ),
    LocationModel(
      id: 'loc_12',
      name: 'Kakinada',
      city: 'Kakinada',
      district: 'Kakinada',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 16.9891,
      longitude: 82.2475,
      category: 'City',
    ),
    LocationModel(
      id: 'loc_13',
      name: 'Rajahmundry',
      city: 'Rajahmundry',
      district: 'East Godavari',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 17.0005,
      longitude: 81.8040,
      category: 'City',
    ),
    LocationModel(
      id: 'loc_14',
      name: 'Kurnool',
      city: 'Kurnool',
      district: 'Kurnool',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 15.8281,
      longitude: 78.0373,
      category: 'City',
    ),
    LocationModel(
      id: 'loc_15',
      name: 'Nellore',
      city: 'Nellore',
      district: 'SPS Nellore',
      state: 'Andhra Pradesh',
      country: 'India',
      latitude: 14.4426,
      longitude: 79.9865,
      category: 'City',
    ),
  ];

  @override
  Future<List<LocationModel>> searchLocations(String query) async {
    // Simulate debounced API latency
    await Future.delayed(const Duration(milliseconds: 300));

    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    return _database.where((item) {
      final nameMatch = item.name.toLowerCase().contains(cleanQuery);
      final cityMatch = item.city?.toLowerCase().contains(cleanQuery) ?? false;
      final districtMatch = item.district?.toLowerCase().contains(cleanQuery) ?? false;
      final stateMatch = item.state?.toLowerCase().contains(cleanQuery) ?? false;
      final categoryMatch = item.category?.toLowerCase().contains(cleanQuery) ?? false;
      return nameMatch || cityMatch || districtMatch || stateMatch || categoryMatch;
    }).toList();
  }

  @override
  Future<LocationModel?> getLocationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _database.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }
}
