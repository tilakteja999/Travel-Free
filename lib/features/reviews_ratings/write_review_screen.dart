import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'review_model.dart';
import 'review_repository.dart';

class WriteReviewScreen extends StatefulWidget {
  final String placeOrHotelId;
  final String titleName;

  const WriteReviewScreen({
    super.key,
    required this.placeOrHotelId,
    required this.titleName,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  double _selectedRating = 5.0;
  final Set<String> _selectedCategoryTags = {'Cleanliness', 'Location'};
  final List<String> _attachedPhotos = [];

  final List<String> _availableTags = [
    'Cleanliness',
    'Location',
    'Value for Money',
    'Service',
    'Family Friendly',
    'Accessibility',
  ];

  final ReviewRepository _reviewRepository = MockReviewRepository();
  bool _isSubmitting = false;

  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRating < 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a star rating.'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      final activeUser = AuthService().getActiveUserIdentifier() ?? 'Verified Guest';

      final newReview = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        placeOrHotelId: widget.placeOrHotelId,
        userName: activeUser.contains('@') ? activeUser.split('@').first : activeUser,
        rating: _selectedRating,
        reviewTitle: _titleController.text.trim(),
        reviewText: _textController.text.trim(),
        timestamp: DateTime.now(),
        categoryTags: _selectedCategoryTags.toList(),
        photos: _attachedPhotos,
        isVerifiedGuest: true,
      );

      await _reviewRepository.submitReview(newReview);

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your review has been published.'),
          backgroundColor: AppColors.accentGreen,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Write a Review'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Title Banner
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.rate_review, color: AppColors.vanRed, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.titleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text('Share your real experience with fellow travelers', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Interactive Star Picker Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starVal = index + 1.0;
                          return IconButton(
                            iconSize: 36,
                            icon: Icon(
                              _selectedRating >= starVal ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedRating = starVal;
                              });
                            },
                          );
                        }),
                      ),
                      Text(
                        '$_selectedRating / 5.0 Stars',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.vanRed),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tags Selection Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Highlight Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableTags.map((tag) {
                          final isSelected = _selectedCategoryTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            selectedColor: AppColors.vanRed,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textDark,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedCategoryTags.add(tag);
                                } else {
                                  _selectedCategoryTags.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title & Description Inputs
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Review Headline / Title',
                          hintText: 'e.g. Wonderful experience with family!',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter headline' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _textController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Detailed Experience',
                          hintText: 'Write at least 20 characters about cleanliness, service, location, and overall experience...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().length < 20) {
                            return 'Review must be at least 20 characters long.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3240),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SUBMIT REVIEW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
