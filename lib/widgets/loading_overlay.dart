import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingOverlay {
  static OverlayEntry? _currentEntry;

  static void show(BuildContext context, {String message = 'Loading, please wait...'}) {
    hide();

    _currentEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 42,
                  height: 42,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: AppColors.vanRed,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }

  static void hide() {
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
    }
  }
}
