import 'package:flutter/material.dart';
import '../features/ride_hailing/models/ride_feedback_model.dart';
import '../features/ride_hailing/providers/ride_provider.dart';
import '../features/ride_hailing/repositories/local_ride_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/persistent_profile_widget.dart';
import 'home_screen.dart';

class RideFeedbackScreen extends StatefulWidget {
  final String bookingId;

  const RideFeedbackScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<RideFeedbackScreen> createState() => _RideFeedbackScreenState();
}

class _RideFeedbackScreenState extends State<RideFeedbackScreen> {
  int _overallRating = 5;
  int _driverRating = 5;
  int _cleanlinessRating = 5;
  int _safetyRating = 5;
  int _appExperienceRating = 5;

  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedTags = {'Great driver', 'Smooth ride'};

  final List<String> _availableTags = [
    'Great driver',
    'Smooth ride',
    'Clean vehicle',
    'Polite behavior',
    'Punctual',
    'Driver was late',
    'Vehicle issue',
    'Route issue',
  ];

  void _submitFeedback() async {
    final currentUser = AuthService().getCurrentUser();
    final userId = currentUser?.id ?? 'guest';

    final feedback = RideFeedbackModel(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      rideBookingId: widget.bookingId,
      userId: userId,
      overallRating: _overallRating,
      driverRating: _driverRating,
      cleanlinessRating: _cleanlinessRating,
      safetyRating: _safetyRating,
      appExperienceRating: _appExperienceRating,
      comment: _commentController.text.trim(),
      issueTags: _selectedTags.toList(),
      submittedAt: DateTime.now(),
    );

    await LocalRideRepository().saveFeedback(feedback);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Your feedback was saved locally in Demo Mode.'),
        backgroundColor: AppColors.accentGreen,
        duration: Duration(seconds: 4),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driverName = RideProvider().activeBooking?.driver?.name ?? 'Driver';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Rate Your Ride'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: PersistentProfileWidget()),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Rating Header
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'How was your ride with $driverName?',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          return IconButton(
                            icon: Icon(
                              star <= _overallRating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 36,
                            ),
                            onPressed: () => setState(() => _overallRating = star),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Detailed Ratings Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Detailed Ratings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      _buildRatingRow('Driver Behavior', _driverRating, (val) => setState(() => _driverRating = val)),
                      _buildRatingRow('Vehicle Cleanliness', _cleanlinessRating, (val) => setState(() => _cleanlinessRating = val)),
                      _buildRatingRow('Safety & Comfort', _safetyRating, (val) => setState(() => _safetyRating = val)),
                      _buildRatingRow('App Experience', _appExperienceRating, (val) => setState(() => _appExperienceRating = val)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Feedback Tags
              const Text('Ride Highlights / Issues', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Written Comment Field
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add additional feedback or comments (optional)...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Feedback Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3240),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 3,
                  ),
                  onPressed: _submitFeedback,
                  child: const Text('SUBMIT FEEDBACK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(String title, int currentValue, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return InkWell(
                onTap: () => onChanged(star),
                child: Icon(
                  star <= currentValue ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 22,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
