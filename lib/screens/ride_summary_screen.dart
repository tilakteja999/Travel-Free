import 'package:flutter/material.dart';
import '../features/ride_hailing/providers/ride_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/persistent_profile_widget.dart';
import 'ride_feedback_screen.dart';

class RideSummaryScreen extends StatelessWidget {
  final String bookingId;

  const RideSummaryScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    final booking = RideProvider().activeBooking;
    final driver = booking?.driver;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Ride Summary'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: PersistentProfileWidget()),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Celebration Check Header
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'You Reached Your Destination!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thank you for riding with ${driver?.name ?? 'Travel Time Driver'}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Route & Fare Summary Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trip Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 12, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(booking?.pickupName ?? 'Pickup', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: SizedBox(height: 16, child: VerticalDivider(thickness: 1.5)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppColors.vanRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(booking?.destinationName ?? 'Destination', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Fare Breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Base Fare', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          Text('₹30', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Distance Fare (${booking?.routeDistanceKm ?? 12.5} km)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          Text('₹${((booking?.estimatedFare ?? 150) * 0.7).toInt()}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Platform & Booking Fee', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          Text('₹10', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Demo Fare', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                          Text('₹${booking?.estimatedFare.toInt() ?? 150}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.vanRed)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Demo Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo ride completed — no real money was charged.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CTA: Rate Your Ride
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideFeedbackScreen(bookingId: bookingId),
                      ),
                    );
                  },
                  child: const Text('RATE YOUR RIDE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
