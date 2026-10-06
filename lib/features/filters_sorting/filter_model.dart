import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FilterModel {
  final double minPrice;
  final double maxPrice;
  final Set<int> selectedStars;
  final Set<String> selectedAmenities;
  final String sortBy;
  final String? transportType;
  final bool isAcOnly;
  final bool isSleeperOnly;

  const FilterModel({
    this.minPrice = 0.0,
    this.maxPrice = 10000.0,
    this.selectedStars = const {},
    this.selectedAmenities = const {},
    this.sortBy = 'recommended',
    this.transportType,
    this.isAcOnly = false,
    this.isSleeperOnly = false,
  });

  bool get hasActiveFilters {
    return minPrice > 0 ||
        maxPrice < 10000 ||
        selectedStars.isNotEmpty ||
        selectedAmenities.isNotEmpty ||
        transportType != null ||
        isAcOnly ||
        isSleeperOnly ||
        sortBy != 'recommended';
  }

  int get activeFilterCount {
    int count = 0;
    if (minPrice > 0 || maxPrice < 10000) count++;
    if (selectedStars.isNotEmpty) count++;
    if (selectedAmenities.isNotEmpty) count++;
    if (transportType != null) count++;
    if (isAcOnly) count++;
    if (isSleeperOnly) count++;
    if (sortBy != 'recommended') count++;
    return count;
  }

  FilterModel copyWith({
    double? minPrice,
    double? maxPrice,
    Set<int>? selectedStars,
    Set<String>? selectedAmenities,
    String? sortBy,
    String? transportType,
    bool? isAcOnly,
    bool? isSleeperOnly,
  }) {
    return FilterModel(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedStars: selectedStars ?? this.selectedStars,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      sortBy: sortBy ?? this.sortBy,
      transportType: transportType ?? this.transportType,
      isAcOnly: isAcOnly ?? this.isAcOnly,
      isSleeperOnly: isSleeperOnly ?? this.isSleeperOnly,
    );
  }

  Map<String, dynamic> toJson() => {
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'selectedStars': selectedStars.toList(),
        'selectedAmenities': selectedAmenities.toList(),
        'sortBy': sortBy,
        'transportType': transportType,
        'isAcOnly': isAcOnly,
        'isSleeperOnly': isSleeperOnly,
      };

  factory FilterModel.fromJson(Map<String, dynamic> json) => FilterModel(
        minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
        maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 10000.0,
        selectedStars: Set<int>.from(json['selectedStars'] ?? []),
        selectedAmenities: Set<String>.from(json['selectedAmenities'] ?? []),
        sortBy: json['sortBy'] ?? 'recommended',
        transportType: json['transportType'],
        isAcOnly: json['isAcOnly'] ?? false,
        isSleeperOnly: json['isSleeperOnly'] ?? false,
      );

  static const String _keyPrefix = 'travel_filters_user_';

  static Future<void> saveForUser(String userIdentifier, FilterModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${userIdentifier.toLowerCase()}';
    await prefs.setString(key, jsonEncode(model.toJson()));
  }

  static Future<FilterModel> loadForUser(String userIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${userIdentifier.toLowerCase()}';
    final raw = prefs.getString(key);
    if (raw != null && raw.isNotEmpty) {
      try {
        return FilterModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
      } catch (e) {
        return const FilterModel();
      }
    }
    return const FilterModel();
  }
}
