import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../models/travel_data.dart';
import '../services/local_availability_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import 'passenger_details_screen.dart';

class HotelRoomSelectionScreen extends StatefulWidget {
  final HotelItem hotel;
  final TravelSearchModel? searchModel;

  const HotelRoomSelectionScreen({
    super.key,
    required this.hotel,
    this.searchModel,
  });

  @override
  State<HotelRoomSelectionScreen> createState() => _HotelRoomSelectionScreenState();
}

class _HotelRoomSelectionScreenState extends State<HotelRoomSelectionScreen> {
  int _selectedCategoryIndex = 0;
  int _activePhotoIndex = 0;

  final Set<String> _bookedRooms = {'Room 102 (Occupied)', 'Room 105 (Occupied)'};
  final Set<String> _selectedRooms = {'Room 101'};

  bool _isLoadingAvailability = true;

  @override
  void initState() {
    super.initState();
    _loadRoomAvailability();
  }

  Future<void> _loadRoomAvailability() async {
    setState(() => _isLoadingAvailability = true);
    final checkInStr = widget.searchModel?.formattedCheckIn ?? '2026-10-29';
    final booked = await LocalAvailabilityService().getBookedRooms(widget.hotel.title, checkInStr);
    if (!mounted) return;

    setState(() {
      _bookedRooms.addAll(booked);
      _isLoadingAvailability = false;
    });
  }

  RoomCategory get _currentCategory {
    if (widget.hotel.roomCategories.isNotEmpty) {
      return widget.hotel.roomCategories[_selectedCategoryIndex.clamp(0, widget.hotel.roomCategories.length - 1)];
    }
    return const RoomCategory(
      categoryName: 'Standard Room',
      price: '₹2,400 / night',
      numericPrice: 2400.0,
      bedInfo: 'Double Bed',
      roomPhotos: ['https://images.weserv.nl/?url=https://images.unsplash.com/photo-1618773928121-c32242e63f39'],
      roomAmenities: ['24/7 Hot Water & Geyser', 'Free Wi-Fi', 'A/C', 'Room Service'],
    );
  }

  void _toggleRoom(String roomCode) {
    if (_bookedRooms.contains(roomCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$roomCode is already occupied by another guest.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      if (_selectedRooms.contains(roomCode)) {
        _selectedRooms.remove(roomCode);
      } else {
        _selectedRooms.add(roomCode);
      }
    });
  }

  void _proceedToGuestDetails() {
    if (_selectedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one room number.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final adults = widget.searchModel?.adultsCount ?? 1;
    final requiredRooms = (adults / 2.0).ceil();
    if (_selectedRooms.length < requiredRooms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Occupancy rule: Max 2 adults per room. Please select at least $requiredRooms room(s) for $adults adults.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final sorted = _selectedRooms.toList()..sort();
    final nights = widget.searchModel?.hotelNights ?? 1;
    final totalPrice = sorted.length * _currentCategory.numericPrice * nights;

    String dateSub = widget.searchModel?.hotelCheckIn != null && widget.searchModel?.hotelCheckOut != null
        ? ' • ${TravelSearchModel.formatShortDate(widget.searchModel!.hotelCheckIn!)} - ${TravelSearchModel.formatShortDate(widget.searchModel!.hotelCheckOut!)} ($nights ${nights == 1 ? "Night" : "Nights"})'
        : '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerDetailsScreen(
          bookingTitle: widget.hotel.title,
          bookingType: 'Hotel',
          subTitle: '${_currentCategory.categoryName}$dateSub',
          selectedItems: sorted.map((r) => '$r (${_currentCategory.categoryName})').toList(),
          totalPrice: totalPrice,
          searchModel: widget.searchModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _selectedRooms.toList()..sort();
    final nights = widget.searchModel?.hotelNights ?? 1;
    final totalPrice = sorted.length * _currentCategory.numericPrice * nights;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(widget.hotel.title),
      ),
      body: _isLoadingAvailability
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hotel Banner
                        Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Image.network(
                              widget.hotel.imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Colors.amber.shade100,
                                child: const Icon(Icons.hotel, size: 80, color: Colors.amber),
                              ),
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.hotel.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.hotel.distance} • Near city center',
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                      const SizedBox(width: 12),
                                      StarRatingWidget(rating: widget.hotel.rating, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Room Type Chips
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Room Type:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(widget.hotel.roomCategories.length, (index) {
                                    final cat = widget.hotel.roomCategories[index];
                                    final isSelected = index == _selectedCategoryIndex;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text('${cat.categoryName} (${cat.price})'),
                                        selected: isSelected,
                                        selectedColor: AppColors.primaryBlue,
                                        backgroundColor: Colors.white,
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : AppColors.textDark,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300),
                                        ),
                                        onSelected: (val) {
                                          if (val) {
                                            setState(() {
                                              _selectedCategoryIndex = index;
                                              _activePhotoIndex = 0;
                                            });
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Category Details Gallery & Amenities
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _currentCategory.categoryName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primaryBlue),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _currentCategory.price,
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentCategory.bedInfo,
                                    style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),

                                  // Room Photos
                                  Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: SizedBox(
                                          height: 200,
                                          child: PageView.builder(
                                            itemCount: _currentCategory.roomPhotos.length,
                                            onPageChanged: (idx) {
                                              setState(() => _activePhotoIndex = idx);
                                            },
                                            itemBuilder: (context, idx) {
                                              return Image.network(
                                                _currentCategory.roomPhotos[idx],
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(Icons.king_bed, size: 60, color: Colors.grey),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        bottom: 10,
                                        child: Row(
                                          children: List.generate(_currentCategory.roomPhotos.length, (idx) {
                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 3),
                                              width: _activePhotoIndex == idx ? 10 : 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: _activePhotoIndex == idx ? Colors.white : Colors.white60,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  const Text(
                                    'Room Amenities & Facilities Present:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _currentCategory.roomAmenities.map((amenity) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(_getAmenityIcon(amenity), size: 16, color: AppColors.primaryBlue),
                                            const SizedBox(width: 6),
                                            Text(
                                              amenity,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Room Number Selector
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Select Room Number:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: ['Room 101', 'Room 102 (Occupied)', 'Room 103', 'Room 104', 'Room 105 (Occupied)', 'Room 106'].map((roomCode) {
                                      final isOccupied = _bookedRooms.contains(roomCode);
                                      final isSelected = _selectedRooms.contains(roomCode);

                                      Color bg;
                                      if (isSelected) {
                                        bg = const Color(0xFF26C6DA);
                                      } else if (isOccupied) {
                                        bg = const Color(0xFF1E88E5);
                                      } else {
                                        bg = const Color(0xFF7CB342);
                                      }

                                      return InkWell(
                                        onTap: () => _toggleRoom(roomCode),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: bg,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            roomCode,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -3)),
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
                              sorted.isEmpty ? 'No room selected' : 'Selected: ${sorted.join(", ")}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              nights > 1
                                  ? '₹${totalPrice.toStringAsFixed(0)} ($nights Nights)'
                                  : '₹${totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
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
                        onPressed: _proceedToGuestDetails,
                        child: const Text('Book Room', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  IconData _getAmenityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('hot water') || lower.contains('geyser')) return Icons.hot_tub;
    if (lower.contains('wi-fi') || lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('a/c') || lower.contains('air conditioning')) return Icons.ac_unit;
    if (lower.contains('room service') || lower.contains('dining')) return Icons.room_service;
    if (lower.contains('tv')) return Icons.tv;
    if (lower.contains('breakfast')) return Icons.free_breakfast;
    return Icons.check_circle_outline;
  }
}
