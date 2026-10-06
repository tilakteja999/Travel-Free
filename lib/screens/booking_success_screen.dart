import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../theme/app_theme.dart';
import '../widgets/demo_mode_banner.dart';
import 'home_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String bookingTitle;
  final String bookingType;
  final String subTitle;
  final List<String> selectedItems;
  final double totalPaid;
  final List<Map<String, String>> passengerList;
  final String paymentMethod;
  final String? bookingId;
  final TravelSearchModel? searchModel;

  const BookingSuccessScreen({
    super.key,
    required this.bookingTitle,
    required this.bookingType,
    required this.subTitle,
    required this.selectedItems,
    required this.totalPaid,
    required this.passengerList,
    required this.paymentMethod,
    this.bookingId,
    this.searchModel,
  });

  String get _finalBookingId => bookingId ?? 'TRV-${bookingType.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 100000}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

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
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your booking has been saved locally & confirmed.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 20),

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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bookingTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text(subTitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _finalBookingId,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 12),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

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

                      const Text('PASSENGER / GUEST DETAILS', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...passengerList.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${p['name']} (${p['gender']}, ${p['age']} yrs)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(p['seatOrRoom'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

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
                            const Text('Scan ticket at boarding / check-in', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ticket Demo Footer Notice
                      const DemoModeBanner(
                        text: 'DEMO TICKET — NOT VALID FOR TRAVEL OR CHECK-IN.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('E-Ticket PDF Downloaded! (DEMO TICKET)')),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download PDF', style: TextStyle(fontSize: 13)),
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
