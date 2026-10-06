import 'package:flutter/material.dart';
import '../features/ride_hailing/models/ride_status.dart';
import '../features/ride_hailing/models/ride_type.dart';
import '../features/ride_hailing/repositories/local_ride_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/persistent_profile_widget.dart';
import 'booking_detail_screen.dart';
import 'location_search_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Trains', 'Buses', 'Flights', 'Hotels', 'Bikes', 'Autos', 'Cabs'];

  List<Map<String, dynamic>> _allBookings = [];

  final List<Map<String, dynamic>> _mockBookings = [
    {
      'bookingId': 'TRV-TRA-84920',
      'title': 'Palnadu Express (Narasaraopet → Tirupati)',
      'subTitle': 'Superfast Express • B1 3AC',
      'date': '15 Oct 2026',
      'status': 'Confirmed',
      'category': 'Trains',
      'amount': '2,535',
      'items': 'Coach B1 - Seats 19, 20',
      'monthGroup': 'October 2026',
    },
    {
      'bookingId': 'TRV-BUS-61294',
      'title': 'APSRTC Garuda Luxury (Guntur → Vijayawada)',
      'subTitle': 'AC Multi-Axle Sleeper',
      'date': '28 Oct 2026',
      'status': 'Confirmed',
      'category': 'Buses',
      'amount': '1,100',
      'items': 'Seats 14, 15',
      'monthGroup': 'October 2026',
    },
    {
      'bookingId': 'TRV-HTL-19402',
      'title': 'Lotus Grand Hotel & Restaurant',
      'subTitle': 'Standard AC Room • 2 Nights',
      'date': '05 Sep 2026',
      'status': 'Completed',
      'category': 'Hotels',
      'amount': '4,800',
      'items': 'Room 101, Room 102',
      'monthGroup': 'September 2026',
    },
    {
      'bookingId': 'TRV-FLT-39201',
      'title': 'IndiGo 6E-712 (Vijayawada → Hyderabad)',
      'subTitle': 'Economy Class',
      'date': '12 Aug 2026',
      'status': 'Cancelled',
      'category': 'Flights',
      'amount': '3,450',
      'items': 'Seat 14A',
      'monthGroup': 'August 2026',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllBookings();
  }

  void _loadAllBookings() async {
    final currentUser = AuthService().getCurrentUser();
    final userId = currentUser?.id ?? 'guest';
    final userRides = await LocalRideRepository().getUserRides(userId);

    final List<Map<String, dynamic>> rideBookings = userRides.map((ride) {
      String cat = 'Cabs';
      if (ride.rideType == RideType.bike) cat = 'Bikes';
      if (ride.rideType == RideType.auto) cat = 'Autos';

      String statusStr = 'Confirmed';
      if (ride.status == RideStatus.tripCompleted) statusStr = 'Completed';
      if (ride.status == RideStatus.cancelled) statusStr = 'Cancelled';

      return {
        'bookingId': ride.id,
        'title': '${ride.rideType.label} Ride (${ride.pickupName} → ${ride.destinationName})',
        'subTitle': '${ride.driver?.vehicleName ?? ride.rideType.description} • Demo Ride',
        'date': '${ride.createdAt.day} ${_getMonthName(ride.createdAt.month)} ${ride.createdAt.year}',
        'status': statusStr,
        'category': cat,
        'amount': '${ride.estimatedFare.toInt()}',
        'items': '${ride.routeDistanceKm} km • Driver: ${ride.driver?.name ?? 'Assigned Driver'}',
        'monthGroup': '${_getMonthName(ride.createdAt.month)} ${ride.createdAt.year}',
      };
    }).toList();

    setState(() {
      _allBookings = [...rideBookings, ..._mockBookings];
    });
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredList(String tabType) {
    return _allBookings.where((booking) {
      final status = booking['status'].toString();

      // Tab Filter
      if (tabType == 'Upcoming' && status != 'Confirmed') return false;
      if (tabType == 'Past' && status != 'Completed') return false;
      if (tabType == 'Cancelled' && status != 'Cancelled') return false;

      // Category Filter
      if (_selectedCategory != 'All' && booking['category'] != _selectedCategory) {
        return false;
      }

      // Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final idMatch = booking['bookingId'].toString().toLowerCase().contains(query);
        final titleMatch = booking['title'].toString().toLowerCase().contains(query);
        return idMatch || titleMatch;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('My Travel Bookings'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: PersistentProfileWidget(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.vanRed,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Booking ID or Destination...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim());
                  },
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList('Upcoming'),
                _buildBookingList('Past'),
                _buildBookingList('Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(String tabType) {
    final filtered = _getFilteredList(tabType);

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tabType == 'Upcoming'
                    ? Icons.flight_takeoff
                    : tabType == 'Past'
                        ? Icons.history
                        : Icons.cancel_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                tabType == 'Upcoming'
                    ? '🎉 No upcoming trips! Time to plan your next adventure.'
                    : tabType == 'Past'
                        ? 'You haven\'t completed any trips yet.'
                        : 'No cancelled bookings.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 20),
              if (tabType == 'Upcoming')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vanRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LocationSearchScreen()),
                    );
                  },
                  child: const Text('Search Destinations'),
                ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final booking = filtered[index];
        final status = booking['status'];
        final isCancelled = status == 'Cancelled';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingDetailScreen(booking: booking)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getIconForCategory(booking['category']),
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            booking['bookingId'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCancelled
                              ? Colors.red.shade50
                              : status == 'Confirmed'
                                  ? Colors.green.shade50
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCancelled
                                ? Colors.red
                                : status == 'Confirmed'
                                    ? Colors.green
                                    : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking['subTitle'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📅 ${booking['date']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('₹${booking['amount']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
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

  IconData _getIconForCategory(String cat) {
    switch (cat) {
      case 'Trains':
        return Icons.train;
      case 'Buses':
        return Icons.directions_bus;
      case 'Flights':
        return Icons.flight;
      case 'Bikes':
        return Icons.two_wheeler;
      case 'Autos':
        return Icons.electric_rickshaw;
      case 'Cabs':
        return Icons.local_taxi;
      default:
        return Icons.hotel;
    }
  }
}
