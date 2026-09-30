class Pitch {
  final int id;
  final String name;
  final String address;
  final String city;
  final String size; // "5v5", "7v7"...
  final double pricePerHour;
  final String? imageUrl;
  final int ownerId;
  final bool isValidated; // approved by admin

  Pitch({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.size,
    required this.pricePerHour,
    this.imageUrl,
    required this.ownerId,
    this.isValidated = false,
  });

  factory Pitch.fromJson(Map<String, dynamic> json) => Pitch(
    id: json['id'],
    name: json['name'] ?? '',
    address: json['address'] ?? '',
    city: json['city'] ?? '',
    size: json['size'] ?? '5v5',
    pricePerHour: (json['price_per_hour'] ?? 0).toDouble(),
    imageUrl: json['image_url'],
    ownerId: json['owner_id'] ?? 0,
    isValidated: json['is_validated'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'city': city,
    'size': size,
    'price_per_hour': pricePerHour,
    'image_url': imageUrl,
    'owner_id': ownerId,
    'is_validated': isValidated,
  };
}