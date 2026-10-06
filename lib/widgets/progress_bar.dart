import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final String? label;
  final Color activeColor;
  final Color backgroundColor;
  final double height;

  const CustomProgressBar({
    super.key,
    required this.value,
    this.label,
    this.activeColor = AppColors.vanRed,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final percentage = (clamped * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              Text(
                '$percentage%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activeColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: height,
                color: backgroundColor,
              ),
              FractionallySizedBox(
                widthFactor: clamped,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
