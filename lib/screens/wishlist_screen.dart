import 'package:flutter/material.dart';
import '../core/widgets/custom_image_widget.dart';
import '../models/wishlist_item_model.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar_with_profile.dart';
import '../widgets/travel_time_navigation_drawer.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WishlistProvider _wishlistProvider = WishlistProvider();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _wishlistProvider.fetchWishlist().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _wishlistProvider.items;

    final placeItems = items.where((i) => i.itemType == WishlistItemType.place).toList();
    final hotelItems = items.where((i) => i.itemType == WishlistItemType.hotel).toList();
    final transportItems = items.where((i) => i.itemType == WishlistItemType.transportRoute).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      drawer: const TravelTimeNavigationDrawer(currentRoute: 'wishlist'),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: Column(
          children: [
            const AppBarWithProfile(
              title: 'Wishlist & Saved Items',
            ),
            Container(
              color: const Color(0xFFD6D6E8),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 3,
                labelColor: AppColors.textDark,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'Places'),
                  Tab(text: 'Hotels'),
                  Tab(text: 'Routes'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWishlistListView(placeItems, 'No saved places yet.'),
          _buildWishlistListView(hotelItems, 'No saved hotels yet.'),
          _buildWishlistListView(transportItems, 'No saved transport routes yet.'),
        ],
      ),
    );
  }

  Widget _buildWishlistListView(List<WishlistItemModel> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Save places, hotels, and travel routes to view them anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CustomImageWidget(
                  imageUrl: item.imageUrl,
                  width: 90,
                  height: 75,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.priceOrFareSummary,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: AppColors.vanRed),
                  onPressed: () async {
                    await _wishlistProvider.toggleWishlist(item);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
