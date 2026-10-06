import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/ride_booking_model.dart';

class DriverInfoBottomSheet extends StatelessWidget {
  final RideBookingModel booking;
  final VoidCallback onCallTap;
  final VoidCallback onChatTap;
  final VoidCallback onCancelTap;

  const DriverInfoBottomSheet({
    super.key,
    required this.booking,
    required this.onCallTap,
    required this.onChatTap,
    required this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    final driver = booking.driver;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Avatar, Name & Vehicle Info
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                  child: Text(
                    driver?.name.isNotEmpty == true ? driver!.name[0].toUpperCase() : 'D',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            driver?.name ?? 'Assigned Driver',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 12, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  '${driver?.rating ?? 4.8}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${driver?.vehicleName ?? booking.rideType.name} • ${driver?.vehicleNumber ?? 'AP 07 TX 4582'}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${driver?.completedTrips ?? 500}+ trips • Speaks ${driver?.language ?? 'Telugu'}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Fare & Payment Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Fare', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '₹${booking.estimatedFare.toInt()}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.vanRed),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Payment Method', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      booking.paymentMethod,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action Buttons Row: Call, Chat, Cancel
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.primaryBlue),
                    ),
                    onPressed: onCallTap,
                    icon: const Icon(Icons.phone, color: AppColors.primaryBlue, size: 20),
                    label: const Text('Call', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onChatTap,
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: onCancelTap,
                  child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
