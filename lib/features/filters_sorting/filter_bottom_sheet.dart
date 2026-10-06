import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'filter_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterModel initialFilters;
  final int? resultCount;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    this.resultCount,
  });

  static Future<FilterModel?> show(
    BuildContext context,
    FilterModel initialFilters, {
    int? resultCount,
  }) {
    return showModalBottomSheet<FilterModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialFilters: initialFilters,
        resultCount: resultCount,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterModel _draftFilter;

  final List<String> _allAmenities = [
    'Free Wi-Fi',
    'Air Conditioning (AC)',
    'Free Breakfast',
    'Swimming Pool',
    'Fitness Center / Gym',
    '24/7 Room Service',
    'Free Parking',
    'Pet Friendly',
  ];

  @override
  void initState() {
    super.initState();
    _draftFilter = widget.initialFilters.copyWith();
  }

  void _resetDraft() {
    setState(() {
      _draftFilter = const FilterModel();
    });
  }

  void _updateSort(String sortValue) {
    setState(() {
      _draftFilter = _draftFilter.copyWith(sortBy: sortValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: AppColors.vanRed),
                    const SizedBox(width: 8),
                    const Text(
                      'Search Filters & Sort',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    if (_draftFilter.activeFilterCount > 0) ...[
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.vanRed,
                        child: Text(
                          '${_draftFilter.activeFilterCount}',
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton(
                  onPressed: _resetDraft,
                  child: const Text('Reset All', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sort By Section
                    const Text('Sort Results By', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortChip('Recommended', 'recommended'),
                        _buildSortChip('Price: Low to High', 'price_asc'),
                        _buildSortChip('Price: High to Low', 'price_desc'),
                        _buildSortChip('Rating: High to Low', 'rating_desc'),
                        _buildSortChip('Popularity', 'popularity'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Price Range Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price Range per Night / Fare', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        Text(
                          '₹${_draftFilter.minPrice.toInt()} - ${_draftFilter.maxPrice >= 10000 ? '₹10,000+' : '₹${_draftFilter.maxPrice.toInt()}'}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.vanRed),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(_draftFilter.minPrice, _draftFilter.maxPrice),
                      min: 0,
                      max: 10000,
                      divisions: 100,
                      activeColor: AppColors.vanRed,
                      labels: RangeLabels(
                        '₹${_draftFilter.minPrice.toInt()}',
                        '₹${_draftFilter.maxPrice.toInt()}',
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _draftFilter = _draftFilter.copyWith(
                            minPrice: values.start,
                            maxPrice: values.end,
                          );
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Star Rating
                    const Text('Star Rating', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Row(
                      children: [3, 4, 5].map((star) {
                        final isSelected = _draftFilter.selectedStars.contains(star);
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FilterChip(
                            avatar: Icon(Icons.star, color: isSelected ? Colors.white : Colors.amber, size: 16),
                            label: Text('$star Star'),
                            selected: isSelected,
                            selectedColor: AppColors.vanRed,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textDark,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setState(() {
                                final updatedStars = Set<int>.from(_draftFilter.selectedStars);
                                if (val) {
                                  updatedStars.add(star);
                                } else {
                                  updatedStars.remove(star);
                                }
                                _draftFilter = _draftFilter.copyWith(selectedStars: updatedStars);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Transport Specific Choices
                    const Text('Transport & Comfort Choices', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text('AC Only'),
                          selected: _draftFilter.isAcOnly,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(color: _draftFilter.isAcOnly ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                          onSelected: (val) {
                            setState(() {
                              _draftFilter = _draftFilter.copyWith(isAcOnly: val);
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        FilterChip(
                          label: const Text('Sleeper Only'),
                          selected: _draftFilter.isSleeperOnly,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(color: _draftFilter.isSleeperOnly ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                          onSelected: (val) {
                            setState(() {
                              _draftFilter = _draftFilter.copyWith(isSleeperOnly: val);
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Amenities
                    const Text('Amenities & Services', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allAmenities.map((amenity) {
                        final isSelected = _draftFilter.selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          selectedColor: AppColors.vanRed,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            setState(() {
                              final updatedAmenities = Set<String>.from(_draftFilter.selectedAmenities);
                              if (val) {
                                updatedAmenities.add(amenity);
                              } else {
                                updatedAmenities.remove(amenity);
                              }
                              _draftFilter = _draftFilter.copyWith(selectedAmenities: updatedAmenities);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Result Summary Text
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Text(
                  widget.resultCount != null
                      ? 'Showing ${widget.resultCount} results matching criteria'
                      : 'Adjust filters to see results',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Bottom Action Buttons
            Row(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: _resetDraft,
                  child: const Text('Reset', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      Navigator.pop(context, _draftFilter);
                    },
                    child: const Text('Apply Filters', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _draftFilter.sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) {
          _updateSort(value);
        }
      },
    );
  }
}
