import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { todo, inProgress, done }

class StudyTask {
  final String id;
  final String userId;
  final String title;
  final String courseCode;
  final DateTime deadline;
  final double estimatedHours;
  final int courseWeight;
  final int priorityScore;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.courseCode,
    required this.deadline,
    required this.estimatedHours,
    required this.courseWeight,
    this.priorityScore = 0,
    this.status = TaskStatus.todo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyTask.empty(String userId) {
    final now = DateTime.now();
    return StudyTask(
      id: '',
      userId: userId,
      title: '',
      courseCode: '',
      deadline: now.add(const Duration(days: 7)),
      estimatedHours: 1,
      courseWeight: 1,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory StudyTask.fromMap(String id, Map<String, dynamic> data) {
    return StudyTask(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      courseCode: data['courseCode'] as String? ?? '',
      deadline: _dateFrom(data['deadline']),
      estimatedHours: (data['estimatedHours'] as num?)?.toDouble() ?? 1.0,
      courseWeight: (data['courseWeight'] as num?)?.toInt() ?? 1,
      priorityScore: (data['priorityScore'] as num?)?.toInt() ?? 0,
      status: _statusFrom(data['status']),
      createdAt: _dateFrom(data['createdAt']),
      updatedAt: _dateFrom(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title.trim(),
      'courseCode': courseCode.trim().toUpperCase(),
      'deadline': Timestamp.fromDate(deadline),
      'estimatedHours': estimatedHours,
      'courseWeight': courseWeight,
      'priorityScore': priorityScore,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  StudyTask copyWith({
    String? id,
    String? userId,
    String? title,
    String? courseCode,
    DateTime? deadline,
    double? estimatedHours,
    int? courseWeight,
    int? priorityScore,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyTask(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      courseCode: courseCode ?? this.courseCode,
      deadline: deadline ?? this.deadline,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      courseWeight: courseWeight ?? this.courseWeight,
      priorityScore: priorityScore ?? this.priorityScore,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

TaskStatus _statusFrom(dynamic value) {
  if (value == TaskStatus.inProgress.name) return TaskStatus.inProgress;
  if (value == TaskStatus.done.name) return TaskStatus.done;
  return TaskStatus.todo;
}

DateTime _dateFrom(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
