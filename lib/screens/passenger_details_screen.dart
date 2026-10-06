import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../theme/app_theme.dart';
import 'payment_screen.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final String bookingTitle;
  final String bookingType; // Bus, Train, Flight, Hotel
  final String subTitle;
  final List<String> selectedItems; // e.g. ['Seat 19', 'Seat 20']
  final double totalPrice;
  final TravelSearchModel? searchModel;

  const PassengerDetailsScreen({
    super.key,
    required this.bookingTitle,
    required this.bookingType,
    required this.subTitle,
    required this.selectedItems,
    required this.totalPrice,
    this.searchModel,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late List<TextEditingController> _nameControllers;
  late List<TextEditingController> _ageControllers;
  late List<String> _genders;
  bool _isProcessing = false;

  final TextEditingController _contactPhoneController = TextEditingController(text: '9876543210');
  final TextEditingController _contactEmailController = TextEditingController(text: 'passenger@example.com');

  @override
  void initState() {
    super.initState();
    final count = widget.selectedItems.length;
    _nameControllers = List.generate(count, (i) => TextEditingController());
    _ageControllers = List.generate(count, (i) => TextEditingController());
    _genders = List.generate(count, (i) => 'Male');
  }

  @override
  void dispose() {
    for (var c in _nameControllers) {
      c.dispose();
    }
    for (var c in _ageControllers) {
      c.dispose();
    }
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (_isProcessing) return; // Duplicate action prevention

    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      final passengerList = <Map<String, String>>[];
      for (int i = 0; i < widget.selectedItems.length; i++) {
        passengerList.add({
          'seatOrRoom': widget.selectedItems[i],
          'name': _nameControllers[i].text.trim(),
          'age': _ageControllers[i].text.trim(),
          'gender': _genders[i],
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            bookingTitle: widget.bookingTitle,
            bookingType: widget.bookingType,
            subTitle: widget.subTitle,
            selectedItems: widget.selectedItems,
            totalPrice: widget.totalPrice,
            passengerList: passengerList,
            contactPhone: _contactPhoneController.text.trim(),
            contactEmail: _contactEmailController.text.trim(),
            searchModel: widget.searchModel,
          ),
        ),
      ).then((_) {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('${widget.bookingType} Passenger Details'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top Summary Card
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForType(widget.bookingType),
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bookingTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${widget.selectedItems.length} Person(s) / Room(s) • ${widget.selectedItems.join(", ")}',
                          style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${widget.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Passengers Form List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(widget.selectedItems.length, (index) {
                      return _buildPassengerCard(index);
                    }),

                    const SizedBox(height: 12),

                    // Contact Info Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.contact_mail_outlined, color: AppColors.primaryBlue),
                                SizedBox(width: 8),
                                Text(
                                  'Contact Details for Ticket & Invoice',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _contactPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Enter mobile number' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _contactEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.email),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Enter email address' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -3))
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isProcessing ? null : _proceedToPayment,
                  child: Text(
                    _isProcessing ? 'PROCESSING...' : 'Continue Booking & Pay',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Bus':
        return Icons.directions_bus;
      case 'Train':
        return Icons.train;
      case 'Flight':
        return Icons.flight;
      default:
        return Icons.hotel;
    }
  }

  Widget _buildPassengerCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.bookingType == "Hotel" ? "Guest" : "Passenger"} ${index + 1} (${widget.selectedItems[index]})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.selectedItems[index],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameControllers[index],
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'e.g. Rahul Sharma',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age (Adult 12+, Child 2-11)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.cake),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter age';
                      final age = int.tryParse(val.trim());
                      if (age == null || age < 0 || age > 120) return 'Valid age (0-120)';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _genders[index],
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _genders[index] = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
