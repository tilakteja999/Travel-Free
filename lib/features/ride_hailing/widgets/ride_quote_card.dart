import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/ride_quote_model.dart';
import '../models/ride_type.dart';

class RideQuoteCard extends StatelessWidget {
  final RideQuoteModel quote;
  final bool isSelected;
  final VoidCallback onTap;

  const RideQuoteCard({
    super.key,
    required this.quote,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getVehicleIcon(RideType type) {
    switch (type) {
      case RideType.bike:
        return Icons.two_wheeler;
      case RideType.auto:
        return Icons.electric_rickshaw;
      case RideType.miniCab:
        return Icons.directions_car;
      case RideType.sedanCab:
        return Icons.time_to_leave;
      case RideType.premiumCab:
        return Icons.airport_shuttle;
    }
  }

  Color _getBadgeColor(RideType type) {
    switch (type) {
      case RideType.bike:
        return Colors.orange;
      case RideType.auto:
        return Colors.green;
      case RideType.miniCab:
        return Colors.blue;
      case RideType.sedanCab:
        return Colors.purple;
      case RideType.premiumCab:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = quote.rideType;
    final isAvailable = quote.isAvailable;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.black12,
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAvailable ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Vehicle Icon Circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getBadgeColor(type).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getVehicleIcon(type),
                          color: _getBadgeColor(type),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  type.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person, size: 12, color: Colors.black54),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${type.maxPassengers}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              type.description,
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),

                      // Price & ETA
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${quote.estimatedTotal.toInt()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.vanRed,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ETA ${quote.driverArrivalMinutes} mins',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (quote.demandMultiplier > 1.0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.bolt, size: 14, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            'Peak fare applies (Higher demand in area)',
                            style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (!isAvailable && quote.unavailableMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '⚠️ ${quote.unavailableMessage}',
                      style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
