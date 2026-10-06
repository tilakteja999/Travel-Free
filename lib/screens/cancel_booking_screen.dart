import 'package:flutter/material.dart';
import '../services/local_availability_service.dart';
import '../theme/app_theme.dart';

class CancelBookingScreen extends StatefulWidget {
  final String bookingId;
  final String bookingTitle;
  final String subTitle;
  final double totalPaid;
  final String bookingType;
  final List<String> selectedItems;
  final String dateStr;

  const CancelBookingScreen({
    super.key,
    required this.bookingId,
    required this.bookingTitle,
    required this.subTitle,
    required this.totalPaid,
    this.bookingType = 'Transport',
    this.selectedItems = const [],
    this.dateStr = '2026-10-29',
  });

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  String _selectedReason = 'Change of plans';
  final TextEditingController _commentController = TextEditingController();

  final List<String> _reasons = [
    'Change of plans',
    'Found a better or cheaper option',
    'Emergency situation',
    'Booked by mistake',
    'Other reason',
  ];

  double get _refundPercentage => 1.0;
  double get _cancellationFee => 0.0;
  double get _refundAmount => widget.totalPaid * _refundPercentage - _cancellationFee;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _confirmCancellation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Cancellation?'),
        content: Text(
          'Are you sure you want to cancel booking #${widget.bookingId}? You will receive a full refund of ₹${_refundAmount.toStringAsFixed(0)} to your original payment method.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep Booking'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _processReleaseAndNotify();
            },
            child: const Text('Yes, Cancel Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _processReleaseAndNotify() async {
    if (widget.bookingType == 'Hotel') {
      await LocalAvailabilityService().releaseRooms(
        widget.bookingTitle,
        widget.dateStr,
        widget.selectedItems,
      );
    } else {
      await LocalAvailabilityService().releaseSeats(
        widget.bookingTitle,
        widget.dateStr,
        widget.bookingTitle,
        widget.selectedItems,
      );
    }

    if (!mounted) return;
    _processCancellationSuccess();
  }

  void _processCancellationSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 14),
              const Text('Booking Cancelled Successfully', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                'Cancellation Ref: #CXL-${widget.bookingId}\nRefund of ₹${_refundAmount.toStringAsFixed(0)} will be credited in 3-5 business days.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Pop back with success result
                },
                child: const Text('Back to Bookings', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('Cancel Booking #${widget.bookingId}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.bookingTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: const Text('Confirmed', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.subTitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Paid Amount:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('₹${widget.totalPaid.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              color: const Color(0xFFFFF8E1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.amber.shade400),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('Applicable Cancellation Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('• More than 24 hours before trip: 100% refund', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 4),
                    const Text('• 12 to 24 hours before trip: 50% refund', style: TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text('• Less than 12 hours before trip: Non-refundable', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Refund Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount Paid'),
                        Text('₹${widget.totalPaid.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Cancellation Fee'),
                        Text('₹${_cancellationFee.toStringAsFixed(0)}'),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Refund Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('₹${_refundAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reason for Cancellation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedReason,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedReason = val);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: _confirmCancellation,
                child: const Text('CANCEL BOOKING & GET REFUND', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
