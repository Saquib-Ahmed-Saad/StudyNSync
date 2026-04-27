import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroup {
  final String id;
  final String name;
  final String courseCode;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.courseCode,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyGroup.fromMap(String id, Map<String, dynamic> data) {
    return StudyGroup(
      id: id,
      name: data['name'] as String? ?? '',
      courseCode: data['courseCode'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? const []),
      createdAt: _dateFrom(data['createdAt']),
      updatedAt: _dateFrom(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'courseCode': courseCode.trim().toUpperCase(),
      'ownerId': ownerId,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
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
