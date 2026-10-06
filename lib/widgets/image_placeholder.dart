import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final String category;

  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.category = 'place',
  });

  @override
  Widget build(BuildContext context) {
    final isHotel = category.toLowerCase().contains('hotel') || category.toLowerCase().contains('resort');

    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0F0F0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isHotel ? Icons.hotel : Icons.account_balance,
            size: 32,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 4),
          Text(
            isHotel ? 'Loading Hotel...' : 'Loading Attraction...',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
