import 'package:flutter/material.dart';
import '../features/date_time_selection/travel_search_model.dart';
import '../models/travel_data.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import 'hotel_room_selection_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  final HotelItem hotel;
  final TravelSearchModel? searchModel;

  const HotelDetailScreen({
    super.key,
    required this.hotel,
    this.searchModel,
  });

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  int _activeImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final allImages = widget.hotel.roomCategories.isNotEmpty
        ? widget.hotel.roomCategories.expand((cat) => cat.roomPhotos).toList()
        : [widget.hotel.imageUrl];

    final nights = widget.searchModel?.hotelNights;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(widget.hotel.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Room Pictures Gallery Carousel
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 240,
                  child: PageView.builder(
                    itemCount: allImages.length,
                    onPageChanged: (index) {
                      setState(() => _activeImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        allImages[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.amber.shade100,
                          child: const Icon(Icons.hotel, size: 80, color: Colors.amber),
                        ),
                      );
                    },
                  ),
                ),

                // Carousel Page Indicator Dots
                Positioned(
                  bottom: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(allImages.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _activeImageIndex == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _activeImageIndex == index ? Colors.white : Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

                // Price Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Text(
                      nights != null
                          ? '${widget.hotel.price} / night'
                          : widget.hotel.price,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Rating Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.hotel.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${widget.hotel.distance} from city center', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              const Spacer(),
                              StarRatingWidget(rating: widget.hotel.rating, size: 16),
                              const SizedBox(width: 4),
                              Text('${widget.hotel.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          if (widget.searchModel?.hotelCheckIn != null && widget.searchModel?.hotelCheckOut != null) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryBlue),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    TravelSearchModel.formatDateRange(
                                      widget.searchModel!.hotelCheckIn,
                                      widget.searchModel!.hotelCheckOut,
                                    ),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Room Categories
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Available Room Types & Facilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          ...widget.hotel.roomCategories.map((cat) {
                            return Column(
                              children: [
                                _buildRoomTypeTile(
                                  cat.categoryName,
                                  cat.price,
                                  cat.bedInfo,
                                  cat.roomPhotos.isNotEmpty ? cat.roomPhotos[0] : widget.hotel.imageUrl,
                                  cat.roomAmenities,
                                ),
                                const Divider(height: 20),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Book Room Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotelRoomSelectionScreen(
                              hotel: widget.hotel,
                              searchModel: widget.searchModel,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Select Room & Book Now',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTypeTile(String name, String price, String sub, String imgUrl, List<String> amenities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imgUrl,
                width: 90,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 70,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.king_bed),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: amenities.map((a) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(a, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
