import 'pitch.dart';

class GameMatch {
  final int id;
  final int creatorId;
  final int pitchId;
  final DateTime start;
  final String level;       // "beginner", "intermediate", "advanced"
  final int playersNeeded;  // e.g. 2
  final int playersJoined;
  final List<int> playerIds;
  final String status;      // "open", "full", "finished"
  final Pitch? pitch;

  GameMatch({
    required this.id,
    required this.creatorId,
    required this.pitchId,
    required this.start,
    required this.level,
    required this.playersNeeded,
    this.playersJoined = 0,
    this.playerIds = const [],
    this.status = 'open',
    this.pitch,
  });

  int get spotsLeft => playersNeeded - playersJoined;
  bool get isOpen => status == 'open' && spotsLeft > 0;

  factory GameMatch.fromJson(Map<String, dynamic> json) => GameMatch(
    id: json['id'],
    creatorId: json['creator_id'],
    pitchId: json['pitch_id'],
    start: DateTime.parse(json['start_time']),
    level: json['level'] ?? 'intermediate',
    playersNeeded: json['players_needed'] ?? 0,
    playersJoined: json['players_joined'] ?? 0,
    playerIds: List<int>.from(json['player_ids'] ?? []),
    status: json['status'] ?? 'open',
    pitch: json['pitch'] != null ? Pitch.fromJson(json['pitch']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'creator_id': creatorId,
    'pitch_id': pitchId,
    'start_time': start.toIso8601String(),
    'level': level,
    'players_needed': playersNeeded,
    'players_joined': playersJoined,
    'player_ids': playerIds,
    'status': status,
  };
}