import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terrain_express/core/api_client.dart';
import 'package:terrain_express/core/theme.dart';
import 'package:terrain_express/data/repositories/booking_repository.dart';
import 'package:terrain_express/models/pitch.dart';
import 'package:terrain_express/models/slot.dart';
import 'package:terrain_express/features/bookings/my_bookings_screen.dart';

class BookSlotScreen extends StatefulWidget {
  final Pitch pitch;
  const BookSlotScreen({super.key, required this.pitch});

  @override
  State<BookSlotScreen> createState() => _BookSlotScreenState();
}

class _BookSlotScreenState extends State<BookSlotScreen> {
  final _repo = createBookingRepository();
  final _hour = DateFormat('HH:mm');

  late final List<DateTime> _days; // next 7 days
  late DateTime _selectedDay;
  List<Slot> _slots = [];
  Slot? _selectedSlot;
  bool _loading = true;
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _days = List.generate(
        7, (i) => DateTime(today.year, today.month, today.day + i));
    _selectedDay = _days.first;
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _selectedSlot = null;
    });
    try {
      final slots = await _repo.getSlots(widget.pitch, _selectedDay);
      setState(() => _slots = slots);
    } catch (_) {
      _showMessage('Could not load slots');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmBooking() async {
    final slot = _selectedSlot!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm booking'),
        content: Text(
          '${widget.pitch.name}\n'
              '${DateFormat('EEEE d MMMM').format(slot.start)}\n'
              '${_hour.format(slot.start)} - ${_hour.format(slot.end)}\n\n'
              'Price: ${slot.price.toInt()} DH (pay on site)',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Book')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _booking = true);
    try {
      await _repo.createBooking(widget.pitch, slot);
      bookingsChanged.value++;
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle,
              color: AppColors.primary, size: 48),
          title: const Text('Booked!'),
          content: const Text(
              'Your slot is reserved. Find it in the Bookings tab.'),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK')),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      _showMessage(e.message); // e.g. slot taken by someone else
      _loadSlots();
    } catch (_) {
      _showMessage('Booking failed, try again');
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pitch.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Day selector ----
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: _days.length,
              itemBuilder: (_, i) {
                final day = _days[i];
                final selected = day == _selectedDay;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(i == 0
                        ? 'Today'
                        : DateFormat('EEE d').format(day)),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedDay = day);
                      _loadSlots();
                    },
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Choose a time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),

          // ---- Slot grid ----
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _slots.map(_slotTile).toList(),
              ),
            ),
          ),

          // ---- Bottom bar ----
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: (_selectedSlot == null || _booking)
                    ? null
                    : _confirmBooking,
                child: _booking
                    ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Text(_selectedSlot == null
                    ? 'Select a slot'
                    : 'Book ${_hour.format(_selectedSlot!.start)} · '
                    '${_selectedSlot!.price.toInt()} DH'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotTile(Slot slot) {
    final selected = _selectedSlot == slot;
    final available = slot.isAvailable;

    return InkWell(
      onTap: available ? () => setState(() => _selectedSlot = slot) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : available
              ? Colors.white
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: available ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Text(
              _hour.format(slot.start),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected
                    ? Colors.white
                    : available
                    ? Colors.black
                    : Colors.grey,
                decoration: available ? null : TextDecoration.lineThrough,
              ),
            ),
            Text(
              available ? 'Free' : 'Taken',
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}