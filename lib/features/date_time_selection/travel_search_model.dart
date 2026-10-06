class TravelSearchModel {
  final String fromLocation;
  final String toLocation;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final DateTime? hotelCheckIn;
  final DateTime? hotelCheckOut;
  final bool isRoundTrip;
  final String searchType; // 'transport', 'hotel', 'places', 'general'
  final String? timeSlot;
  final int adultsCount;
  final int childrenCount;
  final int infantsCount;
  final int roomsCount;

  const TravelSearchModel({
    required this.fromLocation,
    required this.toLocation,
    this.departureDate,
    this.returnDate,
    this.hotelCheckIn,
    this.hotelCheckOut,
    this.isRoundTrip = false,
    this.searchType = 'general',
    this.timeSlot,
    this.adultsCount = 1,
    this.childrenCount = 0,
    this.infantsCount = 0,
    this.roomsCount = 1,
  });

  static DateTime dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  int get totalTravellers => adultsCount + childrenCount + infantsCount;
  int get seatedTravellers => adultsCount + childrenCount;

  String get formattedTravellerSummary {
    final parts = <String>[];
    parts.add('$adultsCount ${adultsCount == 1 ? 'Adult' : 'Adults'}');
    if (childrenCount > 0) parts.add('$childrenCount ${childrenCount == 1 ? 'Child' : 'Children'}');
    if (infantsCount > 0) parts.add('$infantsCount ${infantsCount == 1 ? 'Infant' : 'Infants'}');
    return parts.join(', ');
  }

  String get formattedGuestSummary {
    final roomText = '$roomsCount ${roomsCount == 1 ? 'Room' : 'Rooms'}';
    final guestText = '$totalTravellers ${totalTravellers == 1 ? 'Guest' : 'Guests'}';
    return '$roomText, $guestText';
  }

  int? get hotelNights {
    if (hotelCheckIn == null || hotelCheckOut == null) return null;
    final inDate = dateOnly(hotelCheckIn!);
    final outDate = dateOnly(hotelCheckOut!);
    final diff = outDate.difference(inDate).inDays;
    return diff > 0 ? diff : null;
  }

  int? get hotelDays {
    final nights = hotelNights;
    if (nights == null) return null;
    return nights + 1;
  }

  String get formattedDeparture {
    if (departureDate == null) return 'Select Departure Date';
    return formatDate(departureDate!);
  }

  String get formattedReturn {
    if (returnDate == null) return 'Add Return Date';
    return formatDate(returnDate!);
  }

  String get formattedCheckIn {
    if (hotelCheckIn == null) return 'Select Check-in';
    return formatDate(hotelCheckIn!);
  }

  String get formattedCheckOut {
    if (hotelCheckOut == null) return 'Select Check-out';
    return formatDate(hotelCheckOut!);
  }

  String get formattedHotelDurationSummary {
    final nights = hotelNights;
    if (nights == null) return 'Select Check-in & Check-out';
    final days = nights + 1;
    return '$nights ${nights == 1 ? 'Night' : 'Nights'} - $days Days';
  }

  static String formatTravelDate(DateTime? date) {
    if (date == null) return 'Select date';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatDateRange(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) {
      return 'Select check-in and check-out dates';
    }
    final nights = dateOnly(checkOut).difference(dateOnly(checkIn)).inDays;
    if (nights <= 0) return 'Invalid date range';
    final days = nights + 1;
    return '${formatTravelDate(checkIn)} - ${formatTravelDate(checkOut)} ($nights ${nights == 1 ? 'Night' : 'Nights'} - $days Days)';
  }

  static String formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dayName = days[dt.weekday % 7];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day.toString().padLeft(2, '0')} $monthName ${dt.year}';
  }

  static String formatShortDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  TravelSearchModel copyWith({
    String? fromLocation,
    String? toLocation,
    DateTime? departureDate,
    DateTime? returnDate,
    DateTime? hotelCheckIn,
    DateTime? hotelCheckOut,
    bool? isRoundTrip,
    String? searchType,
    String? timeSlot,
    int? adultsCount,
    int? childrenCount,
    int? infantsCount,
    int? roomsCount,
  }) {
    return TravelSearchModel(
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      hotelCheckIn: hotelCheckIn ?? this.hotelCheckIn,
      hotelCheckOut: hotelCheckOut ?? this.hotelCheckOut,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      searchType: searchType ?? this.searchType,
      timeSlot: timeSlot ?? this.timeSlot,
      adultsCount: adultsCount ?? this.adultsCount,
      childrenCount: childrenCount ?? this.childrenCount,
      infantsCount: infantsCount ?? this.infantsCount,
      roomsCount: roomsCount ?? this.roomsCount,
    );
  }
}
