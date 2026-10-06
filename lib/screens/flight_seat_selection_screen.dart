import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../models/travel_data.dart';
import '../services/local_availability_service.dart';
import '../theme/app_theme.dart';
import 'passenger_details_screen.dart';

class FlightSeatSelectionScreen extends StatefulWidget {
  final TransportItem flight;
  final TravelSearchModel? searchModel;

  const FlightSeatSelectionScreen({
    super.key,
    required this.flight,
    this.searchModel,
  });

  @override
  State<FlightSeatSelectionScreen> createState() => _FlightSeatSelectionScreenState();
}

class _FlightSeatSelectionScreenState extends State<FlightSeatSelectionScreen> {
  final Set<String> _bookedSeats = {'12A', '12C', '14D', '15F'};
  final Set<String> _selectedSeats = {'12B'};

  bool _isLoadingAvailability = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoadingAvailability = true);
    final dateStr = widget.searchModel?.formattedDeparture ?? '2026-10-29';
    final routeKey = widget.flight.name;

    final booked = await LocalAvailabilityService().getBookedSeats(widget.flight.name, dateStr, routeKey);
    if (!mounted) return;

    setState(() {
      _bookedSeats.addAll(booked);
      _isLoadingAvailability = false;
    });
  }

  double get _seatPrice {
    final cleaned = widget.flight.price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 3450.0;
  }

  void _toggleSeat(String seatCode) {
    if (_bookedSeats.contains(seatCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seat $seatCode is already reserved.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seatCode)) {
        _selectedSeats.remove(seatCode);
      } else {
        _selectedSeats.add(seatCode);
      }
    });
  }

  void _proceedToPassengerDetails() {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one flight seat.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final sorted = _selectedSeats.toList()..sort();
    final totalPrice = sorted.length * _seatPrice;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerDetailsScreen(
          bookingTitle: widget.flight.name,
          bookingType: 'Flight',
          subTitle: '${widget.flight.numberOrVehicle} (${widget.flight.timing})',
          selectedItems: sorted.map((s) => 'Seat $s').toList(),
          totalPrice: totalPrice,
          searchModel: widget.searchModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _selectedSeats.toList()..sort();
    final totalPrice = sorted.length * _seatPrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text('${widget.flight.name} Seat Selection'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.flight.numberOrVehicle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(widget.flight.timing, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Text('₹${_seatPrice.toInt()} / seat', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoadingAvailability
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: 320,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(80), bottom: Radius.circular(20)),
                            border: Border.all(color: Colors.blueGrey, width: 2.5),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.flight_takeoff, size: 36, color: AppColors.primaryBlue),
                              const SizedBox(height: 8),
                              const Text('COCKPIT / FRONT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11)),
                              const Divider(height: 20),

                              ...List.generate(7, (rIndex) {
                                final rowNum = 12 + rIndex;
                                return _buildAirplaneRow(rowNum);
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLegendItem('AVAILABLE', const Color(0xFF7CB342)),
                            _buildLegendItem('SELECTED', const Color(0xFF26C6DA)),
                            _buildLegendItem('BOOKED', const Color(0xFF1E88E5)),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(sorted.isEmpty ? 'No seats selected' : sorted.join(", "), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('₹${totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _proceedToPassengerDetails,
                  child: const Text('Book Seats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirplaneRow(int rowNum) {
    final leftCols = ['A', 'B', 'C'];
    final rightCols = ['D', 'E', 'F'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...leftCols.map((c) => _buildFlightSeatWidget('$rowNum$c')),
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text('$rowNum', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ...rightCols.map((c) => _buildFlightSeatWidget('$rowNum$c')),
        ],
      ),
    );
  }

  Widget _buildFlightSeatWidget(String seatCode) {
    final isBooked = _bookedSeats.contains(seatCode);
    final isSelected = _selectedSeats.contains(seatCode);

    Color color;
    if (isSelected) {
      color = const Color(0xFF26C6DA);
    } else if (isBooked) {
      color = const Color(0xFF1E88E5);
    } else {
      color = const Color(0xFF7CB342);
    }

    return InkWell(
      onTap: () => _toggleSeat(seatCode),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(seatCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
