import 'package:flutter/material.dart';
import 'package:terrain_express/widgets/placeholder_screen.dart';
import 'package:terrain_express/features/pitches/pitch_list_screen.dart';
import 'package:terrain_express/features/bookings/my_bookings_screen.dart';

/// Bottom navigation for PLAYERS
class PlayerShell extends StatefulWidget {
  const PlayerShell({super.key});

  @override
  State<PlayerShell> createState() => _PlayerShellState();
}

class _PlayerShellState extends State<PlayerShell> {
  int _index = 0;

  final _screens = const [
    PitchListScreen(),                                       // Amine ✅
    PlaceholderScreen(title: 'Matches', icon: Icons.groups), // Akram
    MyBookingsScreen(),                                      // Amine ✅
    PlaceholderScreen(title: 'Profile', icon: Icons.person), // Akram
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'Pitches'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Matches'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Bottom navigation for PITCH OWNERS (Akram's part)
class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _index = 0;

  final _screens = const [
    PlaceholderScreen(title: 'My pitches', icon: Icons.stadium),
    PlaceholderScreen(title: 'Bookings', icon: Icons.event_note),
    PlaceholderScreen(title: 'Profile', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.stadium), label: 'My pitches'),
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}