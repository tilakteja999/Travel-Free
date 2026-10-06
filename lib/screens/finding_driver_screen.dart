import 'dart:async';
import 'package:flutter/material.dart';
import '../features/ride_hailing/models/ride_status.dart';
import '../features/ride_hailing/models/ride_type.dart';
import '../features/ride_hailing/providers/ride_provider.dart';
import '../features/ride_hailing/widgets/driver_search_animation.dart';
import '../theme/app_theme.dart';
import '../widgets/persistent_profile_widget.dart';
import 'ride_tracking_screen.dart';

class FindingDriverScreen extends StatefulWidget {
  final String bookingId;

  const FindingDriverScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends State<FindingDriverScreen> {
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _startDriverSearch();
  }

  void _startDriverSearch() {
    _searchTimer = Timer(const Duration(seconds: 4), () async {
      final provider = RideProvider();
      await provider.simulateDriverAssignment(widget.bookingId);

      if (!mounted) return;

      final booking = provider.activeBooking;
      if (booking?.status == RideStatus.driverAssigned) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demo driver assigned: ${booking?.driver?.name ?? 'Driver'} is on the way.'),
            backgroundColor: AppColors.accentGreen,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RideTrackingScreen(bookingId: widget.bookingId),
          ),
        );
      }
    });
  }

  void _cancelSearch() async {
    _searchTimer?.cancel();
    await RideProvider().cancelBooking('Cancelled by user during search', 0.0);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo ride request cancelled locally.')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeBooking = RideProvider().activeBooking;
    final vehicleLabel = activeBooking?.rideType.label ?? 'Ride';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Searching for Driver'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: PersistentProfileWidget()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: DriverSearchAnimation(vehicleLabel: vehicleLabel),
              ),

              // Route Summary Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pickup: ${activeBooking?.pickupName ?? 'Pickup'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('₹${activeBooking?.estimatedFare.toInt() ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.vanRed, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Destination: ${activeBooking?.destinationName ?? 'Destination'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Cancel Search Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _cancelSearch,
                  child: const Text('Cancel Request', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
