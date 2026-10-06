import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/ride_status.dart';

class RideStatusTimeline extends StatelessWidget {
  final RideStatus status;

  const RideStatusTimeline({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    int activeStep = 0;
    switch (status) {
      case RideStatus.searchingDriver:
        activeStep = 0;
        break;
      case RideStatus.driverAssigned:
      case RideStatus.driverArriving:
        activeStep = 1;
        break;
      case RideStatus.driverArrived:
        activeStep = 2;
        break;
      case RideStatus.tripStarted:
        activeStep = 3;
        break;
      case RideStatus.tripCompleted:
        activeStep = 4;
        break;
      default:
        activeStep = 0;
    }

    final steps = [
      'Assigned',
      'Arriving',
      'Arrived',
      'On Trip',
      'Completed',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isCompleted = index <= activeStep;
          return Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isCompleted ? AppColors.primaryBlue : Colors.grey.shade300,
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? AppColors.textDark : Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
