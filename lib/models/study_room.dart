import 'package:cloud_firestore/cloud_firestore.dart';

class StudyRoom {
  final String id;
  final String name;
  final String building;
  final int capacity;
  final int occupiedSeats;
  final bool isOpen;
  final DateTime updatedAt;

  const StudyRoom({
    required this.id,
    required this.name,
    required this.building,
    required this.capacity,
    required this.occupiedSeats,
    this.isOpen = true,
    required this.updatedAt,
  });

  bool get hasAvailableSeats => isOpen && occupiedSeats < capacity;
  int get availableSeats => capacity - occupiedSeats;

  factory StudyRoom.fromMap(String id, Map<String, dynamic> data) {
    return StudyRoom(
      id: id,
      name: data['name'] as String? ?? '',
      building: data['building'] as String? ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      occupiedSeats: (data['occupiedSeats'] as num?)?.toInt() ?? 0,
      isOpen: data['isOpen'] as bool? ?? true,
      updatedAt: _dateFrom(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'building': building,
      'capacity': capacity,
      'occupiedSeats': occupiedSeats,
      'isOpen': isOpen,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

DateTime _dateFrom(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
