import 'package:flutter/material.dart';
import 'package:terrain_express/core/theme.dart';
import 'package:terrain_express/data/repositories/pitch_repository.dart';
import 'package:terrain_express/models/pitch.dart';
import 'package:terrain_express/features/bookings/book_slot_screen.dart';

class PitchDetailsScreen extends StatefulWidget {
  final int pitchId;
  const PitchDetailsScreen({super.key, required this.pitchId});

  @override
  State<PitchDetailsScreen> createState() => _PitchDetailsScreenState();
}

class _PitchDetailsScreenState extends State<PitchDetailsScreen> {
  final _repo = createPitchRepository();
  late Future<Pitch> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getPitch(widget.pitchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pitch details')),
      body: FutureBuilder<Pitch>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return const Center(child: Text('Could not load this pitch'));
          }
          return _buildContent(snap.data!);
        },
      ),
    );
  }

  Widget _buildContent(Pitch pitch) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              // Header banner
              Container(
                height: 180,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Center(
                  child: Icon(Icons.sports_soccer,
                      size: 80, color: AppColors.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pitch.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _infoRow(Icons.location_on,
                        '${pitch.address}, ${pitch.city}'),
                    _infoRow(Icons.groups, 'Format: ${pitch.size}'),
                    _infoRow(Icons.payments,
                        '${pitch.pricePerHour.toInt()} DH / hour'),
                    _infoRow(Icons.store, 'Payment on site'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: const Text('See available slots'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BookSlotScreen(pitch: pitch)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}