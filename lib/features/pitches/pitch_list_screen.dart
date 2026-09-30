import 'dart:async';
import 'package:flutter/material.dart';
import 'package:terrain_express/core/theme.dart';
import 'package:terrain_express/data/repositories/pitch_repository.dart';
import 'package:terrain_express/features/pitches/pitch_details_screen.dart';
import 'package:terrain_express/models/pitch.dart';

class PitchListScreen extends StatefulWidget {
  const PitchListScreen({super.key});

  @override
  State<PitchListScreen> createState() => _PitchListScreenState();
}

class _PitchListScreenState extends State<PitchListScreen> {
  final _repo = createPitchRepository();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Pitch> _pitches = [];
  bool _loading = true;
  String? _error;
  double? _maxPrice; // null = all prices

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.getPitches(
          query: _searchCtrl.text, maxPrice: _maxPrice);
      setState(() => _pitches = result);
    } catch (e) {
      setState(() => _error = 'Could not load pitches');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Wait until the user stops typing before searching
  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pitches in Fès')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search by name or area...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Price filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _priceChip('All', null),
                _priceChip('≤ 250 DH', 250),
                _priceChip('≤ 350 DH', 350),
              ],
            ),
          ),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _priceChip(String label, double? value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _maxPrice == value,
        onSelected: (_) {
          setState(() => _maxPrice = value);
          _load();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_pitches.isEmpty) {
      return const Center(child: Text('No pitches found'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pitches.length,
        itemBuilder: (_, i) => _PitchCard(pitch: _pitches[i]),
      ),
    );
  }
}

class _PitchCard extends StatelessWidget {
  final Pitch pitch;
  const _PitchCard({required this.pitch});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PitchDetailsScreen(pitchId: pitch.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sports_soccer,
                    color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pitch.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(pitch.address,
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(pitch.size,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.primary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${pitch.pricePerHour.toInt()} DH',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('/ hour',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}