import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/ride_category.dart';

class RideCategoryToggle extends StatelessWidget {
  final RideCategory selectedCategory;
  final ValueChanged<RideCategory> onCategoryChanged;

  const RideCategoryToggle({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildItem(
              context,
              category: RideCategory.autoBike,
              icon: Icons.two_wheeler,
              label: '🛺 Auto & Bike',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildItem(
              context,
              category: RideCategory.cab,
              icon: Icons.local_taxi,
              label: '🚕 Cab',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required RideCategory category,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () => onCategoryChanged(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
