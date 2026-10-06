import 'package:flutter/material.dart';
import '../../core/widgets/custom_image_widget.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_illustrations.dart';
import 'review_model.dart';

class ReviewCard extends StatefulWidget {
  final Review review;
  final VoidCallback? onHelpfulPressed;

  const ReviewCard({
    super.key,
    required this.review,
    this.onHelpfulPressed,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _isExpanded = false;
  bool _hasLiked = false;

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                          ),
                          if (review.isVerifiedGuest) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.verified, size: 10, color: Colors.green.shade700),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Verified Guest',
                                    style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatDate(review.timestamp),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                StarRatingWidget(rating: review.rating, size: 16),
              ],
            ),

            const SizedBox(height: 10),

            // Category Tags
            if (review.categoryTags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: review.categoryTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // Title & Review Text
            if (review.reviewTitle.isNotEmpty)
              Text(
                review.reviewTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
              ),
            const SizedBox(height: 4),

            Text(
              review.reviewText,
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
            ),

            if (review.reviewText.length > 120) ...[
              GestureDetector(
                onTap: () {
                  setState(() => _isExpanded = !_isExpanded);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _isExpanded ? 'Show less' : 'Read more',
                    style: const TextStyle(color: AppColors.vanRed, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],

            // Photos Gallery
            if (review.photos.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CustomImageWidget(
                        imageUrl: review.photos[index],
                        width: 90,
                        height: 70,
                        borderRadius: BorderRadius.circular(8),
                        enableFullscreenOnClick: true,
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Helpful Count
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                onPressed: () {
                  setState(() {
                    if (!_hasLiked) {
                      review.helpfulCount++;
                      _hasLiked = true;
                    }
                  });
                  if (widget.onHelpfulPressed != null) widget.onHelpfulPressed!();
                },
                icon: Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 14,
                  color: _hasLiked ? AppColors.vanRed : Colors.grey,
                ),
                label: Text(
                  'Helpful (${review.helpfulCount})',
                  style: TextStyle(
                    fontSize: 12,
                    color: _hasLiked ? AppColors.vanRed : Colors.grey.shade700,
                    fontWeight: _hasLiked ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
