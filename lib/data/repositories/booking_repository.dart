import 'package:intl/intl.dart';
import 'package:terrain_express/core/api_client.dart';
import 'package:terrain_express/core/constants.dart';
import 'package:terrain_express/models/booking.dart';
import 'package:terrain_express/models/pitch.dart';
import 'package:terrain_express/models/slot.dart';

abstract class BookingRepository {
  Future<List<Slot>> getSlots(Pitch pitch, DateTime date);
  Future<Booking> createBooking(Pitch pitch, Slot slot);
  Future<List<Booking>> getMyBookings();
  Future<void> cancelBooking(int bookingId);
}

BookingRepository createBookingRepository() =>
    AppConstants.useMock ? MockBookingRepository() : ApiBookingRepository();

// ---------------------------------------------------------------------------
// FAKE version — slots from 16:00 to 00:00, some already taken
// `static` so bookings are shared between all screens
// ---------------------------------------------------------------------------
class MockBookingRepository implements BookingRepository {
  static final List<Booking> _bookings = [];
  static int _nextId = 1;

  @override
  Future<List<Slot>> getSlots(Pitch pitch, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final slots = <Slot>[];

    for (var hour = 16; hour < 24; hour++) {
      final start = DateTime(date.year, date.month, date.day, hour);
      final end = start.add(const Duration(hours: 1));

      final isPast = start.isBefore(now);
      final takenByOthers = (hour + date.day + pitch.id) % 3 == 0; // fake
      final takenByMe = _bookings.any((b) =>
      b.pitchId == pitch.id && b.start == start && !b.isCancelled);

      slots.add(Slot(
        pitchId: pitch.id,
        start: start,
        end: end,
        price: pitch.pricePerHour,
        isAvailable: !isPast && !takenByOthers && !takenByMe,
      ));
    }
    return slots;
  }

  @override
  Future<Booking> createBooking(Pitch pitch, Slot slot) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final conflict = _bookings.any((b) =>
    b.pitchId == pitch.id && b.start == slot.start && !b.isCancelled);
    if (conflict) {
      throw ApiException(409, 'This slot was just booked by someone else');
    }
    final booking = Booking(
      id: _nextId++,
      userId: 1,
      pitchId: pitch.id,
      start: slot.start,
      end: slot.end,
      totalPrice: slot.price,
      pitch: pitch,
    );
    _bookings.add(booking);
    return booking;
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.of(_bookings)..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final i = _bookings.indexWhere((b) => b.id == bookingId);
    if (i == -1) throw ApiException(404, 'Booking not found');
    final b = _bookings[i];
    _bookings[i] = Booking(
      id: b.id,
      userId: b.userId,
      pitchId: b.pitchId,
      start: b.start,
      end: b.end,
      totalPrice: b.totalPrice,
      status: 'cancelled',
      pitch: b.pitch,
    );
  }
}

// ---------------------------------------------------------------------------
// REAL version — Walid's /api/bookings routes
// ---------------------------------------------------------------------------
class ApiBookingRepository implements BookingRepository {
  final _api = ApiClient.instance;

  @override
  Future<List<Slot>> getSlots(Pitch pitch, DateTime date) async {
    final res = await _api.get('/pitches/${pitch.id}/slots',
        query: {'date': DateFormat('yyyy-MM-dd').format(date)});
    return (res as List).map((j) => Slot.fromJson(j)).toList();
  }

  @override
  Future<Booking> createBooking(Pitch pitch, Slot slot) async {
    final res = await _api.post('/bookings', body: {
      'pitch_id': pitch.id,
      'start_time': slot.start.toIso8601String(),
      'end_time': slot.end.toIso8601String(),
    });
    return Booking.fromJson(res);
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    final res = await _api.get('/bookings/me');
    return (res as List).map((j) => Booking.fromJson(j)).toList();
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    await _api.put('/bookings/$bookingId/cancel');
  }
}