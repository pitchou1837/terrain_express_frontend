import 'pitch.dart';

class Booking {
  final int id;
  final int userId;
  final int pitchId;
  final DateTime start;
  final DateTime end;
  final double totalPrice;
  final String status; // "confirmed" or "cancelled"
  final Pitch? pitch;  // pitch details, if the backend sends them

  Booking({
    required this.id,
    required this.userId,
    required this.pitchId,
    required this.start,
    required this.end,
    required this.totalPrice,
    this.status = 'confirmed',
    this.pitch,
  });

  bool get isCancelled => status == 'cancelled';

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'],
    userId: json['user_id'],
    pitchId: json['pitch_id'],
    start: DateTime.parse(json['start_time']),
    end: DateTime.parse(json['end_time']),
    totalPrice: (json['total_price'] ?? 0).toDouble(),
    status: json['status'] ?? 'confirmed',
    pitch: json['pitch'] != null ? Pitch.fromJson(json['pitch']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'pitch_id': pitchId,
    'start_time': start.toIso8601String(),
    'end_time': end.toIso8601String(),
    'total_price': totalPrice,
    'status': status,
  };
}