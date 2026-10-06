import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DateTimeSelectorWidget extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String>? onTimeSlotSelected;
  final bool includeTimePicker;

  const DateTimeSelectorWidget({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.onTimeSlotSelected,
    this.includeTimePicker = false,
  });

  @override
  State<DateTimeSelectorWidget> createState() => _DateTimeSelectorWidgetState();
}

class _DateTimeSelectorWidgetState extends State<DateTimeSelectorWidget> {
  late DateTime _selectedDate;
  String _selectedTimeSlot = '08:00 AM';

  final List<String> _timeSlots = [
    '06:00 AM', '06:30 AM', '07:00 AM', '07:30 AM',
    '08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM',
    '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
    '06:00 PM', '06:30 PM', '07:00 PM', '07:30 PM',
    '08:00 PM', '08:30 PM', '09:00 PM', '09:30 PM',
    '10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  void _selectQuickChip(int offsetDays) {
    final now = DateTime.now();
    DateTime target = now.add(Duration(days: offsetDays));

    // For "This Weekend" (Saturday)
    if (offsetDays == -1) {
      final daysUntilSaturday = (DateTime.saturday - now.weekday + 7) % 7;
      target = now.add(Duration(days: daysUntilSaturday == 0 ? 7 : daysUntilSaturday));
    }

    setState(() {
      _selectedDate = DateTime(target.year, target.month, target.day);
    });
    widget.onDateSelected(_selectedDate);
  }

  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(const Duration(days: 180));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
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
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return '${days[dt.weekday % 7]}, ${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Chips Row (Today, Tomorrow, This Weekend, +7 Days)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip('Today', 0),
              const SizedBox(width: 8),
              _buildChip('Tomorrow', 1),
              const SizedBox(width: 8),
              _buildChip('This Weekend', -1),
              const SizedBox(width: 8),
              _buildChip('+7 Days', 7),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Main Selected Date Picker Display
        GestureDetector(
          onTap: _openDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.vanRed, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textDark),
              ],
            ),
          ),
        ),

        // Time Slot Picker for Cab / Auto / Specific Departures
        if (widget.includeTimePicker) ...[
          const SizedBox(height: 12),
          const Text(
            'Select Preferred Departure Time:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final slot = _timeSlots[index];
                final isSelected = slot == _selectedTimeSlot;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    selectedColor: AppColors.vanRed,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedTimeSlot = slot;
                        });
                        if (widget.onTimeSlotSelected != null) {
                          widget.onTimeSlotSelected!(slot);
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(String label, int offsetDays) {
    final now = DateTime.now();
    bool isSelected = false;

    if (offsetDays == 0 && _selectedDate.day == now.day && _selectedDate.month == now.month) {
      isSelected = true;
    } else if (offsetDays == 1 && _selectedDate.day == now.add(const Duration(days: 1)).day) {
      isSelected = true;
    }

    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected ? AppColors.vanRed : Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onPressed: () => _selectQuickChip(offsetDays),
    );
  }
}
