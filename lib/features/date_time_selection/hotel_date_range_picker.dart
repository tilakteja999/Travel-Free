import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'travel_search_model.dart';

class HotelDateRangePicker extends StatefulWidget {
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final ValueChanged<DateTimeRange> onDateRangeSelected;

  const HotelDateRangePicker({
    super.key,
    this.checkInDate,
    this.checkOutDate,
    required this.onDateRangeSelected,
  });

  @override
  State<HotelDateRangePicker> createState() => _HotelDateRangePickerState();
}

class _HotelDateRangePickerState extends State<HotelDateRangePicker> {
  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final today = TravelSearchModel.dateOnly(now);
    final maxDate = today.add(const Duration(days: 180));

    final initialStart = widget.checkInDate != null && !widget.checkInDate!.isBefore(today)
        ? TravelSearchModel.dateOnly(widget.checkInDate!)
        : today;
    
    final initialEnd = widget.checkOutDate != null && widget.checkOutDate!.isAfter(initialStart)
        ? TravelSearchModel.dateOnly(widget.checkOutDate!)
        : initialStart.add(const Duration(days: 1));

    final messenger = ScaffoldMessenger.of(context);

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      firstDate: today,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.vanRed,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final start = TravelSearchModel.dateOnly(picked.start);
      final end = TravelSearchModel.dateOnly(picked.end);

      if (start.isBefore(today)) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Selected date is outside the allowed travel period.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Check-out must be after check-in.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      widget.onDateRangeSelected(DateTimeRange(start: start, end: end));
    }
  }

  String _formatDateWithYear(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDates = widget.checkInDate != null && widget.checkOutDate != null;

    int nights = 0;
    if (hasDates) {
      final inD = TravelSearchModel.dateOnly(widget.checkInDate!);
      final outD = TravelSearchModel.dateOnly(widget.checkOutDate!);
      nights = outD.difference(inD).inDays;
    }

    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasDates ? const Color(0xFFFFF8E1) : Colors.amber.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDates ? Colors.amber.shade600 : Colors.amber.shade400,
            width: 1.5,
          ),
        ),
        child: hasDates && nights > 0
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHECK-IN',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateWithYear(widget.checkInDate!),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$nights ${nights == 1 ? 'Night' : 'Nights'} - ${nights + 1} Days',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'CHECK-OUT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateWithYear(widget.checkOutDate!),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select check-in and check-out dates',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                        ),
                        Text(
                          'Choose check-in and check-out to view hotel prices',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: _selectDateRange,
                    child: const Text('Choose Dates', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
      ),
    );
  }
}
