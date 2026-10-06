import 'package:flutter/material.dart';
import '../features/date_time_selection/date_time_selector_widget.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/search_history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import '../widgets/persistent_profile_widget.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';
import 'places_hotels_screen.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  String _fromLocation = 'Detecting your location...';
  bool _isDetectingLocation = true;
  LocationPermissionState _permissionState = LocationPermissionState.granted;

  final TextEditingController _toController = TextEditingController();
  final FocusNode _toFocusNode = FocusNode();

  DateTime _selectedDepartureDate = DateTime.now().add(const Duration(days: 1));

  int _adultsCount = 1;
  int _childrenCount = 0;
  int _infantsCount = 0;
  int _roomsCount = 1;

  List<String> _suggestions = [];
  bool _showSuggestions = false;
  bool _isSearching = false;
  String? _errorMessage;

  List<SearchHistoryItem> _searchHistory = [];

  // Popular search database for autocomplete
  final List<String> _popularDestinations = [

    'Narasaraopet, Andhra Pradesh',
    'Narasaraopet Railway Station',
    'Guntur, Andhra Pradesh',
    'Vijayawada, Andhra Pradesh',
    'Tirupati, Andhra Pradesh',
    'Tirumala Temple, Tirupati',
    'Tirupati Airport (TIR)',
    'Tirupati Central Railway Station',
    'Goa (Beach Destination)',
    'Bengaluru, Karnataka',
    'Chennai, Tamil Nadu',
    'Hyderabad, Telangana',
    'Rajiv Gandhi International Airport, Hyderabad',
    'Secunderabad Junction Railway Station',
    'Visakhapatnam, Andhra Pradesh',
    'Kochi, Kerala',
    'Munnar, Kerala',
    'Ooty, Tamil Nadu',
    'Jaipur, Rajasthan',
    'Mumbai, Maharashtra',
    'Delhi NCR',
  ];

  @override
  void initState() {
    super.initState();
    _detectUserLocation();
    _loadSearchHistory();
    _toController.addListener(_onToTextChanged);
  }

  Future<void> _detectUserLocation() async {
    setState(() {
      _isDetectingLocation = true;
      _fromLocation = 'Detecting your location...';
      _errorMessage = null;
    });

    final result = await LocationService().getCurrentLocation();

    if (!mounted) return;

    setState(() {
      _isDetectingLocation = false;
      _fromLocation = result.locationName;
      _permissionState = result.state;
      if (result.errorMessage != null && result.state != LocationPermissionState.granted) {
        _errorMessage = result.errorMessage;
      }
    });
  }

  Future<void> _loadSearchHistory() async {
    final activeUser = AuthService().getActiveUserIdentifier() ?? 'guest';
    final history = await SearchHistoryService().getHistory(activeUser);
    if (!mounted) return;
    setState(() {
      _searchHistory = history;
    });
  }

  void _onToTextChanged() {
    final query = _toController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final matches = _popularDestinations
        .where((dest) => dest.toLowerCase().contains(query))
        .toList();

    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty;
    });
  }

  void _selectDestination(String destination) {
    setState(() {
      _toController.text = destination;
      _showSuggestions = false;
      _errorMessage = null;
    });
    _toFocusNode.unfocus();
  }

  void _handleManualFromLocation() {
    final controller = TextEditingController(text: _fromLocation.startsWith('📍') ? _fromLocation.replaceFirst('📍 ', '') : _fromLocation);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enter Starting Location', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Banjara Hills, Hyderabad',
              prefixIcon: Icon(Icons.my_location, color: AppColors.vanRed),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3240),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _fromLocation = controller.text.trim();
                    _errorMessage = null;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Set Location', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSearch() async {
    setState(() {
      _errorMessage = null;
    });

    final cleanFrom = _fromLocation.replaceFirst('📍 ', '').trim();
    final cleanTo = _toController.text.trim();

    if (cleanFrom.isEmpty || _isDetectingLocation) {
      setState(() {
        _errorMessage = 'Please specify a valid starting location.';
      });
      return;
    }

    if (cleanTo.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a destination.';
      });
      return;
    }

    // Validate From and To are not the same
    if (cleanFrom.toLowerCase() == cleanTo.toLowerCase()) {
      setState(() {
        _errorMessage = 'From and To locations cannot be the same.';
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Save search to user's search history
    final activeUser = AuthService().getActiveUserIdentifier() ?? 'guest';
    await SearchHistoryService().addSearch(
      userIdentifier: activeUser,
      fromLocation: cleanFrom,
      toLocation: cleanTo,
    );

    await _loadSearchHistory();

    setState(() {
      _isSearching = false;
    });

    if (!mounted) return;

    final searchModel = TravelSearchModel(
      fromLocation: cleanFrom,
      toLocation: cleanTo,
      departureDate: _selectedDepartureDate,
      searchType: 'general',
      adultsCount: _adultsCount,
      childrenCount: _childrenCount,
      infantsCount: _infantsCount,
      roomsCount: _roomsCount,
    );

    // Navigate to HomeScreen displaying Bookings and Places options for entered destination
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          fromLocation: cleanFrom,
          toLocation: cleanTo,
          searchModel: searchModel,
        ),
      ),
    );
  }

  void _selectHistoryItem(SearchHistoryItem item) {
    setState(() {
      _fromLocation = item.fromLocation;
      _toController.text = item.toLocation;
      _errorMessage = null;
    });
  }

  void _deleteHistoryItem(String itemId) async {
    final activeUser = AuthService().getActiveUserIdentifier() ?? 'guest';
    await SearchHistoryService().deleteItem(activeUser, itemId);
    _loadSearchHistory();
  }

  void _clearAllHistory() async {
    final activeUser = AuthService().getActiveUserIdentifier() ?? 'guest';
    await SearchHistoryService().clearHistory(activeUser);
    _loadSearchHistory();
  }

  Widget _buildCounterRow(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: () => onChanged(value - 1),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                  color: Colors.white,
                ),
                child: const Icon(Icons.remove, size: 18, color: AppColors.textDark),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            InkWell(
              onTap: () => onChanged(value + 1),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBlue),
                  color: AppColors.primaryBlue,
                ),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _toController.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: RetroVanPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.vanRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.explore, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'TRAVEL TIME',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const PersistentProfileWidget(),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Center(
                      child: Container(
                        width: size.width > 450 ? 420 : size.width * 0.92,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFDE5D53),
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Screen Title
                            const Text(
                              'Where do you want to go?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // FROM FIELD SECTION
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'FROM',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _detectUserLocation,
                                      child: const Text(
                                        '📍 Use Current Location',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: _handleManualFromLocation,
                                      child: const Text(
                                        'Change',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.vanRed,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  if (_isDetectingLocation)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vanRed),
                                    )
                                  else
                                    const Icon(Icons.my_location, color: AppColors.vanRed, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _fromLocation,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _isDetectingLocation ? Colors.black54 : AppColors.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Permission / Location Service Alert Box if needed
                            if (_permissionState != LocationPermissionState.granted) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.amber.shade400),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _errorMessage ?? 'Location permission required',
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        if (_permissionState == LocationPermissionState.serviceDisabled)
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.amber.shade700,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            ),
                                            onPressed: () => LocationService().openLocationSettings(),
                                            child: const Text('Turn On Location', style: TextStyle(fontSize: 12, color: Colors.white)),
                                          )
                                        else
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.amber.shade700,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            ),
                                            onPressed: _detectUserLocation,
                                            child: const Text('Allow Location', style: TextStyle(fontSize: 12, color: Colors.white)),
                                          ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: _handleManualFromLocation,
                                          child: const Text('Enter Manually', style: TextStyle(fontSize: 12, color: Colors.black87)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 18),

                            // TO FIELD SECTION
                            const Text(
                              'TO',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12, width: 1.5),
                              ),
                              child: TextField(
                                controller: _toController,
                                focusNode: _toFocusNode,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: InputBorder.none,
                                  hintText: 'Enter destination (e.g. Tirupati)',
                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                                  prefixIcon: Icon(Icons.search, color: AppColors.vanRed, size: 22),
                                ),
                              ),
                            ),

                            // Autocomplete Suggestions Dropdown
                            if (_showSuggestions) ...[
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                constraints: const BoxConstraints(maxHeight: 180),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _suggestions.length,
                                  itemBuilder: (context, index) {
                                    final item = _suggestions[index];
                                    return ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.location_on, color: AppColors.vanRed, size: 18),
                                      title: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                      onTap: () => _selectDestination(item),
                                    );
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 18),

                            // DEPARTURE DATE SECTION
                            const Text(
                              'DEPARTURE DATE',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DateTimeSelectorWidget(
                              initialDate: _selectedDepartureDate,
                              onDateSelected: (dt) {
                                setState(() {
                                  _selectedDepartureDate = dt;
                                });
                              },
                            ),

                            const SizedBox(height: 18),

                            // TRAVELLERS & ROOMS SECTION
                            const Text(
                              'TRAVELLERS & ROOMS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12, width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  _buildCounterRow('Adults (12+ yrs)', _adultsCount, (val) => setState(() => _adultsCount = val.clamp(1, 10))),
                                  const Divider(height: 16),
                                  _buildCounterRow('Children (2-11 yrs)', _childrenCount, (val) => setState(() => _childrenCount = val.clamp(0, 6))),
                                  const Divider(height: 16),
                                  _buildCounterRow('Infants (0-2 yrs)', _infantsCount, (val) => setState(() => _infantsCount = val.clamp(0, 2))),
                                  const Divider(height: 16),
                                  _buildCounterRow('Rooms', _roomsCount, (val) => setState(() => _roomsCount = val.clamp(1, 5))),
                                ],
                              ),
                            ),

                            // Red Error Display
                            if (_errorMessage != null && _permissionState == LocationPermissionState.granted) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade300),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 22),

                            // SEARCH BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSearching ? null : _handleSearch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C3240),
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: _isSearching
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : const Text(
                                        'SEARCH',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            const Divider(height: 1),
                            const SizedBox(height: 16),

                            // PREVIOUS SEARCHES SECTION
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Previous Searches',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (_searchHistory.isNotEmpty)
                                  GestureDetector(
                                    onTap: _clearAllHistory,
                                    child: const Text(
                                      'Clear History',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (_searchHistory.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    'No previous searches yet.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black45,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _searchHistory.length,
                                itemBuilder: (context, index) {
                                  final item = _searchHistory[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9F9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.history, color: AppColors.vanRed, size: 20),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.fromLocation} → ${item.toLocation}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textDark,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                        onPressed: () => _deleteHistoryItem(item.id),
                                      ),
                                      onTap: () => _selectHistoryItem(item),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
