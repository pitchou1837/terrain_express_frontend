import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terrain_express/core/api_client.dart';
import 'package:terrain_express/core/theme.dart';
import 'package:terrain_express/data/repositories/booking_repository.dart';
import 'package:terrain_express/models/booking.dart';

/// Bumped whenever a booking is created/cancelled so this screen reloads
final bookingsChanged = ValueNotifier<int>(0);

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _repo = createBookingRepository();
  List<Booking> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    bookingsChanged.addListener(_load);
  }

  @override
  void dispose() {
    bookingsChanged.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.getMyBookings();
      if (mounted) setState(() => _bookings = list);
    } catch (_) {
      _showMessage('Could not load your bookings');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(Booking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: Text(
            'Cancel ${b.pitch?.name ?? 'this pitch'} on '
                '${DateFormat('EEE d MMM, HH:mm').format(b.start)}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep it')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel booking')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _repo.cancelBooking(b.id);
      _showMessage('Booking cancelled');
      bookingsChanged.value++;
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = _bookings
        .where((b) => !b.isCancelled && b.start.isAfter(now))
        .toList();
    final past = _bookings
        .where((b) => b.isCancelled || !b.start.isAfter(now))
        .toList()
        .reversed
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My bookings'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Upcoming'), Tab(text: 'Past & cancelled')],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _list(upcoming, 'No upcoming bookings.\nBook a pitch!',
                canCancel: true),
            _list(past, 'Nothing here yet'),
          ],
        ),
      ),
    );
  }

  Widget _list(List<Booking> items, String emptyText,
      {bool canCancel = false}) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => _BookingCard(
          booking: items[i],
          onCancel: canCancel ? () => _cancel(items[i]) : null,
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCancel;
  const _BookingCard({required this.booking, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final hour = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(b.pitch?.name ?? 'Pitch #${b.pitchId}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                _statusChip(b),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.event, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(DateFormat('EEEE d MMMM').format(b.start)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.schedule, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text('${hour.format(b.start)} - ${hour.format(b.end)}'),
              const Spacer(),
              Text('${b.totalPrice.toInt()} DH',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            if (onCancel != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, color: AppColors.error),
                  label: const Text('Cancel',
                      style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(Booking b) {
    final cancelled = b.isCancelled;
    final past = !cancelled && !b.start.isAfter(DateTime.now());
    final (label, color) = cancelled
        ? ('Cancelled', AppColors.error)
        : past
        ? ('Played', Colors.grey)
        : ('Confirmed', AppColors.primary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}