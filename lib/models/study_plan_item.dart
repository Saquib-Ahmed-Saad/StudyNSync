import 'package:cloud_firestore/cloud_firestore.dart';

class StudyPlanItem {
  final String id;
  final String taskId;
  final String taskTitle;
  final String courseCode;
  final DateTime startTime;
  final DateTime endTime;
  final int priorityScore;
  final String recommendationReason;
  final bool hasConflict;
  final String adjustmentSuggestion;

  const StudyPlanItem({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.courseCode,
    required this.startTime,
    required this.endTime,
    required this.priorityScore,
    required this.recommendationReason,
    this.hasConflict = false,
    this.adjustmentSuggestion = '',
  });

  factory StudyPlanItem.fromMap(String id, Map<String, dynamic> data) {
    return StudyPlanItem(
      id: id,
      taskId: data['taskId'] as String? ?? '',
      taskTitle: data['taskTitle'] as String? ?? '',
      courseCode: data['courseCode'] as String? ?? '',
      startTime: _dateFrom(data['startTime']),
      endTime: _dateFrom(data['endTime']),
      priorityScore: (data['priorityScore'] as num?)?.toInt() ?? 0,
      recommendationReason: data['recommendationReason'] as String? ?? '',
      hasConflict: data['hasConflict'] as bool? ?? false,
      adjustmentSuggestion: data['adjustmentSuggestion'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'taskTitle': taskTitle,
      'courseCode': courseCode,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'priorityScore': priorityScore,
      'recommendationReason': recommendationReason,
      'hasConflict': hasConflict,
      'adjustmentSuggestion': adjustmentSuggestion,
    };
  }
}

DateTime _dateFrom(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
