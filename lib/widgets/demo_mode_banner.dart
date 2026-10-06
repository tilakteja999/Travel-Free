import 'package:flutter/material.dart';
import '../core/config/demo_mode_config.dart';

class DemoModeBanner extends StatelessWidget {
  final String text;

  const DemoModeBanner({
    super.key,
    this.text = DemoModeConfig.paymentNotice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
