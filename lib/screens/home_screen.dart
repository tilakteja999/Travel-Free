import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import '../widgets/persistent_profile_widget.dart';
import '../widgets/travel_time_navigation_drawer.dart';
import 'bookings_screen.dart';
import 'places_hotels_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? fromLocation;
  final String? toLocation;
  final TravelSearchModel? searchModel;

  const HomeScreen({
    super.key,
    this.fromLocation,
    this.toLocation,
    this.searchModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final initialDest = widget.toLocation ?? widget.searchModel?.toLocation ?? 'Tirupati';
    _locationController = TextEditingController(text: initialDest);
  }

  void _onSearchSubmitted() {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination.')),
      );
      return;
    }
    _navigateToPlaces();
  }

  void _navigateToPlaces() {
    final location = _locationController.text.trim();
    if (location.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlacesHotelsScreen(
            location: location,
            searchModel: widget.searchModel,
          ),
        ),
      );
    }
  }

  void _navigateToTransport() {
    final location = _locationController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingsScreen(
          location: location.isNotEmpty ? location : 'Tirupati',
          fromLocation: widget.fromLocation,
          searchModel: widget.searchModel,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      drawer: const TravelTimeNavigationDrawer(currentRoute: 'search'),
      body: Stack(
        children: [
          // Background Painter (Retro Travel Van, Sun, Sunset, Palms)
          Positioned.fill(
            child: CustomPaint(
              painter: RetroVanPainter(),
            ),
          ),

          // Central Retro Van Vector Stack
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width > 420 ? 400 : size.width * 0.92,
              height: size.height * 0.78,
              margin: const EdgeInsets.only(bottom: 20),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Main Outer Teal Van Body
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: size.width > 420 ? 360 : size.width * 0.86,
                      height: size.height * 0.52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2EA5B0),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(55),
                          topRight: Radius.circular(55),
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Central Panel containing BOTH Bookings & Places Buttons
                          Container(
                            width: 290,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF2E1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.black26, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // License Plate "Travel time"
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBE4C5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black26, width: 1.5),
                                  ),
                                  child: const Text(
                                    '• Travel time •',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                      fontFamily: 'serif',
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // 1. BOOKINGS BUTTON (Trains, Buses, Flights)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _navigateToTransport,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(Icons.confirmation_number, size: 20),
                                    label: const Text(
                                      'Bookings',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // 2. PLACES BUTTON (Attractions & Hotels)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF33C19C),
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: _navigateToPlaces,
                                    icon: const Icon(Icons.account_balance, size: 20),
                                    label: const Text(
                                      'Places',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Wheels
                  Positioned(
                    bottom: 0,
                    left: 20,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF222222),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 20,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF222222),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Header Bar with Search TextField & Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.textDark, size: 22),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                        decoration: const InputDecoration(
                          hintText: 'Enter destination...',
                          hintStyle: TextStyle(color: Colors.black45, fontSize: 15),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) => _onSearchSubmitted(),
                      ),
                    ),
                    const PersistentProfileWidget(),
                    IconButton(
                      icon: const Icon(Icons.search, color: AppColors.textDark),
                      onPressed: _onSearchSubmitted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
