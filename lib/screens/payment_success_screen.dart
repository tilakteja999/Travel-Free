import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String bookingTitle;
  final String bookingType;
  final String subTitle;
  final List<String> selectedItems;
  final double totalPaid;
  final List<Map<String, String>> passengerList;
  final String paymentMethod;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingTitle,
    required this.bookingType,
    required this.subTitle,
    required this.selectedItems,
    required this.totalPaid,
    required this.passengerList,
    required this.paymentMethod,
  });

  String get _bookingId => 'TRV-${bookingType.substring(0, 3).toUpperCase()}-${Random().nextInt(90000) + 10000}';
  String get _txnId => 'TXN-${Random().nextInt(89999999) + 10000000}';

  void _shareDetails() {
    final text = '🎉 My booking on Travel Time is confirmed!\n\nBooking Reference: #$_bookingId\nRoute: $bookingTitle\nItems: ${selectedItems.join(", ")}\nTotal Paid: ₹${totalPaid.toStringAsFixed(0)}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Green Checkmark Animation Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 72,
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Payment Successful! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your ticket has been booked and confirmed.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Booking Reference Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bookingTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text(subTitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _bookingId,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 12),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Seats & Payment Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BOOKED SEATS/ROOMS', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(selectedItems.join(", "), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('TOTAL PAID', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('₹${totalPaid.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Transaction Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Txn ID: $_txnId', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text('Method: $paymentMethod', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // QR Code Mock
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.qr_code_2,
                                size: 100,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text('Scan QR code at boarding / check-in', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _shareDetails,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share Ticket', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home, size: 18),
                      label: const Text('Home Screen', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
