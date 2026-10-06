import 'package:flutter/material.dart';
import '../core/widgets/custom_image_widget.dart';
import '../features/reviews_ratings/review_card.dart';
import '../features/reviews_ratings/review_model.dart';
import '../features/reviews_ratings/review_repository.dart';
import '../features/reviews_ratings/write_review_screen.dart';
import '../models/travel_data.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_illustrations.dart';
import '../widgets/tourist_guide_sheet.dart';

class PlaceDetailScreen extends StatefulWidget {
  final PlaceItem place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  int _selectedImageIndex = 0;
  late Future<List<Review>> _reviewsFuture;
  final ReviewRepository _reviewRepository = MockReviewRepository();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _reviewsFuture = _reviewRepository.getReviewsForPlace(widget.place.title);
    });
  }
  @override
  Widget build(BuildContext context) {
    final images = widget.place.placeImages.isNotEmpty
        ? widget.place.placeImages
        : [widget.place.imageUrl];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          // App Bar with Main Active Image Preview of this Place
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            leading: CircleAvatar(
              backgroundColor: Colors.black38,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Main Active Image Preview via CustomImageWidget
                  CustomImageWidget(
                    imageUrl: images[_selectedImageIndex],
                    fit: BoxFit.cover,
                    enableFullscreenOnClick: true,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),

                  // Overlay Category & Title
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.place.category,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.place.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Gallery Strip of this Place
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.photo_library_outlined, size: 20, color: AppColors.primaryBlue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Photos of this Place:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                                  ),
                                ],
                              ),
                              Text(
                                '${_selectedImageIndex + 1} / ${images.length}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 85,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                final isSelected = index == _selectedImageIndex;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedImageIndex = index);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                                        width: isSelected ? 3 : 1,
                                      ),
                                    ),
                                    child: CustomImageWidget(
                                      imageUrl: images[index],
                                      width: 110,
                                      height: 85,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap any thumbnail above to view it in full resolution.',
                            style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Distance & Rating Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.vanRed, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.place.distance} away',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              StarRatingWidget(rating: widget.place.rating, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.place.rating} (${widget.place.reviewCount})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Open & Close Timings Card
                  Card(
                    elevation: 2,
                    color: const Color(0xFFFFF8E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.amber.shade400, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.access_time_filled, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Open & Close Timings',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.place.openCloseTiming,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.brown.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Information about the Place / Spot
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primaryBlue),
                              SizedBox(width: 8),
                              Text(
                                'Information About This Place',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.place.description,
                            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF424242)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // What We Can Find & See Here
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.visibility, color: AppColors.accentGreen),
                              SizedBox(width: 8),
                              Text(
                                'What You Can Find & See Here',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...widget.place.whatToSee.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reviews & Ratings Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Guest Reviews & Ratings',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.vanRed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WriteReviewScreen(
                                        placeOrHotelId: widget.place.title,
                                        titleName: widget.place.title,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadReviews();
                                  }
                                },
                                icon: const Icon(Icons.edit, size: 14),
                                label: const Text('Write Review', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<List<Review>>(
                            future: _reviewsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final reviews = snapshot.data ?? [];
                              if (reviews.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text('No reviews yet. Be the first to review!', style: TextStyle(color: Colors.grey)),
                                );
                              }
                              return Column(
                                children: reviews.map((rev) => ReviewCard(review: rev)).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Floating Guide Contact Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38C5CD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.support_agent, size: 36, color: Colors.white),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Need a Personal Tourist Guide?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                              Text('Get local temple history & VIP darshan escorts', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            TouristGuideSheet.show(context);
                          },
                          child: const Text('Contact Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
