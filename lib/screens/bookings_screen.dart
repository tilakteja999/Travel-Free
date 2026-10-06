import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../features/filters_sorting/filter_model.dart';
import '../features/filters_sorting/filter_repository.dart';
import '../features/ride_hailing/models/ride_category.dart';
import '../models/travel_data.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import '../widgets/persistent_profile_widget.dart';
import '../widgets/results_filter_header.dart';
import 'bus_seat_selection_screen.dart';
import 'flight_seat_selection_screen.dart';
import 'ride_options_screen.dart';
import 'train_berth_selection_screen.dart';

class BookingsScreen extends StatefulWidget {
  final String location;
  final String? fromLocation;
  final TravelSearchModel? searchModel;

  const BookingsScreen({
    super.key,
    this.location = 'Tirupati',
    this.fromLocation,
    this.searchModel,
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _selectedCategory = 'Train';
  late String _origin;
  late String _destination;

  FilterModel _activeFilter = const FilterModel();

  final List<String> _categories = ['Train', 'Bus', 'Flight', 'Cab', 'Auto'];

  @override
  void initState() {
    super.initState();
    _origin = widget.fromLocation ?? widget.searchModel?.fromLocation ?? 'Narasaraopet';
    _destination = widget.location.isNotEmpty ? widget.location : (widget.searchModel?.toLocation ?? 'Tirupati');
  }

  void _swapRoute() {
    setState(() {
      final temp = _origin;
      _origin = _destination;
      _destination = temp;
    });
  }

  void _openRideOptions(RideCategory initialCat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideOptionsScreen(
          pickupLocation: _origin,
          destinationLocation: _destination,
          passengerCount: widget.searchModel?.totalTravellers ?? 1,
          initialCategory: initialCat,
        ),
      ),
    );
  }

  List<TransportItem> _getRawTransportItems() {
    if (_selectedCategory == 'Train') {
      return [
        TransportItem(
          name: 'Palnadu Superfast Express ($_origin → $_destination)',
          type: 'Train',
          numberOrVehicle: '12748 - Express',
          timing: '06:10 AM -> 11:45 AM (5h 35m)',
          price: '₹380',
          rating: 4.6,
          badgeText: 'Daily',
        ),
        TransportItem(
          name: 'Sabari Express ($_origin → $_destination)',
          type: 'Train',
          numberOrVehicle: '17230 - Express',
          timing: '12:20 PM -> 06:15 PM (5h 55m)',
          price: '₹420',
          rating: 4.7,
          badgeText: 'Daily',
        ),
        TransportItem(
          name: 'Narayanadri Express ($_origin → $_destination)',
          type: 'Train',
          numberOrVehicle: '12734 - Express',
          timing: '09:30 PM -> 04:30 AM (7h 00m)',
          price: '₹485',
          rating: 4.8,
          badgeText: 'Daily',
        ),
      ];
    }

    if (_selectedCategory == 'Bus') {
      return [
        TransportItem(
          name: 'APSRTC Garuda Super Luxury ($_origin → $_destination)',
          type: 'Bus',
          numberOrVehicle: 'AP 07 Z 4512',
          timing: '08:30 AM -> 02:00 PM (5h 30m)',
          price: '₹550',
          rating: 4.7,
          badgeText: 'AC Seater',
        ),
        TransportItem(
          name: 'Morning Star Travels Volvo Multi-Axle',
          type: 'Bus',
          numberOrVehicle: 'AP 16 TJ 8820',
          timing: '09:45 PM -> 04:30 AM (6h 45m)',
          price: '₹850',
          rating: 4.8,
          badgeText: 'AC Sleeper',
        ),
      ];
    }

    if (_selectedCategory == 'Flight') {
      final isSmallTown = _origin.toLowerCase().contains('narasaraopet') || _origin.toLowerCase().contains('tenali');
      if (isSmallTown) {
        return [];
      }
      return [
        TransportItem(
          name: 'IndiGo 6E-712 ($_origin → $_destination)',
          type: 'Flight',
          numberOrVehicle: '6E 712',
          timing: '07:15 AM -> 08:25 AM (1h 10m)',
          price: '₹3,450',
          rating: 4.8,
          badgeText: 'Direct Flight',
        ),
      ];
    }

    return [
      TransportItem(
        name: 'Direct Local $_selectedCategory ($_origin → $_destination)',
        type: _selectedCategory,
        numberOrVehicle: 'Instant Ride Hailing',
        timing: 'Available on Demand (24/7)',
        price: '₹140 - ₹390',
        rating: 4.8,
        badgeText: 'Instant Ride',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rawItems = _getRawTransportItems();
    final filteredItems = FilterRepository.applyTransportFilters(rawItems, _activeFilter);

    String? dateSummary;
    if (widget.searchModel?.departureDate != null) {
      dateSummary = 'Departure: ${TravelSearchModel.formatTravelDate(widget.searchModel!.departureDate!)}';
      if (widget.searchModel!.isRoundTrip && widget.searchModel!.returnDate != null) {
        dateSummary += ' | Return: ${TravelSearchModel.formatTravelDate(widget.searchModel!.returnDate!)}';
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Painter
          Positioned.fill(
            child: CustomPaint(
              painter: TransportScenicPainter(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header Row
                Container(
                  color: Colors.white.withValues(alpha: 0.92),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$_selectedCategory Search Results',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const PersistentProfileWidget(),
                    ],
                  ),
                ),

                // Horizontal Category Chips Row
                Container(
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              if (category == 'Auto') {
                                _openRideOptions(RideCategory.autoBike);
                              } else if (category == 'Cab') {
                                _openRideOptions(RideCategory.cab);
                              } else {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Filter & Sort Header Bar
                ResultsFilterHeader(
                  title: '$_origin → $_destination',
                  dateSummary: dateSummary,
                  filterModel: _activeFilter,
                  resultCount: filteredItems.length,
                  onFilterChanged: (updated) {
                    setState(() {
                      _activeFilter = updated;
                    });
                  },
                ),

                // Route Display Banner
                Container(
                  color: Colors.white.withValues(alpha: 0.9),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _origin,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, color: AppColors.primaryBlue, size: 20),
                        onPressed: _swapRoute,
                      ),
                      Text(
                        _destination,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Results List View
                Expanded(
                  child: _buildResultsView(filteredItems, rawItems.length),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(List<TransportItem> filteredItems, int totalRawCount) {
    if (_selectedCategory == 'Flight' && totalRawCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade300, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flight_takeoff, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                Text(
                  'No Direct Flights Available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sorry, there are no direct commercial airports operating in $_origin.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Text(
                  '💡 Recommendation: Nearest airport is Vijayawada Airport (VGA) or Tirupati Airport (TIR). You can book Trains or Buses directly from $_origin!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Text(item.badgeText, style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${item.numberOrVehicle} • ${item.timing}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fare: ${item.price}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.vanRed)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3240),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (_selectedCategory == 'Train') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TrainBerthSelectionScreen(train: item)),
                          );
                        } else if (_selectedCategory == 'Bus') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BusSeatSelectionScreen(bus: item)),
                          );
                        } else if (_selectedCategory == 'Flight') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FlightSeatSelectionScreen(flight: item)),
                          );
                        } else if (_selectedCategory == 'Auto') {
                          _openRideOptions(RideCategory.autoBike);
                        } else if (_selectedCategory == 'Cab') {
                          _openRideOptions(RideCategory.cab);
                        }
                      },
                      child: Text(
                        _selectedCategory == 'Train'
                            ? 'Select Berths'
                            : (_selectedCategory == 'Bus' || _selectedCategory == 'Flight' ? 'Select Seats' : 'Book Ride'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
