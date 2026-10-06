import 'package:flutter/material.dart';
import '../features/filters_sorting/filter_bottom_sheet.dart';
import '../features/filters_sorting/filter_model.dart';
import '../theme/app_theme.dart';

class ResultsFilterHeader extends StatelessWidget {
  final String title;
  final String? dateSummary;
  final FilterModel filterModel;
  final int resultCount;
  final ValueChanged<FilterModel> onFilterChanged;

  const ResultsFilterHeader({
    super.key,
    required this.title,
    this.dateSummary,
    required this.filterModel,
    required this.resultCount,
    required this.onFilterChanged,
  });

  Future<void> _openFilters(BuildContext context) async {
    final updated = await FilterBottomSheet.show(
      context,
      filterModel,
      resultCount: resultCount,
    );
    if (updated != null) {
      onFilterChanged(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dateSummary != null && dateSummary!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        dateSummary!,
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),

              Text(
                '$resultCount found',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(width: 8),

              // Filter Button with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: filterModel.hasActiveFilters ? AppColors.vanRed : Colors.grey.shade300,
                        width: filterModel.hasActiveFilters ? 1.8 : 1.0,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: () => _openFilters(context),
                    icon: Icon(
                      Icons.tune,
                      size: 18,
                      color: filterModel.hasActiveFilters ? AppColors.vanRed : AppColors.textDark,
                    ),
                    label: Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: filterModel.hasActiveFilters ? AppColors.vanRed : AppColors.textDark,
                      ),
                    ),
                  ),
                  if (filterModel.activeFilterCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: AppColors.vanRed,
                        child: Text(
                          '${filterModel.activeFilterCount}',
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Active Removable Filter Chips
          if (filterModel.hasActiveFilters) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (filterModel.minPrice > 0 || filterModel.maxPrice < 10000)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: Text('₹${filterModel.minPrice.toInt()}–₹${filterModel.maxPrice.toInt()}'),
                        onDeleted: () {
                          onFilterChanged(filterModel.copyWith(minPrice: 0.0, maxPrice: 10000.0));
                        },
                      ),
                    ),
                  if (filterModel.selectedStars.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: Text('${filterModel.selectedStars.join(", ")}★'),
                        onDeleted: () {
                          onFilterChanged(filterModel.copyWith(selectedStars: {}));
                        },
                      ),
                    ),
                  if (filterModel.isAcOnly)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: const Text('AC Only'),
                        onDeleted: () {
                          onFilterChanged(filterModel.copyWith(isAcOnly: false));
                        },
                      ),
                    ),
                  if (filterModel.isSleeperOnly)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: const Text('Sleeper Only'),
                        onDeleted: () {
                          onFilterChanged(filterModel.copyWith(isSleeperOnly: false));
                        },
                      ),
                    ),
                  if (filterModel.sortBy != 'recommended')
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: Text('Sort: ${_formatSortName(filterModel.sortBy)}'),
                        onDeleted: () {
                          onFilterChanged(filterModel.copyWith(sortBy: 'recommended'));
                        },
                      ),
                    ),
                  ...filterModel.selectedAmenities.map((amenity) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: Text(amenity),
                        onDeleted: () {
                          final updated = Set<String>.from(filterModel.selectedAmenities)..remove(amenity);
                          onFilterChanged(filterModel.copyWith(selectedAmenities: updated));
                        },
                      ),
                    );
                  }),
                  ActionChip(
                    label: const Text('Clear all', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                    backgroundColor: Colors.red.shade50,
                    onPressed: () {
                      onFilterChanged(const FilterModel());
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatSortName(String sort) {
    switch (sort) {
      case 'price_asc':
        return 'Price Low to High';
      case 'price_desc':
        return 'Price High to Low';
      case 'rating_desc':
        return 'Rating';
      case 'popularity':
        return 'Popularity';
      default:
        return 'Recommended';
    }
  }
}
