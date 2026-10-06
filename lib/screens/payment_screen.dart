import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../models/booking_model.dart';
import '../repositories/local_booking_repository.dart';
import '../services/auth_service.dart';
import '../services/local_availability_service.dart';
import '../theme/app_theme.dart';
import '../widgets/demo_mode_banner.dart';
import 'booking_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingTitle;
  final String bookingType;
  final String subTitle;
  final List<String> selectedItems;
  final double totalPrice;
  final List<Map<String, String>> passengerList;
  final String contactPhone;
  final String contactEmail;
  final TravelSearchModel? searchModel;

  const PaymentScreen({
    super.key,
    required this.bookingTitle,
    required this.bookingType,
    required this.subTitle,
    required this.selectedItems,
    required this.totalPrice,
    required this.passengerList,
    required this.contactPhone,
    required this.contactEmail,
    this.searchModel,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'UPI (Demo)';
  bool _isProcessing = false;

  final TextEditingController _upiController = TextEditingController(text: 'demo@upi');
  final TextEditingController _cardNumberController = TextEditingController(text: '4111 •••• •••• 1111');
  final TextEditingController _cardExpiryController = TextEditingController(text: '12/28');
  final TextEditingController _cardCvvController = TextEditingController(text: '•••');

  double get _taxAmount => (widget.totalPrice * 0.05).roundToDouble();
  double get _convenienceFee => 20.0;
  double get _finalTotal => widget.totalPrice + _taxAmount + _convenienceFee;

  void _handlePayAndConfirm() {
    if (_isProcessing) return; // Prevent duplicate submission

    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Simulating Demo Payment...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'No real money will be charged.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () async {
      final dateStr = widget.bookingType == 'Hotel'
          ? (widget.searchModel?.formattedCheckIn ?? '2026-10-29')
          : (widget.searchModel?.formattedDeparture ?? '2026-10-29');

      final prefix = widget.bookingType.substring(0, 3).toUpperCase();
      final bookingId = 'TRV-$prefix-${DateTime.now().millisecondsSinceEpoch % 100000}';
      final txnId = 'DEMO-TXN-${DateTime.now().millisecondsSinceEpoch % 10000000}';

      final user = AuthService().getCurrentUser();
      final userId = user?.id ?? 'guest';

      // Save Availability Inventory
      if (widget.bookingType == 'Hotel') {
        await LocalAvailabilityService().bookRooms(
          widget.bookingTitle,
          dateStr,
          widget.selectedItems,
          bookingId,
        );
      } else {
        await LocalAvailabilityService().bookSeats(
          widget.bookingTitle,
          dateStr,
          widget.bookingTitle,
          widget.selectedItems,
          bookingId,
        );
      }

      // Determine Booking Type Enum
      BookingType bType = BookingType.train;
      if (widget.bookingType == 'Bus') bType = BookingType.bus;
      if (widget.bookingType == 'Flight') bType = BookingType.flight;
      if (widget.bookingType == 'Hotel') bType = BookingType.hotel;
      if (widget.bookingType == 'Auto') bType = BookingType.auto;
      if (widget.bookingType == 'Cab') bType = BookingType.cab;

      // Save Central Booking
      final centralBooking = BookingModel(
        bookingId: bookingId,
        userId: userId,
        bookingType: bType,
        status: BookingStatus.confirmed,
        fromLocation: widget.searchModel?.fromLocation ?? 'Narasaraopet',
        toLocation: widget.searchModel?.toLocation ?? 'Tirupati',
        hotelName: widget.bookingType == 'Hotel' ? widget.bookingTitle : null,
        createdAt: DateTime.now(),
        departureDateTime: widget.searchModel?.departureDate ?? DateTime.now().add(const Duration(days: 1)),
        passengers: widget.passengerList
            .map((p) => PassengerModel(
                  name: p['name'] ?? 'Passenger',
                  age: int.tryParse(p['age'] ?? '25') ?? 25,
                  gender: p['gender'] ?? 'Male',
                  seatOrRoomCode: p['seatOrRoom'],
                ))
            .toList(),
        selectedSeatIds: widget.bookingType != 'Hotel' ? widget.selectedItems : [],
        selectedRoomIds: widget.bookingType == 'Hotel' ? widget.selectedItems : [],
        baseFare: widget.totalPrice,
        taxes: _taxAmount,
        convenienceFee: _convenienceFee,
        totalAmount: _finalTotal,
        paymentMethod: _selectedPaymentMethod,
        localTransactionId: txnId,
        isDemoBooking: true,
      );

      await LocalBookingRepository().saveBooking(centralBooking);

      if (!mounted) return;
      Navigator.pop(context); // Close dialog

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(
            bookingTitle: widget.bookingTitle,
            bookingType: widget.bookingType,
            subTitle: widget.subTitle,
            selectedItems: widget.selectedItems,
            totalPaid: _finalTotal,
            passengerList: widget.passengerList,
            paymentMethod: _selectedPaymentMethod,
            bookingId: bookingId,
            searchModel: widget.searchModel,
          ),
        ),
        (route) => route.isFirst,
      );
    });
  }

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Demo Payment Options'),
      ),
      body: Column(
        children: [
          // Demo Banner Top
          const Padding(
            padding: EdgeInsets.all(12),
            child: DemoModeBanner(
              text: 'Demo Mode — no real money or live payment gateways involved.',
            ),
          ),

          // Total Fare Summary Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL PAYABLE AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text('₹${_finalTotal.toInt()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.vanRed)),
                  ],
                ),
                Text('Includes taxes & fees (5%)', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Payment Options Selection
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPaymentMethodTile(
                  title: 'UPI Payment (Demo)',
                  subtitle: 'GPay, PhonePe, Paytm (Simulated)',
                  value: 'UPI (Demo)',
                  icon: Icons.qr_code,
                  child: TextField(
                    controller: _upiController,
                    decoration: const InputDecoration(labelText: 'Demo VPA / UPI ID', border: OutlineInputBorder()),
                  ),
                ),
                _buildPaymentMethodTile(
                  title: 'Credit / Debit Card (Demo)',
                  subtitle: 'Visa, MasterCard, RuPay (Simulated)',
                  value: 'Card (Demo)',
                  icon: Icons.credit_card,
                  child: Column(
                    children: [
                      TextField(controller: _cardNumberController, decoration: const InputDecoration(labelText: 'Card Number', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _cardExpiryController, decoration: const InputDecoration(labelText: 'MM/YY', border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: _cardCvvController, obscureText: true, decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()))),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildPaymentMethodTile(
                  title: 'Net Banking (Demo)',
                  subtitle: 'SBI, HDFC, ICICI, Axis (Simulated)',
                  value: 'Net Banking (Demo)',
                  icon: Icons.account_balance,
                ),
                _buildPaymentMethodTile(
                  title: 'Wallet / Pay Later (Demo)',
                  subtitle: 'Amazon Pay, Mobikwik (Simulated)',
                  value: 'Wallet (Demo)',
                  icon: Icons.account_balance_wallet,
                ),
              ],
            ),
          ),

          // Pay Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: _isProcessing ? null : _handlePayAndConfirm,
                  child: Text(
                    'SIMULATE PAYMENT ₹${_finalTotal.toInt()} & CONFIRM',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    Widget? child,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            RadioListTile<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              activeColor: AppColors.primaryBlue,
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              secondary: Icon(icon, color: AppColors.primaryBlue),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPaymentMethod = val);
              },
            ),
            if (isSelected && child != null) ...[
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: child),
            ],
          ],
        ),
      ),
    );
  }
}
