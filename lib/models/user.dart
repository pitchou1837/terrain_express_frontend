class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role; // "player", "owner" or "admin"
  final double reliabilityScore;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.reliabilityScore = 5.0,
  });

  bool get isOwner => role == 'owner';

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    role: json['role'] ?? 'player',
    reliabilityScore: (json['reliability_score'] ?? 5.0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'reliability_score': reliabilityScore,
  };
}