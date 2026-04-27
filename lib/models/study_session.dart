import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String id;
  final String groupId;
  final String title;
  final String createdBy;
  final List<String> participantIds;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final bool reminderQueued;
  final DateTime createdAt;

  const StudySession({
    required this.id,
    required this.groupId,
    required this.title,
    required this.createdBy,
    required this.participantIds,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.reminderQueued = false,
    required this.createdAt,
  });

  factory StudySession.fromMap(String id, Map<String, dynamic> data) {
    return StudySession(
      id: id,
      groupId: data['groupId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      participantIds: List<String>.from(data['participantIds'] ?? const []),
      startTime: _dateFrom(data['startTime']),
      endTime: _dateFrom(data['endTime']),
      location: data['location'] as String? ?? '',
      reminderQueued: data['reminderQueued'] as bool? ?? false,
      createdAt: _dateFrom(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'title': title.trim(),
      'createdBy': createdBy,
      'participantIds': participantIds,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location.trim(),
      'reminderQueued': reminderQueued,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

DateTime _dateFrom(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}