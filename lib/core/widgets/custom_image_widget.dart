import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableFullscreenOnClick;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableFullscreenOnClick = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageContent;

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      imageContent = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.redAccent,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackWidget();
        },
      );
    } else if (imageUrl.startsWith('assets/')) {
      imageContent = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallbackWidget(),
      );
    } else {
      imageContent = _buildFallbackWidget();
    }

    if (borderRadius != null) {
      imageContent = ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    if (enableFullscreenOnClick) {
      return GestureDetector(
        onTap: () => _openFullscreen(context),
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildFallbackWidget() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFEFEFEF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.landscape, color: Colors.grey, size: 36),
          SizedBox(height: 4),
          Text(
            'Travel Image',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackWidget(),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
