import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/whatsapp_support_button.dart';
import 'chat_support_screen.dart';
import 'report_issue_form.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I cancel or reschedule my booking?',
      'a': 'You can cancel or reschedule any train, bus, flight, or hotel booking directly from your Profile > My Bookings screen up to 4 hours before departure.',
    },
    {
      'q': 'What is your cancellation and refund policy?',
      'a': 'Full refunds are processed to your original payment method within 3–5 business days for cancellations made 24 hours prior to trip time.',
    },
    {
      'q': 'How do I download my E-Ticket or Invoice?',
      'a': 'After payment, your ticket is instantly generated with a QR code. Click "Download PDF" on the Booking Success screen or access it anytime from My Bookings.',
    },
    {
      'q': 'Are local tourist guides verified?',
      'a': 'Yes, all guides listed in Travel Time are certified heritage experts with verified phone numbers and local temple darshan escort passes.',
    },
    {
      'q': 'What payment methods are supported?',
      'a': 'We accept UPI (GPay, PhonePe, Paytm), Credit/Debit Cards (Visa, MasterCard, RuPay), Net Banking, and Wallets in Indian Rupees (₹).',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      return faq['q']!.toLowerCase().contains(_searchQuery) ||
          faq['a']!.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Help & Customer Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Contact Options Header
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.headset_mic, color: AppColors.vanRed, size: 28),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('24/7 Customer Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('🟢 Online • Avg response time: 15 mins', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChatSupportScreen()),
                            );
                          },
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('Live Chat'),
                        ),
                        const WhatsAppSupportButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Search FAQs input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search help topics & FAQs...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim().toLowerCase());
              },
            ),

            const SizedBox(height: 20),

            const Text('Frequently Asked Questions (FAQs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
            const SizedBox(height: 10),

            // FAQ Accordion
            ...filteredFaqs.map((faq) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(
                    faq['q']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Text(
                        faq['a']!,
                        style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Report an Issue Card
            Card(
              color: const Color(0xFFFFF3E0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.orange.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem_outlined, color: Colors.orange, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Have a specific issue with a booking?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Report payment, cancellation, or driver issues', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReportIssueForm()),
                        );
                      },
                      child: const Text('Report Issue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
