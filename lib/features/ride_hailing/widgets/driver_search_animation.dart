import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class DriverSearchAnimation extends StatefulWidget {
  final String vehicleLabel;

  const DriverSearchAnimation({
    super.key,
    required this.vehicleLabel,
  });

  @override
  State<DriverSearchAnimation> createState() => _DriverSearchAnimationState();
}

class _DriverSearchAnimationState extends State<DriverSearchAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final wave = _controller.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Wave Ring
                  Container(
                    width: 120 + (wave * 60),
                    height: 120 + (wave * 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: (1.0 - wave) * 0.3),
                    ),
                  ),
                  // Inner Pulse Ring
                  Container(
                    width: 90 + (wave * 30),
                    height: 90 + (wave * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: (1.0 - wave) * 0.5),
                    ),
                  ),
                  // Center Icon Circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Finding nearby ${widget.vehicleLabel} driver...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Simulated driver search for Demo Mode',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
