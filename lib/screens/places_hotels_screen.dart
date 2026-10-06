import 'package:flutter/material.dart';
import '../core/widgets/custom_image_widget.dart';
import '../features/date_time_selection/hotel_date_range_picker.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../features/filters_sorting/filter_model.dart';
import '../features/filters_sorting/filter_repository.dart';
import '../models/travel_data.dart';
import '../repositories/hotel_repository.dart';
import '../repositories/places_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import '../widgets/persistent_profile_widget.dart';
import '../widgets/results_filter_header.dart';
import '../widgets/tourist_guide_sheet.dart';
import 'hotel_detail_screen.dart';
import 'hotel_room_selection_screen.dart';
import 'place_detail_screen.dart';

class PlacesHotelsScreen extends StatefulWidget {
  final String location;
  final TravelSearchModel? searchModel;

  const PlacesHotelsScreen({
    super.key,
    this.location = 'Tirupati',
    this.searchModel,
  });

  @override
  State<PlacesHotelsScreen> createState() => _PlacesHotelsScreenState();
}

class _PlacesHotelsScreenState extends State<PlacesHotelsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  final PlacesRepository _placesRepository = MockPlacesRepository();
  final HotelRepository _hotelRepository = MockHotelRepository();

  late Future<List<PlaceItem>> _placesFuture;
  late Future<List<HotelItem>> _hotelsFuture;

  FilterModel _activeFilter = const FilterModel();

  // Check-in & Check-out dates strictly derived from searchModel
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController(text: widget.location);

    if (widget.searchModel != null) {
      _checkInDate = widget.searchModel!.hotelCheckIn;
      _checkOutDate = widget.searchModel!.hotelCheckOut;
    }

    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _placesFuture = _placesRepository.getPlacesByDestination(_searchController.text).then((places) {
        return FilterRepository.applyPlaceFilters(places, _activeFilter);
      });
      _hotelsFuture = _hotelRepository.getHotelsByDestination(_searchController.text).then((hotels) {
        return FilterRepository.applyHotelFilters(hotels, _activeFilter);
      });
    });
  }

  int? get _hotelNights {
    if (_checkInDate == null || _checkOutDate == null) return null;
    final inD = TravelSearchModel.dateOnly(_checkInDate!);
    final outD = TravelSearchModel.dateOnly(_checkOutDate!);
    final diff = outD.difference(inD).inDays;
    return diff > 0 ? diff : null;
  }

  TravelSearchModel _getUpdatedSearchModel() {
    final base = widget.searchModel ?? TravelSearchModel(
      fromLocation: 'Narasaraopet',
      toLocation: _searchController.text,
      searchType: 'hotel',
    );
    return base.copyWith(
      toLocation: _searchController.text,
      hotelCheckIn: _checkInDate,
      hotelCheckOut: _checkOutDate,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Header Bar
                Container(
                  color: AppColors.primaryBlue,
                  padding: const EdgeInsets.only(left: 8, right: 12, top: 8, bottom: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textDark,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter destination...',
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (val) => _fetchData(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.search, color: AppColors.textDark, size: 22),
                                onPressed: _fetchData,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const PersistentProfileWidget(),
                    ],
                  ),
                ),

                // Places / Hotels Tab Bar Switcher
                Container(
                  color: const Color(0xFFD6D6E8),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primaryBlue,
                    indicatorWeight: 3,
                    labelColor: AppColors.textDark,
                    unselectedLabelColor: Colors.black54,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: 'Places'),
                      Tab(text: 'Hotels'),
                    ],
                  ),
                ),

                // Tab Content View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPlacesView(),
                      _buildHotelsView(),
                    ],
                  ),
                ),
              ],
            ),

            // Floating Tourist Guide Button
            Positioned(
              right: 16,
              bottom: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    TouristGuideSheet.show(context);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5CC0C6),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Contact a\ntourist guide',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.phone_in_talk_outlined,
                          color: Colors.black87,
                          size: 20,
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
    );
  }

  Widget _buildPlacesView() {
    return FutureBuilder<List<PlaceItem>>(
      future: _placesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final places = snapshot.data ?? [];

        return Column(
          children: [
            ResultsFilterHeader(
              title: 'Tourist Attractions in ${_searchController.text}',
              filterModel: _activeFilter,
              resultCount: places.length,
              onFilterChanged: (updated) {
                setState(() {
                  _activeFilter = updated;
                });
                _fetchData();
              },
            ),

            Expanded(
              child: places.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.filter_alt_off, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text('No results match your filters.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.vanRed),
                              onPressed: () {
                                setState(() {
                                  _activeFilter = const FilterModel();
                                });
                                _fetchData();
                              },
                              child: const Text('Clear Filters', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: places.length,
                      itemBuilder: (context, index) => _buildPlaceCard(places[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHotelsView() {
    return FutureBuilder<List<HotelItem>>(
      future: _hotelsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final hotels = snapshot.data ?? [];

        final String dateSummary = _checkInDate != null && _checkOutDate != null
            ? TravelSearchModel.formatDateRange(_checkInDate, _checkOutDate)
            : 'Select check-in & check-out dates to view total cost';

        return Column(
          children: [
            ResultsFilterHeader(
              title: 'Hotels in ${_searchController.text}',
              dateSummary: dateSummary,
              filterModel: _activeFilter,
              resultCount: hotels.length,
              onFilterChanged: (updated) {
                setState(() {
                  _activeFilter = updated;
                });
                _fetchData();
              },
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // Hotel Check-in / Check-out Date Picker Card
                  HotelDateRangePicker(
                    checkInDate: _checkInDate,
                    checkOutDate: _checkOutDate,
                    onDateRangeSelected: (range) {
                      setState(() {
                        _checkInDate = range.start;
                        _checkOutDate = range.end;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  if (hotels.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.filter_alt_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('No results match your filters.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.vanRed),
                            onPressed: () {
                              setState(() {
                                _activeFilter = const FilterModel();
                              });
                              _fetchData();
                            },
                            child: const Text('Clear Filters', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  else
                    ...hotels.map((hotel) => _buildHotelCard(hotel)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceCard(PlaceItem place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.grey.shade300, width: 0.8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlaceDetailScreen(place: place)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImageWidget(
                imageUrl: place.imageUrl,
                width: 110,
                height: 85,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.distance,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${place.rating} ',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        StarRatingWidget(rating: place.rating, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '(${place.reviewCount})',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotelCard(HotelItem hotel) {
    final digits = hotel.price.replaceAll(RegExp(r'[^0-9.]'), '');
    final double nightlyPrice = double.tryParse(digits) ?? 2400.0;
    final nights = _hotelNights;
    final double totalHotelCost = nights != null ? nightlyPrice * nights : nightlyPrice;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.grey.shade300, width: 0.8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailScreen(
                hotel: hotel,
                searchModel: _getUpdatedSearchModel(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImageWidget(
                    imageUrl: hotel.imageUrl,
                    width: 110,
                    height: 85,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hotel.distance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StarRatingWidget(rating: hotel.rating, size: 16),
                        const SizedBox(height: 6),

                        // Pricing calculation display
                        if (nights != null)
                          Text(
                            '₹${nightlyPrice.toInt()} × $nights ${nights == 1 ? 'night' : 'nights'} = ₹${totalHotelCost.toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          )
                        else
                          Text(
                            '₹${nightlyPrice.toInt()} / night',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelDetailScreen(
                            hotel: hotel,
                            searchModel: _getUpdatedSearchModel(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Hotel Details', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelRoomSelectionScreen(
                            hotel: hotel,
                            searchModel: _getUpdatedSearchModel(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Book Room', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
