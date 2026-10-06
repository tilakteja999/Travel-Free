import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'help_center_screen.dart';

class PaymentFailureScreen extends StatelessWidget {
  final String reason;
  final double amount;

  const PaymentFailureScreen({
    super.key,
    this.reason = 'Bank server communication timeout or insufficient funds.',
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Red Error Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 72,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Payment Failed ❌',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We could not process your payment. Don\'t worry, no money was deducted from your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
              ),

              const SizedBox(height: 24),

              // Reason Card
              Card(
                color: const Color(0xFFFFF3E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.orange.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Failure Reason:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(reason, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('TRY AGAIN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                  );
                },
                child: const Text('Contact Customer Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
