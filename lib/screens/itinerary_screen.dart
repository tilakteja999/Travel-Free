import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../models/itinerary_model.dart';
import '../providers/itinerary_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar_with_profile.dart';
import '../widgets/travel_time_navigation_drawer.dart';
import 'itinerary_detail_screen.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ItineraryProvider _provider = ItineraryProvider();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _provider.fetchItineraries().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _createNewItinerary() {
    final titleController = TextEditingController();
    final destController = TextEditingController(text: 'Tirupati');

    DateTime startDate = DateTime.now().add(const Duration(days: 7));
    DateTime endDate = DateTime.now().add(const Duration(days: 10));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Create New Trip Itinerary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Trip Title',
                      hintText: 'e.g. Tirupati Divine Pilgrimage',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: destController,
                    decoration: InputDecoration(
                      labelText: 'Destination City',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Duration: ${endDate.difference(startDate).inDays + 1} Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      TextButton(
                        onPressed: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 180)),
                          );
                          if (range != null) {
                            setDialogState(() {
                              startDate = range.start;
                              endDate = range.end;
                            });
                          }
                        },
                        child: const Text('Change Dates'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.vanRed),
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  final newItin = ItineraryModel(
                    id: 'itin_${DateTime.now().millisecondsSinceEpoch}',
                    userId: 'user@travel.com',
                    title: titleController.text.trim(),
                    destination: destController.text.trim(),
                    startDate: startDate,
                    endDate: endDate,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await _provider.saveItinerary(newItin);
                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _provider.itineraries;
    final now = DateTime.now();

    final upcoming = list.where((i) => !i.endDate.isBefore(now)).toList();
    final past = list.where((i) => i.endDate.isBefore(now)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      drawer: const TravelTimeNavigationDrawer(currentRoute: 'itinerary'),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: Column(
          children: [
            const AppBarWithProfile(title: 'My Trip Itinerary Planner'),
            Container(
              color: const Color(0xFFD6D6E8),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.vanRed,
                indicatorWeight: 3,
                labelColor: AppColors.textDark,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'Upcoming Trips'),
                  Tab(text: 'Past Trips'),
                  Tab(text: 'Draft Plans'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.vanRed,
        foregroundColor: Colors.white,
        onPressed: _createNewItinerary,
        icon: const Icon(Icons.add),
        label: const Text('Start Planning'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItineraryListView(upcoming),
          _buildItineraryListView(past),
          _buildItineraryListView(list),
        ],
      ),
    );
  }

  Widget _buildItineraryListView(List<ItineraryModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No trip itineraries planned yet.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              onPressed: _createNewItinerary,
              child: const Text('Start Planning A Trip', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final itin = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ItineraryDetailScreen(itinerary: itin)),
              );
              _provider.fetchItineraries().then((_) {
                if (mounted) setState(() {});
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(itin.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${itin.durationDays} Days', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('📍 Destination: ${itin.destination}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📅 ${TravelSearchModel.formatShortDate(itin.startDate)} - ${TravelSearchModel.formatShortDate(itin.endDate)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Bookings: ${itin.linkedBookingIds.length} • Saved: ${itin.savedPlaceIds.length}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
