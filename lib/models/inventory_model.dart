import 'dart:convert';

enum InventoryStatus {
  available,
  selected,
  booked,
  unavailable,
}

class SeatInventory {
  final String inventoryId;
  final String transportId;
  final String routeKey;
  final String travelDate;
  final String coach;
  final String seatNumber;
  final String seatType;
  final InventoryStatus status;
  final String? bookingId;

  const SeatInventory({
    required this.inventoryId,
    required this.transportId,
    required this.routeKey,
    required this.travelDate,
    required this.coach,
    required this.seatNumber,
    required this.seatType,
    required this.status,
    this.bookingId,
  });

  SeatInventory copyWith({
    InventoryStatus? status,
    String? bookingId,
  }) {
    return SeatInventory(
      inventoryId: inventoryId,
      transportId: transportId,
      routeKey: routeKey,
      travelDate: travelDate,
      coach: coach,
      seatNumber: seatNumber,
      seatType: seatType,
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  Map<String, dynamic> toJson() => {
        'inventoryId': inventoryId,
        'transportId': transportId,
        'routeKey': routeKey,
        'travelDate': travelDate,
        'coach': coach,
        'seatNumber': seatNumber,
        'seatType': seatType,
        'status': status.name,
        'bookingId': bookingId,
      };

  factory SeatInventory.fromJson(Map<String, dynamic> json) => SeatInventory(
        inventoryId: json['inventoryId'] ?? '',
        transportId: json['transportId'] ?? '',
        routeKey: json['routeKey'] ?? '',
        travelDate: json['travelDate'] ?? '',
        coach: json['coach'] ?? '',
        seatNumber: json['seatNumber'] ?? '',
        seatType: json['seatType'] ?? '',
        status: InventoryStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => InventoryStatus.available,
        ),
        bookingId: json['bookingId'],
      );
}

class RoomInventory {
  final String inventoryId;
  final String hotelId;
  final String roomType;
  final String checkInDate;
  final String roomNumber;
  final InventoryStatus status;
  final String? bookingId;

  const RoomInventory({
    required this.inventoryId,
    required this.hotelId,
    required this.roomType,
    required this.checkInDate,
    required this.roomNumber,
    required this.status,
    this.bookingId,
  });

  RoomInventory copyWith({
    InventoryStatus? status,
    String? bookingId,
  }) {
    return RoomInventory(
      inventoryId: inventoryId,
      hotelId: hotelId,
      roomType: roomType,
      checkInDate: checkInDate,
      roomNumber: roomNumber,
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  Map<String, dynamic> toJson() => {
        'inventoryId': inventoryId,
        'hotelId': hotelId,
        'roomType': roomType,
        'checkInDate': checkInDate,
        'roomNumber': roomNumber,
        'status': status.name,
        'bookingId': bookingId,
      };

  factory RoomInventory.fromJson(Map<String, dynamic> json) => RoomInventory(
        inventoryId: json['inventoryId'] ?? '',
        hotelId: json['hotelId'] ?? '',
        roomType: json['roomType'] ?? '',
        checkInDate: json['checkInDate'] ?? '',
        roomNumber: json['roomNumber'] ?? '',
        status: InventoryStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => InventoryStatus.available,
        ),
        bookingId: json['bookingId'],
      );
}
