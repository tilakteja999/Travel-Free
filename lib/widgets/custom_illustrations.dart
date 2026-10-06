import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Star Rating Widget that matches the design (e.g. 5 star outline/filled stars)
class StarRatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.size = 18,
    this.color = AppColors.starGold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: color);
        } else if (index < rating && rating - index >= 0.5) {
          return Icon(Icons.star_half, size: size, color: color);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.grey.shade400);
        }
      }),
    );
  }
}

/// Custom painter for the Login screen background (Globe, Beach, Luggage & Camera)
class LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sky/Tropical gradient
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Gradient skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFCBE3FB),
        const Color(0xFFE2F0FD),
        const Color(0xFFC7ECEE),
        const Color(0xFFBBE5BD),
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
    final Paint bgPaint = Paint()..shader = skyGradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Stylized Globe behind card
    final Paint globeWater = Paint()..color = const Color(0xFF51A3E0);
    final Offset center = Offset(size.width * 0.5, size.height * 0.3);
    final double radius = size.width * 0.42;

    canvas.drawCircle(center, radius, globeWater);

    // Draw continents on globe
    final Paint landPaint = Paint()
      ..color = const Color(0xFF76C893)
      ..style = PaintingStyle.fill;

    final Path land1 = Path()
      ..addOval(Rect.fromLTWH(center.dx - radius * 0.6, center.dy - radius * 0.5, radius * 0.8, radius * 0.7));
    final Path land2 = Path()
      ..addOval(Rect.fromLTWH(center.dx + radius * 0.1, center.dy - radius * 0.3, radius * 0.6, radius * 0.8));
    final Path land3 = Path()
      ..addOval(Rect.fromLTWH(center.dx - radius * 0.3, center.dy + radius * 0.1, radius * 0.7, radius * 0.5));

    canvas.drawPath(land1, landPaint);
    canvas.drawPath(land2, landPaint);
    canvas.drawPath(land3, landPaint);

    // Draw Sun hat / Beach element on top right of globe
    final Paint hatPaint = Paint()..color = const Color(0xFFFDEB71);
    canvas.drawArc(
      Rect.fromLTWH(center.dx + radius * 0.1, center.dy - radius * 0.8, 120, 70),
      0,
      math.pi * 2,
      false,
      hatPaint,
    );

    // Decorative clouds
    final Paint cloudPaint = Paint()..color = Colors.white.withOpacity(0.85);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.12), 28, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.10), 36, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.12), 26, cloudPaint);

    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.15), 32, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.87, size.height * 0.13), 42, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Retro Van Illustration Painter for Home Screen
class RetroVanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Background Gradient (Sun & Sea & Palms)
    final Rect bgRect = Rect.fromLTWH(0, 0, w, h);
    final Gradient bgGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF91C788),
        const Color(0xFFBCE7FD),
        const Color(0xFF70A6FF),
        const Color(0xFFE2A082),
        const Color(0xFF283655),
      ],
      stops: const [0.0, 0.25, 0.55, 0.8, 1.0],
    );
    canvas.drawRect(bgRect, Paint()..shader = bgGrad.createShader(bgRect));

    // Sun
    final Paint sunPaint = Paint()..color = const Color(0xFFF9A03F);
    canvas.drawCircle(Offset(w * 0.5, h * 0.32), w * 0.38, sunPaint);

    // Palm tree silhouettes on sides
    final Paint palmPaint = Paint()..color = const Color(0xFF2D4030);
    // Left palm trunk
    final Path leftTrunk = Path()
      ..moveTo(0, h * 0.6)
      ..quadraticBezierTo(w * 0.08, h * 0.45, w * 0.02, h * 0.3)
      ..lineTo(0, h * 0.3)
      ..close();
    canvas.drawPath(leftTrunk, palmPaint);

    // Right palm trunk
    final Path rightTrunk = Path()
      ..moveTo(w, h * 0.6)
      ..quadraticBezierTo(w * 0.92, h * 0.45, w * 0.98, h * 0.3)
      ..lineTo(w, h * 0.3)
      ..close();
    canvas.drawPath(rightTrunk, palmPaint);

    // Road at bottom
    final Paint roadPaint = Paint()..color = const Color(0xFF333A42);
    final Path roadPath = Path()
      ..moveTo(w * 0.1, h)
      ..lineTo(w * 0.25, h * 0.72)
      ..lineTo(w * 0.75, h * 0.72)
      ..lineTo(w * 0.9, h)
      ..close();
    canvas.drawPath(roadPath, roadPaint);

    // Road centerline
    final Paint linePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.5, h * 0.98), Offset(w * 0.5, h * 0.82), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Scenic Mountain & Train Background for Bookings
class TransportScenicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Sky gradient
    final Rect rect = Rect.fromLTWH(0, 0, w, h);
    final Gradient sky = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF90C1E7),
        const Color(0xFFD6E8F7),
        const Color(0xFFF7E2C6),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = sky.createShader(rect));

    // Sun behind mountains
    canvas.drawCircle(Offset(w * 0.3, h * 0.35), 45, Paint()..color = const Color(0xFFFFF0A5));

    // Mountains
    final Paint mtn1 = Paint()..color = const Color(0xFF6B839E);
    final Path p1 = Path()
      ..moveTo(0, h * 0.6)
      ..lineTo(w * 0.35, h * 0.3)
      ..lineTo(w * 0.7, h * 0.65)
      ..lineTo(0, h * 0.65)
      ..close();
    canvas.drawPath(p1, mtn1);

    final Paint mtn2 = Paint()..color = const Color(0xFF4A607A);
    final Path p2 = Path()
      ..moveTo(w * 0.25, h * 0.65)
      ..lineTo(w * 0.65, h * 0.25)
      ..lineTo(w, h * 0.6)
      ..lineTo(w, h * 0.65)
      ..close();
    canvas.drawPath(p2, mtn2);

    // Green Hills
    final Paint hillPaint = Paint()..color = const Color(0xFF638B42);
    final Path hill = Path()
      ..moveTo(0, h * 0.6)
      ..quadraticBezierTo(w * 0.5, h * 0.5, w, h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill, hillPaint);

    // Train tracks at bottom
    final Paint trackPaint = Paint()
      ..color = const Color(0xFF433422)
      ..strokeWidth = 3;
    final Path tracks = Path()
      ..moveTo(0, h * 0.92)
      ..lineTo(w * 0.7, h * 0.8)
      ..lineTo(w, h * 0.85);
    canvas.drawPath(tracks, trackPaint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
