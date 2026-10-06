import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/ride_type.dart';

class MapSimulationWidget extends StatelessWidget {
  final String pickupName;
  final String destinationName;
  final double animationProgress; // 0.0 to 1.0
  final bool isArrivingStage; // true: driver -> pickup, false: pickup -> destination
  final RideType rideType;

  const MapSimulationWidget({
    super.key,
    required this.pickupName,
    required this.destinationName,
    required this.animationProgress,
    required this.isArrivingStage,
    required this.rideType,
  });

  IconData _getVehicleIcon() {
    switch (rideType) {
      case RideType.bike:
        return Icons.two_wheeler;
      case RideType.auto:
        return Icons.electric_rickshaw;
      case RideType.miniCab:
      case RideType.sedanCab:
      case RideType.premiumCab:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE8ECEF), // Off-white map canvas background
      ),
      child: Stack(
        children: [
          // Background Custom Map Road Network Painter
          Positioned.fill(
            child: CustomPaint(
              painter: _MapCanvasPainter(
                progress: animationProgress,
                isArriving: isArrivingStage,
              ),
            ),
          ),

          // Pickup Pin Marker
          Positioned(
            left: 60,
            top: 140,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pickupName,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.location_on, color: Colors.green, size: 36),
              ],
            ),
          ),

          // Destination Pin Marker
          Positioned(
            right: 60,
            bottom: 160,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.vanRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    destinationName,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.location_on, color: AppColors.vanRed, size: 36),
              ],
            ),
          ),

          // Animated Driver Vehicle Marker
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _calculateVehicleX(MediaQuery.of(context).size.width),
            top: _calculateVehicleY(MediaQuery.of(context).size.height),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Icon(
                _getVehicleIcon(),
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Demo Badge Overlay Top Left
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Demo tracking — not live GPS',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateVehicleX(double screenWidth) {
    if (isArrivingStage) {
      // Driver moving from Top-Left (20) to Pickup (60)
      return 20 + (40 * animationProgress);
    } else {
      // Driver moving from Pickup (60) to Destination (screenWidth - 90)
      return 60 + ((screenWidth - 150) * animationProgress);
    }
  }

  double _calculateVehicleY(double screenHeight) {
    if (isArrivingStage) {
      // Driver moving from Top-Left (60) to Pickup (140)
      return 60 + (80 * animationProgress);
    } else {
      // Driver moving from Pickup (140) to Destination (screenHeight - 220)
      return 140 + ((screenHeight - 360) * animationProgress);
    }
  }
}

class _MapCanvasPainter extends CustomPainter {
  final double progress;
  final bool isArriving;

  _MapCanvasPainter({required this.progress, required this.isArriving});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke;

    // Draw Map Roads
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.2), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.8), gridPaint);

    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), gridPaint);
    canvas.drawLine(Offset(size.width * 0.70, 0), Offset(size.width * 0.70, size.height), gridPaint);

    // Route Polyline
    final routePaint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(70, 160);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.35, size.width - 70, size.height - 180);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isArriving != isArriving;
  }
}
