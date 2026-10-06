import 'dart:async';
import 'package:flutter/material.dart';
import '../features/ride_hailing/models/ride_status.dart';
import '../features/ride_hailing/providers/ride_provider.dart';
import '../features/ride_hailing/widgets/driver_info_bottom_sheet.dart';
import '../features/ride_hailing/widgets/map_simulation_widget.dart';
import '../features/ride_hailing/widgets/ride_status_timeline.dart';
import '../theme/app_theme.dart';
import '../widgets/persistent_profile_widget.dart';
import 'ride_chat_screen.dart';
import 'ride_summary_screen.dart';

class RideTrackingScreen extends StatefulWidget {
  final String bookingId;

  const RideTrackingScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  Timer? _simulationTimer;
  double _progress = 0.0;
  bool _isArrivingStage = true; // true: driver -> pickup, false: pickup -> destination

  @override
  void initState() {
    super.initState();
    _startSimulationTimer();
  }

  void _startSimulationTimer() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.04;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _handleStageCompletion();
        }
      });
    });
  }

  void _handleStageCompletion() async {
    final provider = RideProvider();
    final booking = provider.activeBooking;

    if (_isArrivingStage && booking?.status == RideStatus.driverAssigned) {
      await provider.updateBookingStatus(RideStatus.driverArrived);
    } else if (!_isArrivingStage && booking?.status == RideStatus.tripStarted) {
      await provider.updateBookingStatus(RideStatus.tripCompleted);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RideSummaryScreen(bookingId: widget.bookingId),
        ),
      );
    }
  }

  void _speedUpDemo() {
    setState(() {
      _progress = 0.95;
    });
  }

  void _handleStartRide() async {
    final provider = RideProvider();
    await provider.updateBookingStatus(RideStatus.tripStarted);
    setState(() {
      _isArrivingStage = false;
      _progress = 0.0;
    });
    _startSimulationTimer();
  }

  void _showDemoCallDialog() {
    final driver = RideProvider().activeBooking?.driver;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.phone, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('Demo Call', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'In a live version, this would connect you to ${driver?.name ?? 'your driver'}.\nNo real driver call is available in this demo.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleCancelRide() {
    final status = RideProvider().activeBooking?.status;
    double fee = 0.0;
    if (status == RideStatus.driverArrived) {
      fee = 20.0;
    } else if (status == RideStatus.driverAssigned || status == RideStatus.driverArriving) {
      fee = 10.0;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Ride?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to cancel this demo ride?${fee > 0 ? '\nDemo cancellation fee: ₹${fee.toInt()}' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep Ride', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              _simulationTimer?.cancel();
              await RideProvider().cancelBooking('Cancelled by user', fee);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo ride cancelled locally.')),
              );
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = RideProvider();
    final booking = provider.activeBooking;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Tracking')),
        body: const Center(child: Text('No active ride found.')),
      );
    }

    final driver = booking.driver;
    final status = booking.status;

    return Scaffold(
      body: Stack(
        children: [
          // Map Canvas Simulation
          MapSimulationWidget(
            pickupName: booking.pickupName,
            destinationName: booking.destinationName,
            animationProgress: _progress,
            isArrivingStage: _isArrivingStage,
            rideType: booking.rideType,
          ),

          // Top Header Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const PersistentProfileWidget(),
                ],
              ),
            ),
          ),

          // Bottom Content Column: Timeline + Driver Sheet + Action CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Timeline Step Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RideStatusTimeline(status: status),
                ),

                const SizedBox(height: 8),

                // Speed Up Demo Button for testing
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: FloatingActionButton.extended(
                      heroTag: 'speed_up_btn',
                      backgroundColor: Colors.amber.shade800,
                      onPressed: _speedUpDemo,
                      icon: const Icon(Icons.fast_forward, size: 18, color: Colors.white),
                      label: const Text('Speed Up Demo', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Start Ride CTA when driver arrived
                if (status == RideStatus.driverArrived)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: _handleStartRide,
                        child: const Text('START DEMO RIDE NOW', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),

                // Driver Info Bottom Sheet
                DriverInfoBottomSheet(
                  booking: booking,
                  onCallTap: _showDemoCallDialog,
                  onChatTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideChatScreen(rideId: booking.id, driverName: driver?.name ?? 'Driver'),
                      ),
                    );
                  },
                  onCancelTap: _handleCancelRide,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
