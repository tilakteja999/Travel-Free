import 'package:flutter/material.dart';
import '../features/ride_hailing/models/ride_category.dart';
import '../features/ride_hailing/models/ride_quote_model.dart';
import '../features/ride_hailing/models/ride_type.dart';
import '../features/ride_hailing/providers/ride_provider.dart';
import '../features/ride_hailing/services/ride_fare_calculator.dart';
import '../features/ride_hailing/widgets/ride_category_toggle.dart';
import '../features/ride_hailing/widgets/ride_quote_card.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/persistent_profile_widget.dart';
import 'finding_driver_screen.dart';

class RideOptionsScreen extends StatefulWidget {
  final String pickupLocation;
  final String destinationLocation;
  final int passengerCount;
  final RideCategory initialCategory;

  const RideOptionsScreen({
    super.key,
    required this.pickupLocation,
    required this.destinationLocation,
    this.passengerCount = 1,
    this.initialCategory = RideCategory.autoBike,
  });

  @override
  State<RideOptionsScreen> createState() => _RideOptionsScreenState();
}

class _RideOptionsScreenState extends State<RideOptionsScreen> {
  late String _pickup;
  late String _destination;
  late RideCategory _selectedCategory;
  late List<RideQuoteModel> _quotes;
  RideType? _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pickup = widget.pickupLocation.isNotEmpty ? widget.pickupLocation : 'Narasaraopet';
    _destination = widget.destinationLocation.isNotEmpty ? widget.destinationLocation : 'Vijayawada';
    _selectedCategory = widget.initialCategory;
    _calculateQuotes();
  }

  void _calculateQuotes() {
    setState(() => _isLoading = true);
    _quotes = RideFareCalculator.calculateAllQuotes(
      pickup: _pickup,
      destination: _destination,
      passengerCount: widget.passengerCount,
    );

    final visible = _quotes.where((q) => q.rideType.category == _selectedCategory && q.isAvailable).toList();
    if (visible.isNotEmpty) {
      _selectedType = visible.first.rideType;
    } else {
      _selectedType = null;
    }

    setState(() => _isLoading = false);
  }

  void _swapLocations() {
    setState(() {
      final temp = _pickup;
      _pickup = _destination;
      _destination = temp;
    });
    _calculateQuotes();
  }

  void _handleBookRide() async {
    if (_selectedType == null) return;

    final selectedQuote = _quotes.firstWhere((q) => q.rideType == _selectedType);
    final currentUser = AuthService().getCurrentUser();
    final userId = currentUser?.id ?? 'guest';

    final provider = RideProvider();
    final booking = await provider.createBooking(
      userId: userId,
      rideType: _selectedType!,
      pickup: _pickup,
      destination: _destination,
      quote: selectedQuote,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FindingDriverScreen(bookingId: booking.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleQuotes = _quotes.where((q) => q.rideType.category == _selectedCategory).toList();
    final distance = _quotes.isNotEmpty ? _quotes.first.routeDistanceKm : 12.5;
    final duration = _quotes.isNotEmpty ? _quotes.first.estimatedDurationMinutes : 25;

    RideQuoteModel? currentSelectedQuote;
    if (_selectedType != null) {
      for (var q in _quotes) {
        if (q.rideType == _selectedType) {
          currentSelectedQuote = q;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Your Ride', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('Demo Simulation • $distance km ($duration mins)', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: PersistentProfileWidget()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Route Summary Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Column(
                  children: [
                    Icon(Icons.circle, size: 12, color: Colors.green),
                    SizedBox(height: 20, child: VerticalDivider(thickness: 2, color: Colors.black26)),
                    Icon(Icons.location_on, size: 16, color: AppColors.vanRed),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pickup,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _destination,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_vert, color: AppColors.primaryBlue),
                  onPressed: _swapLocations,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Main Category Toggle (Auto & Bike vs Cab)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RideCategoryToggle(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (cat) {
                setState(() {
                  _selectedCategory = cat;
                  final avail = _quotes.where((q) => q.rideType.category == cat && q.isAvailable).toList();
                  if (avail.isNotEmpty) {
                    _selectedType = avail.first.rideType;
                  } else {
                    _selectedType = null;
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          // Passenger Count Alert / Guidance Banner
          if (widget.passengerCount >= 4 && _selectedCategory == RideCategory.autoBike)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'For ${widget.passengerCount} passengers, choose a Cab.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = RideCategory.cab;
                        _calculateQuotes();
                      });
                    },
                    child: const Text('View Cabs', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),

          // Rides List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : visibleQuotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.no_drinks, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text('No rides available in ${_selectedCategory.label}'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: visibleQuotes.length,
                        itemBuilder: (context, index) {
                          final quote = visibleQuotes[index];
                          return RideQuoteCard(
                            quote: quote,
                            isSelected: _selectedType == quote.rideType,
                            onTap: () {
                              setState(() {
                                _selectedType = quote.rideType;
                              });
                            },
                          );
                        },
                      ),
          ),

          // Bottom Fixed Booking CTA Button
          if (currentSelectedQuote != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -3)),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3240),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 3,
                    ),
                    onPressed: _handleBookRide,
                    child: Text(
                      'BOOK ${currentSelectedQuote.rideType.label.toUpperCase()} — ₹${currentSelectedQuote.estimatedTotal.toInt()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
