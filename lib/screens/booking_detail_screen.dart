import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/whatsapp_support_button.dart';
import 'cancel_booking_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late Map<String, dynamic> _currentBooking;

  @override
  void initState() {
    super.initState();
    _currentBooking = Map<String, dynamic>.from(widget.booking);
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentBooking['status'] ?? 'Confirmed';
    final isCancelled = status == 'Cancelled';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('Booking #${_currentBooking['bookingId']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Ticket Card
            Card(
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
                            Text(_currentBooking['title'] ?? 'Route', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(_currentBooking['subTitle'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCancelled ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isCancelled ? Colors.red.shade300 : Colors.green.shade300),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isCancelled ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TRAVEL DATE', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_currentBooking['date'] ?? '15 Oct 2026', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TOTAL PAID', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('₹${_currentBooking['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Text('BOOKED SEATS/ROOMS', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_currentBooking['items'] ?? 'Seat 12', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 14)),

                    const SizedBox(height: 20),

                    // QR Code Box
                    if (!isCancelled)
                      Center(
                        child: Column(
                          children: const [
                            Icon(Icons.qr_code_2, size: 100, color: AppColors.textDark),
                            SizedBox(height: 4),
                            Text('Boarding Pass QR Code', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Help & Cancellation Actions
            if (!isCancelled) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CancelBookingScreen(
                          bookingId: _currentBooking['bookingId'],
                          bookingTitle: _currentBooking['title'],
                          subTitle: _currentBooking['subTitle'],
                          totalPaid: double.tryParse(_currentBooking['amount'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 2535.0,
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _currentBooking['status'] = 'Cancelled';
                      });
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Booking & Refund', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            WhatsAppSupportButton(bookingId: _currentBooking['bookingId']),
          ],
        ),
      ),
    );
  }
}
