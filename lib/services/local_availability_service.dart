import 'package:shared_preferences/shared_preferences.dart';

class LocalAvailabilityService {
  static final LocalAvailabilityService _instance = LocalAvailabilityService._internal();
  factory LocalAvailabilityService() => _instance;
  LocalAvailabilityService._internal();

  static const String _keySeatsPrefix = 'travel_booked_seats_v1_';
  static const String _keyRoomsPrefix = 'travel_booked_rooms_v1_';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _seatKey(String transportId, String date, String routeKey) {
    return '$_keySeatsPrefix${transportId.replaceAll(' ', '_')}_${date.replaceAll(' ', '_')}_${routeKey.replaceAll(' ', '_')}';
  }

  String _roomKey(String hotelId, String checkInDate) {
    return '$_keyRoomsPrefix${hotelId.replaceAll(' ', '_')}_${checkInDate.replaceAll(' ', '_')}';
  }

  Future<void> lockRoom(String roomCode) async {
    await init();
    final list = _prefs?.getStringList('locked_rooms_v1') ?? [];
    if (!list.contains(roomCode)) {
      list.add(roomCode);
      await _prefs?.setStringList('locked_rooms_v1', list);
    }
  }

  Future<void> lockSeat(String seatCode) async {
    await init();
    final list = _prefs?.getStringList('locked_seats_v1') ?? [];
    if (!list.contains(seatCode)) {
      list.add(seatCode);
      await _prefs?.setStringList('locked_seats_v1', list);
    }
  }

  Future<void> releaseRoom(String roomCode) async {
    await init();
    final list = _prefs?.getStringList('locked_rooms_v1') ?? [];
    list.remove(roomCode);
    await _prefs?.setStringList('locked_rooms_v1', list);
  }

  Future<void> releaseSeat(String seatCode) async {
    await init();
    final list = _prefs?.getStringList('locked_seats_v1') ?? [];
    list.remove(seatCode);
    await _prefs?.setStringList('locked_seats_v1', list);
  }

  // Get Booked Seats
  Future<Set<String>> getBookedSeats(String transportId, String date, String routeKey) async {
    await init();
    final key = _seatKey(transportId, date, routeKey);
    final raw = _prefs?.getStringList(key);
    if (raw != null) {
      return Set<String>.from(raw);
    }
    return {};
  }

  // Book Seats
  Future<void> bookSeats(String transportId, String date, String routeKey, List<String> seatNumbers, String bookingId) async {
    await init();
    final key = _seatKey(transportId, date, routeKey);
    final current = await getBookedSeats(transportId, date, routeKey);
    current.addAll(seatNumbers);
    await _prefs?.setStringList(key, current.toList());
  }

  // Release Seats
  Future<void> releaseSeats(String transportId, String date, String routeKey, List<String> seatNumbers) async {
    await init();
    final key = _seatKey(transportId, date, routeKey);
    final current = await getBookedSeats(transportId, date, routeKey);
    current.removeAll(seatNumbers);
    await _prefs?.setStringList(key, current.toList());
  }

  // Get Booked Rooms
  Future<Set<String>> getBookedRooms(String hotelId, String checkInDate) async {
    await init();
    final key = _roomKey(hotelId, checkInDate);
    final raw = _prefs?.getStringList(key);
    if (raw != null) {
      return Set<String>.from(raw);
    }
    return {};
  }

  // Book Rooms
  Future<void> bookRooms(String hotelId, String checkInDate, List<String> roomNumbers, String bookingId) async {
    await init();
    final key = _roomKey(hotelId, checkInDate);
    final current = await getBookedRooms(hotelId, checkInDate);
    current.addAll(roomNumbers);
    await _prefs?.setStringList(key, current.toList());
  }

  // Release Rooms
  Future<void> releaseRooms(String hotelId, String checkInDate, List<String> roomNumbers) async {
    await init();
    final key = _roomKey(hotelId, checkInDate);
    final current = await getBookedRooms(hotelId, checkInDate);
    current.removeAll(roomNumbers);
    await _prefs?.setStringList(key, current.toList());
  }
}
