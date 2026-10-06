import 'package:flutter/material.dart';

class ShimmerCard extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_animController.value * 2.0), -0.3),
              end: Alignment(1.0 + (_animController.value * 2.0), 0.3),
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerListPlaceholder extends StatelessWidget {
  const ShimmerListPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const ShimmerCard(width: 110, height: 85),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerCard(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    ShimmerCard(width: 120, height: 12),
                    SizedBox(height: 8),
                    ShimmerCard(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
