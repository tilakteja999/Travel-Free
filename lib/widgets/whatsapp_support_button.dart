import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppSupportButton extends StatelessWidget {
  final String? bookingId;
  final String phoneNumber;

  const WhatsAppSupportButton({
    super.key,
    this.bookingId,
    this.phoneNumber = '919876543210',
  });

  Future<void> _openWhatsApp(BuildContext context) async {
    final message = bookingId != null
        ? 'Hi Travel Time Support, I need assistance with my booking #$bookingId'
        : 'Hi Travel Time Support, I need assistance with my travel plans.';

    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$phoneNumber?text=$encoded');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening WhatsApp: $message')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact Support: $message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openWhatsApp(context),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF25D366), // WhatsApp Green
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'WhatsApp Support',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
