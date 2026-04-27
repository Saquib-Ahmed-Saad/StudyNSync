import 'package:flutter/material.dart';

class StudyRoomFinderScreen extends StatelessWidget {
  const StudyRoomFinderScreen({super.key});

  static const String routeName = '/study-room-finder';

  static const List<_RoomItem> _rooms = [
    _RoomItem(name: 'Library Room A', occupancy: 3, capacity: 6, isAvailable: true),
    _RoomItem(name: 'Engineering Lab 2', occupancy: 8, capacity: 8, isAvailable: false),
    _RoomItem(name: 'Discussion Hub B1', occupancy: 2, capacity: 5, isAvailable: true),
    _RoomItem(name: 'Innovation Room C', occupancy: 10, capacity: 10, isAvailable: false),
    _RoomItem(name: 'Quiet Zone D', occupancy: 1, capacity: 4, isAvailable: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Room Finder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Available Study Rooms',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a room based on current occupancy.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 14),
          ..._rooms.map(
            (room) => _RoomCard(room: room),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room});

  final _RoomItem room;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = room.isAvailable ? Colors.green : Colors.red;
    final String statusText = room.isAvailable ? 'Available' : 'Full';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withValues(alpha: 0.45)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          title: Text(
            room.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Occupancy: ${room.occupancy}/${room.capacity}'),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomItem {
  const _RoomItem({
    required this.name,
    required this.occupancy,
    required this.capacity,
    required this.isAvailable,
  });

  final String name;
  final int occupancy;
  final int capacity;
  final bool isAvailable;
}
