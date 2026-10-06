import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../models/travel_data.dart';
import '../services/local_availability_service.dart';
import '../theme/app_theme.dart';
import 'passenger_details_screen.dart';

class BusSeatSelectionScreen extends StatefulWidget {
  final TransportItem bus;
  final TravelSearchModel? searchModel;

  const BusSeatSelectionScreen({
    super.key,
    required this.bus,
    this.searchModel,
  });

  @override
  State<BusSeatSelectionScreen> createState() => _BusSeatSelectionScreenState();
}

class _BusSeatSelectionScreenState extends State<BusSeatSelectionScreen> {
  final Set<int> _bookedSeats = {1, 3, 10, 12, 13, 15, 16, 23, 24, 28, 29, 31};
  final Set<int> _selectedSeats = {19, 20};

  bool _isLoadingAvailability = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoadingAvailability = true);
    final dateStr = widget.searchModel?.formattedDeparture ?? '2026-10-29';
    final routeKey = widget.bus.name;

    final booked = await LocalAvailabilityService().getBookedSeats(widget.bus.name, dateStr, routeKey);
    if (!mounted) return;

    setState(() {
      for (var code in booked) {
        final seatNum = int.tryParse(code.replaceAll(RegExp(r'[^0-9]'), ''));
        if (seatNum != null) {
          _bookedSeats.add(seatNum);
        }
      }
      _isLoadingAvailability = false;
    });
  }

  double get _seatPrice {
    final cleaned = widget.bus.price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 378.0;
  }

  void _toggleSeat(int seatNumber) {
    if (_bookedSeats.contains(seatNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seat $seatNumber is already booked by another passenger.'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seatNumber)) {
        _selectedSeats.remove(seatNumber);
      } else {
        _selectedSeats.add(seatNumber);
      }
    });
  }

  void _proceedToPassengerDetails() {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one seat to proceed.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final sortedSeats = _selectedSeats.toList()..sort();
    final totalPrice = sortedSeats.length * _seatPrice;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerDetailsScreen(
          bookingTitle: widget.bus.name,
          bookingType: 'Bus',
          subTitle: '${widget.bus.numberOrVehicle} (${widget.bus.timing})',
          selectedItems: sortedSeats.map((s) => 'Seat $s').toList(),
          totalPrice: totalPrice,
          searchModel: widget.searchModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedSelected = _selectedSeats.toList()..sort();
    final totalPrice = sortedSelected.length * _seatPrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.bus.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.bus.numberOrVehicle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Seats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(widget.bus.timing, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₹${_seatPrice.toInt()} / seat',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Bus Layout View
          Expanded(
            child: _isLoadingAvailability
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFF37474F), width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade700,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text('FRONT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
                                  const SizedBox(width: 20),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),

                              _buildBusSeatingGrid(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildLegendItem('SELECTED', const Color(0xFF26C6DA)),
                              _buildLegendItem('AVAILABLE', const Color(0xFF7CB342)),
                              _buildLegendItem('BOOKED', const Color(0xFF1E88E5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -3)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedSeats.isEmpty
                            ? 'No seats selected'
                            : 'Seats: ${sortedSelected.join(", ")}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildBusSeatingGrid() {
    final row1 = [1, 8, 9, 16, 17, 24, 25, 32, 33, 40];
    final row2 = [2, 7, 10, 15, 18, 23, 26, 31, 34, 39];
    final row3 = [3, 6, 11, 14, 19, 22, 27, 30, 35, 38];
    final row4 = [4, 5, 12, 13, 20, 21, 28, 29, 36, 37];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(children: row1.map((seatNum) => _buildSeatWidget(seatNum)).toList()),
          const SizedBox(height: 6),
          Row(children: row2.map((seatNum) => _buildSeatWidget(seatNum)).toList()),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            height: 24,
            width: row1.length * 52.0,
            alignment: Alignment.centerLeft,
            child: Row(
              children: const [
                Icon(Icons.directions_walk, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text('AISLE', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 3)),
              ],
            ),
          ),

          Row(children: row3.map((seatNum) => _buildSeatWidget(seatNum)).toList()),
          const SizedBox(height: 6),
          Row(children: row4.map((seatNum) => _buildSeatWidget(seatNum)).toList()),
        ],
      ),
    );
  }

  Widget _buildSeatWidget(int seatNumber) {
    final isBooked = _bookedSeats.contains(seatNumber);
    final isSelected = _selectedSeats.contains(seatNumber);

    Color seatColor;
    if (isSelected) {
      seatColor = const Color(0xFF26C6DA);
    } else if (isBooked) {
      seatColor = const Color(0xFF1E88E5);
    } else {
      seatColor = const Color(0xFF7CB342);
    }

    return InkWell(
      onTap: () => _toggleSeat(seatNumber),
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.cyanAccent : Colors.black12,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.cyan.withOpacity(0.4),
                blurRadius: 6,
                spreadRadius: 1,
              )
          ],
        ),
        child: Center(
          child: Text(
            '$seatNumber',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
