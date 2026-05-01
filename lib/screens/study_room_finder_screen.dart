import 'package:flutter/material.dart';

import '../models/study_room.dart';
import '../services/firestore_service.dart';

class StudyRoomFinderScreen extends StatelessWidget {
  const StudyRoomFinderScreen({super.key});

  static const String routeName = '/study-room-finder';

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Room Finder'),
        actions: [
          IconButton(
            tooltip: 'Seed demo rooms',
            onPressed: () async {
              try {
                await firestoreService.seedDemoRooms();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Firestore rooms seeded.')),
                );
              } catch (error) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Room seed failed: $error')),
                );
              }
            },
            icon: const Icon(Icons.add_business_rounded),
          ),
        ],
      ),
      body: StreamBuilder<List<StudyRoom>>(
        stream: firestoreService.watchRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Room error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!;

          if (rooms.isEmpty) {
            return const Center(
              child: Text(
                'No rooms found. Tap the building icon in the top-right to create demo rooms.',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Available Study Rooms',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Live room data from Firestore.'),
              const SizedBox(height: 14),
              ...rooms.map(
                (room) => _RoomCard(
                  room: room,
                  onCheckIn: () => firestoreService.checkIntoRoom(room.id),
                  onCheckOut: () => firestoreService.checkOutOfRoom(room.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  final StudyRoom room;
  final Future<void> Function() onCheckIn;
  final Future<void> Function() onCheckOut;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = room.hasAvailableSeats ? Colors.green : Colors.red;
    final String statusText = room.hasAvailableSeats ? 'Available' : 'Full';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text(
          '${room.name} • ${room.building}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Occupancy: ${room.occupiedSeats}/${room.capacity} • ${room.availableSeats} seats open',
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              tooltip: 'Check out',
              onPressed: () async {
                try {
                  await onCheckOut();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checked out of room.')),
                  );
                } catch (error) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Check out failed: $error')),
                  );
                }
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            IconButton(
              tooltip: 'Check in',
              onPressed: room.hasAvailableSeats
                  ? () async {
                      try {
                        await onCheckIn();

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checked into room.')),
                        );
                      } catch (error) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Check in failed: $error')),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
            Chip(
              label: Text(statusText),
              backgroundColor: statusColor.withValues(alpha: 0.12),
              labelStyle: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
