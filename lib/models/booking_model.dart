enum BookingType {
  train,
  bus,
  flight,
  hotel,
  auto,
  cab,
}

enum BookingStatus {
  draft,
  pendingPayment,
  confirmed,
  completed,
  cancelled,
  paymentFailed,
}

class PassengerModel {
  final String name;
  final int age;
  final String gender;
  final String? seatOrRoomCode;

  const PassengerModel({
    required this.name,
    required this.age,
    required this.gender,
    this.seatOrRoomCode,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'seatOrRoomCode': seatOrRoomCode,
      };

  factory PassengerModel.fromJson(Map<String, dynamic> json) => PassengerModel(
        name: json['name'] ?? '',
        age: json['age'] is int ? json['age'] : (int.tryParse(json['age']?.toString() ?? '25') ?? 25),
        gender: json['gender'] ?? 'Male',
        seatOrRoomCode: json['seatOrRoomCode'],
      );
}

class BookingModel {
  final String bookingId;
  final String userId;
  final BookingType bookingType;
  final BookingStatus status;

  final String fromLocation;
  final String toLocation;

  final String? hotelId;
  final String? hotelName;

  final DateTime createdAt;
  final DateTime? departureDateTime;
  final DateTime? returnDateTime;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;

  final List<PassengerModel> passengers;
  final List<String> selectedSeatIds;
  final List<String> selectedRoomIds;

  final double baseFare;
  final double taxes;
  final double convenienceFee;
  final double totalAmount;

  final String paymentMethod;
  final String? localTransactionId;

  final String? cancellationReason;
  final double? refundEstimate;

  final bool isDemoBooking;

  const BookingModel({
    required this.bookingId,
    required this.userId,
    required this.bookingType,
    required this.status,
    required this.fromLocation,
    required this.toLocation,
    this.hotelId,
    this.hotelName,
    required this.createdAt,
    this.departureDateTime,
    this.returnDateTime,
    this.checkInDate,
    this.checkOutDate,
    required this.passengers,
    this.selectedSeatIds = const [],
    this.selectedRoomIds = const [],
    required this.baseFare,
    this.taxes = 0.0,
    this.convenienceFee = 0.0,
    required this.totalAmount,
    this.paymentMethod = 'UPI (Demo)',
    this.localTransactionId,
    this.cancellationReason,
    this.refundEstimate,
    this.isDemoBooking = true,
  });

  bool get isUpcoming {
    if (status == BookingStatus.cancelled || status == BookingStatus.paymentFailed) return false;
    final now = DateTime.now();
    if (departureDateTime != null) return departureDateTime!.isAfter(now);
    if (checkInDate != null) return checkInDate!.isAfter(now);
    return status == BookingStatus.confirmed;
  }

  bool get isCompleted => status == BookingStatus.completed || (!isUpcoming && status == BookingStatus.confirmed);

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'userId': userId,
        'bookingType': bookingType.name,
        'status': status.name,
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        'hotelId': hotelId,
        'hotelName': hotelName,
        'createdAt': createdAt.toIso8601String(),
        'departureDateTime': departureDateTime?.toIso8601String(),
        'returnDateTime': returnDateTime?.toIso8601String(),
        'checkInDate': checkInDate?.toIso8601String(),
        'checkOutDate': checkOutDate?.toIso8601String(),
        'passengers': passengers.map((p) => p.toJson()).toList(),
        'selectedSeatIds': selectedSeatIds,
        'selectedRoomIds': selectedRoomIds,
        'baseFare': baseFare,
        'taxes': taxes,
        'convenienceFee': convenienceFee,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'localTransactionId': localTransactionId,
        'cancellationReason': cancellationReason,
        'refundEstimate': refundEstimate,
        'isDemoBooking': isDemoBooking,
      };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        bookingId: json['bookingId'] ?? '',
        userId: json['userId'] ?? '',
        bookingType: BookingType.values.firstWhere(
          (e) => e.name == json['bookingType'],
          orElse: () => BookingType.train,
        ),
        status: BookingStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => BookingStatus.confirmed,
        ),
        fromLocation: json['fromLocation'] ?? '',
        toLocation: json['toLocation'] ?? '',
        hotelId: json['hotelId'],
        hotelName: json['hotelName'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        departureDateTime: DateTime.tryParse(json['departureDateTime'] ?? ''),
        returnDateTime: DateTime.tryParse(json['returnDateTime'] ?? ''),
        checkInDate: DateTime.tryParse(json['checkInDate'] ?? ''),
        checkOutDate: DateTime.tryParse(json['checkOutDate'] ?? ''),
        passengers: (json['passengers'] as List? ?? []).map((p) => PassengerModel.fromJson(Map<String, dynamic>.from(p))).toList(),
        selectedSeatIds: List<String>.from(json['selectedSeatIds'] ?? []),
        selectedRoomIds: List<String>.from(json['selectedRoomIds'] ?? []),
        baseFare: (json['baseFare'] as num?)?.toDouble() ?? 0.0,
        taxes: (json['taxes'] as num?)?.toDouble() ?? 0.0,
        convenienceFee: (json['convenienceFee'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        paymentMethod: json['paymentMethod'] ?? 'UPI (Demo)',
        localTransactionId: json['localTransactionId'],
        cancellationReason: json['cancellationReason'],
        refundEstimate: (json['refundEstimate'] as num?)?.toDouble(),
        isDemoBooking: json['isDemoBooking'] ?? true,
      );

  BookingModel copyWith({
    BookingStatus? status,
    String? cancellationReason,
    double? refundEstimate,
    String? localTransactionId,
  }) {
    return BookingModel(
      bookingId: bookingId,
      userId: userId,
      bookingType: bookingType,
      status: status ?? this.status,
      fromLocation: fromLocation,
      toLocation: toLocation,
      hotelId: hotelId,
      hotelName: hotelName,
      createdAt: createdAt,
      departureDateTime: departureDateTime,
      returnDateTime: returnDateTime,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      passengers: passengers,
      selectedSeatIds: selectedSeatIds,
      selectedRoomIds: selectedRoomIds,
      baseFare: baseFare,
      taxes: taxes,
      convenienceFee: convenienceFee,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      localTransactionId: localTransactionId ?? this.localTransactionId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      refundEstimate: refundEstimate ?? this.refundEstimate,
      isDemoBooking: isDemoBooking,
    );
  }
}
