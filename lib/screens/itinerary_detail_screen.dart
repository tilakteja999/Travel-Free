import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../models/itinerary_model.dart';
import '../theme/app_theme.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final ItineraryModel itinerary;

  const ItineraryDetailScreen({super.key, required this.itinerary});

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  late ItineraryModel _itin;

  @override
  void initState() {
    super.initState();
    _itin = widget.itinerary;
  }

  void _shareItinerary() {
    final text = '🗺️ Travel Itinerary: ${_itin.title}\n📍 Destination: ${_itin.destination}\n📅 ${TravelSearchModel.formatShortDate(_itin.startDate)} to ${TravelSearchModel.formatShortDate(_itin.endDate)}\n\nDemo trip plan generated on Travel Time!';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(_itin.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareItinerary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination & Date Header
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
                        Text(_itin.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                          child: const Text('DEMO ITINERARY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('📍 Destination: ${_itin.destination}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('📅 Duration: ${TravelSearchModel.formatShortDate(_itin.startDate)} - ${TravelSearchModel.formatShortDate(_itin.endDate)} (${_itin.durationDays} Days)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Linked Confirmed Bookings Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.confirmation_number, color: AppColors.primaryBlue),
                        SizedBox(width: 8),
                        Text('Linked Confirmed Bookings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_itin.linkedBookingIds.isEmpty)
                      const Text('No bookings linked to this trip itinerary.', style: TextStyle(fontSize: 12, color: Colors.grey))
                    else
                      ..._itin.linkedBookingIds.map((id) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Text('Booking Reference: #$id', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Saved Places to Visit Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.place, color: AppColors.vanRed),
                        SizedBox(width: 8),
                        Text('Planned Tourist Attractions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_itin.savedPlaceIds.isEmpty)
                      const Text('No places added yet.', style: TextStyle(fontSize: 12, color: Colors.grey))
                    else
                      ..._itin.savedPlaceIds.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Day-by-day Timeline
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.timeline, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Day-by-Day Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_itin.durationDays, (index) {
                      final dayKey = 'Day ${index + 1}';
                      final note = _itin.dayNotes[dayKey] ?? 'Exploration and local sightseeing.';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dayKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple)),
                            const SizedBox(height: 2),
                            Text(note, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
