import 'package:terrain_express/core/api_client.dart';
import 'package:terrain_express/core/constants.dart';
import 'package:terrain_express/models/pitch.dart';

abstract class PitchRepository {
  Future<List<Pitch>> getPitches({String? query, double? maxPrice});
  Future<Pitch> getPitch(int id);
}

PitchRepository createPitchRepository() =>
    AppConstants.useMock ? MockPitchRepository() : ApiPitchRepository();

// ---------------------------------------------------------------------------
// FAKE data — pitches in Fès
// ---------------------------------------------------------------------------
class MockPitchRepository implements PitchRepository {
  static final _pitches = [
    Pitch(id: 1, name: 'Terrain Saiss', address: 'Route Sefrou, Saiss',
        city: 'Fès', size: '5v5', pricePerHour: 250, ownerId: 10, isValidated: true),
    Pitch(id: 2, name: 'Complexe Narjiss', address: 'Quartier Narjiss',
        city: 'Fès', size: '5v5', pricePerHour: 300, ownerId: 11, isValidated: true),
    Pitch(id: 3, name: 'Five Atlas', address: 'Avenue Atlas',
        city: 'Fès', size: '7v7', pricePerHour: 400, ownerId: 12, isValidated: true),
    Pitch(id: 4, name: 'Terrain Route Imouzzer', address: 'Route Imouzzer',
        city: 'Fès', size: '5v5', pricePerHour: 200, ownerId: 13, isValidated: true),
    Pitch(id: 5, name: 'Stade Mini Agdal', address: 'Quartier Agdal',
        city: 'Fès', size: '7v7', pricePerHour: 350, ownerId: 14, isValidated: true),
  ];

  @override
  Future<List<Pitch>> getPitches({String? query, double? maxPrice}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final q = (query ?? '').trim().toLowerCase();
    return _pitches.where((p) {
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q);
      final matchesPrice = maxPrice == null || p.pricePerHour <= maxPrice;
      return matchesQuery && matchesPrice;
    }).toList();
  }

  @override
  Future<Pitch> getPitch(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _pitches.firstWhere((p) => p.id == id);
  }
}

// ---------------------------------------------------------------------------
// REAL version — Walid's /api/pitches routes
// ---------------------------------------------------------------------------
class ApiPitchRepository implements PitchRepository {
  final _api = ApiClient.instance;

  @override
  Future<List<Pitch>> getPitches({String? query, double? maxPrice}) async {
    final res = await _api.get('/pitches', query: {
      if (query != null && query.isNotEmpty) 'q': query,
      if (maxPrice != null) 'max_price': maxPrice.toString(),
    });
    return (res as List).map((j) => Pitch.fromJson(j)).toList();
  }

  @override
  Future<Pitch> getPitch(int id) async {
    final res = await _api.get('/pitches/$id');
    return Pitch.fromJson(res);
  }
}