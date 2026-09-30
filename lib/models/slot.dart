class Slot {
  final int? id;
  final int pitchId;
  final DateTime start;
  final DateTime end;
  final double price;
  final bool isAvailable; // false = already booked or blocked

  Slot({
    this.id,
    required this.pitchId,
    required this.start,
    required this.end,
    required this.price,
    this.isAvailable = true,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    id: json['id'],
    pitchId: json['pitch_id'],
    start: DateTime.parse(json['start_time']),
    end: DateTime.parse(json['end_time']),
    price: (json['price'] ?? 0).toDouble(),
    isAvailable: json['is_available'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'pitch_id': pitchId,
    'start_time': start.toIso8601String(),
    'end_time': end.toIso8601String(),
    'price': price,
    'is_available': isAvailable,
  };
}