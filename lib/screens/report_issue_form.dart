import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportIssueForm extends StatefulWidget {
  final String? initialBookingId;

  const ReportIssueForm({super.key, this.initialBookingId});

  @override
  State<ReportIssueForm> createState() => _ReportIssueFormState();
}

class _ReportIssueFormState extends State<ReportIssueForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bookingIdController;
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Payment Issue';
  bool _isSubmitted = false;

  final List<String> _categories = [
    'Payment Issue',
    'Cancellation & Refund',
    'Hotel Experience',
    'Transport / Driver Issue',
    'E-Ticket Download Problem',
    'Other General Issue',
  ];

  @override
  void initState() {
    super.initState();
    _bookingIdController = TextEditingController(text: widget.initialBookingId ?? 'TRV-TRA-84920');
  }

  @override
  void dispose() {
    _bookingIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Report an Issue'),
      ),
      body: _isSubmitted ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Issue Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    const Text('Booking Reference ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bookingIdController,
                      decoration: InputDecoration(
                        hintText: 'e.g. TRV-TRA-84920',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.confirmation_number),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter booking ID' : null,
                    ),

                    const SizedBox(height: 16),

                    const Text('Detailed Issue Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Please describe the problem in detail (minimum 50 characters)...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 50) {
                          return 'Please provide at least 50 characters describing your issue.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vanRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: _submitReport,
                child: const Text('SUBMIT REPORT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Issue Reported Successfully!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ticket Ticket Reference: #TKT-SUP-98214\nOur support executive will review your ticket and respond within 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Help Center'),
            ),
          ],
        ),
      ),
    );
  }
}
