import 'package:flutter/material.dart';
import '../models/travel_data.dart';
import '../theme/app_theme.dart';

class TouristGuideSheet extends StatelessWidget {
  const TouristGuideSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TouristGuideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent, color: AppColors.primaryBlue, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Local Tourist Guides',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Verified local guides & transport escorts in Tirupati',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // List of guides
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: TravelData.guides.map((guide) => _buildGuideCard(context, guide)).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, TouristGuide guide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text(
                    guide.name.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        guide.serviceType,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${guide.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.translate, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    guide.languages,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                Text(
                  guide.experience,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling ${guide.name} (${guide.phone})...'),
                          backgroundColor: AppColors.primaryBlue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call Guide', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening chat with ${guide.name}...'),
                          backgroundColor: const Color(0xFF25D366),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('WhatsApp', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
