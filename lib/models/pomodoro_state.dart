import 'package:cloud_firestore/cloud_firestore.dart';

enum TimerMode { focus, shortBreak, longBreak }

enum TimerRunState { idle, running, paused }

class PomodoroState {
  final String groupId;
  final TimerMode mode;
  final TimerRunState runState;
  final int totalSeconds;
  final int remainingSeconds;
  final String controlledBy;
  final DateTime updatedAt;

  const PomodoroState({
    required this.groupId,
    this.mode = TimerMode.focus,
    this.runState = TimerRunState.idle,
    this.totalSeconds = 1500,
    this.remainingSeconds = 1500,
    this.controlledBy = '',
    required this.updatedAt,
  });

  factory PomodoroState.fromMap(String groupId, Map<String, dynamic> data) {
    return PomodoroState(
      groupId: groupId,
      mode: _modeFrom(data['mode']),
      runState: _runStateFrom(data['runState']),
      totalSeconds: (data['totalSeconds'] as num?)?.toInt() ?? 1500,
      remainingSeconds: (data['remainingSeconds'] as num?)?.toInt() ?? 1500,
      controlledBy: data['controlledBy'] as String? ?? '',
      updatedAt: _dateFrom(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mode': mode.name,
      'runState': runState.name,
      'totalSeconds': totalSeconds,
      'remainingSeconds': remainingSeconds,
      'controlledBy': controlledBy,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

TimerMode _modeFrom(dynamic value) {
  if (value == TimerMode.shortBreak.name) return TimerMode.shortBreak;
  if (value == TimerMode.longBreak.name) return TimerMode.longBreak;
  return TimerMode.focus;
}

TimerRunState _runStateFrom(dynamic value) {
  if (value == TimerRunState.running.name) return TimerRunState.running;
  if (value == TimerRunState.paused.name) return TimerRunState.paused;
  return TimerRunState.idle;
}

DateTime _dateFrom(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}