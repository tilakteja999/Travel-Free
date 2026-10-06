import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../models/travel_data.dart';
import '../services/local_availability_service.dart';
import '../theme/app_theme.dart';
import 'passenger_details_screen.dart';

class TrainBerthSelectionScreen extends StatefulWidget {
  final TransportItem train;
  final TravelSearchModel? searchModel;

  const TrainBerthSelectionScreen({
    super.key,
    required this.train,
    this.searchModel,
  });

  @override
  State<TrainBerthSelectionScreen> createState() => _TrainBerthSelectionScreenState();
}

class _TrainBerthSelectionScreenState extends State<TrainBerthSelectionScreen> {
  String _selectedCoach = 'B1 (3AC)';
  final List<String> _coaches = ['S1 (Sleeper)', 'B1 (3AC)', 'B2 (3AC)', 'A1 (2AC)', 'H1 (1AC)'];

  final Set<String> _bookedBerths = {'B1-12 (LB)', 'B1-15 (UB)', 'B1-18 (SL)'};
  final Set<String> _selectedBerths = {};

  bool _isLoadingAvailability = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoadingAvailability = true);
    final dateStr = widget.searchModel?.formattedDeparture ?? '2026-10-29';
    final routeKey = '${widget.train.name}_$_selectedCoach';

    final booked = await LocalAvailabilityService().getBookedSeats(widget.train.name, dateStr, routeKey);
    if (!mounted) return;

    setState(() {
      _bookedBerths.addAll(booked);
      _isLoadingAvailability = false;
    });
  }

  double get _berthPrice {
    final cleaned = widget.train.price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 450.0;
  }

  void _toggleBerth(String berthCode) {
    if (_bookedBerths.contains(berthCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berth $berthCode is already booked by another passenger.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      if (_selectedBerths.contains(berthCode)) {
        _selectedBerths.remove(berthCode);
      } else {
        _selectedBerths.add(berthCode);
      }
    });
  }

  void _proceedToPassengerDetails() {
    if (_selectedBerths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one berth.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final sortedBerths = _selectedBerths.toList()..sort();
    final totalPrice = sortedBerths.length * _berthPrice;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerDetailsScreen(
          bookingTitle: widget.train.name,
          bookingType: 'Train',
          subTitle: '${widget.train.numberOrVehicle} • Coach $_selectedCoach',
          selectedItems: sortedBerths,
          totalPrice: totalPrice,
          searchModel: widget.searchModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedBerths = _selectedBerths.toList()..sort();
    final totalPrice = sortedBerths.length * _berthPrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(widget.train.name),
      ),
      body: Column(
        children: [
          // Coach Selector Bar
          Container(
            color: Colors.white,
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _coaches.length,
              itemBuilder: (context, index) {
                final coach = _coaches[index];
                final isSelected = coach == _selectedCoach;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(coach),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedCoach = coach);
                        _loadAvailability();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Train Coach Layout
          Expanded(
            child: _isLoadingAvailability
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Select Train Berth (Lower / Middle / Upper / Side)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 16),

                        // Coach Container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade400, width: 2),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                          ),
                          child: Column(
                            children: [
                              _buildCabinSection('Cabin 1', ['1 (LB)', '2 (MB)', '3 (UB)', '4 (LB)', '5 (MB)', '6 (UB)', '7 (SL)', '8 (SU)']),
                              const SizedBox(height: 16),
                              _buildCabinSection('Cabin 2', ['9 (LB)', '10 (MB)', '11 (UB)', '12 (LB)', '13 (MB)', '14 (LB)', '15 (SL)', '16 (SU)']),
                              const SizedBox(height: 16),
                              _buildCabinSection('Cabin 3', ['17 (LB)', '18 (MB)', '19 (UB)', '20 (LB)', '21 (MB)', '22 (UB)', '23 (SL)', '24 (SU)']),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Legend
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

          // Bottom Action Bar
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
                      Text(sortedBerths.isEmpty ? 'No berths selected' : sortedBerths.join(", "), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                  child: const Text('Book Berths', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCabinSection(String title, List<String> berthLabels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: berthLabels.map((label) {
            final fullCode = 'B1-$label';
            final isBooked = _bookedBerths.contains(fullCode);
            final isSelected = _selectedBerths.contains(fullCode);

            Color color;
            if (isSelected) {
              color = const Color(0xFF26C6DA);
            } else if (isBooked) {
              color = const Color(0xFF1E88E5);
            } else {
              color = const Color(0xFF7CB342);
            }

            return InkWell(
              onTap: () => _toggleBerth(fullCode),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            );
          }).toList(),
        ),
      ],
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
