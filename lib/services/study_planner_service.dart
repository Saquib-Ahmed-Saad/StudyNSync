import '../models/study_plan_item.dart';
import '../models/study_task.dart';

class StudyPlannerService {
  int calculatePriorityScore(StudyTask task, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final daysUntilDue = task.deadline.difference(reference).inDays;

    final urgencyScore = switch (daysUntilDue) {
      <= 0 => 60,
      1 => 50,
      <= 3 => 40,
      <= 7 => 30,
      <= 14 => 20,
      _ => 10,
    };

    final effortScore = (task.estimatedHours * 5).round().clamp(0, 25);
    final weightScore = (task.courseWeight * 2).clamp(0, 20);

    return (urgencyScore + effortScore + weightScore).clamp(0, 100);
  }

  String explainPriority(StudyTask task, int score, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final daysUntilDue = task.deadline.difference(reference).inDays;

    return '${task.courseCode} scored $score because it is due in $daysUntilDue day(s), '
        'needs ${task.estimatedHours.toStringAsFixed(1)} hour(s), '
        'and has course weight ${task.courseWeight}/10.';
  }

  List<StudyTask> prioritizeTasks(List<StudyTask> tasks, {DateTime? now}) {
    final scored = tasks
        .where((task) => task.status != TaskStatus.done)
        .map(
          (task) => task.copyWith(
            priorityScore: calculatePriorityScore(task, now: now),
          ),
        )
        .toList();

    scored.sort((a, b) {
      final scoreCompare = b.priorityScore.compareTo(a.priorityScore);
      if (scoreCompare != 0) return scoreCompare;
      return a.deadline.compareTo(b.deadline);
    });

    return scored;
  }

  List<StudyPlanItem> generateWeeklyPlan({
    required List<StudyTask> tasks,
    DateTime? weekStart,
    int studyStartHour = 9,
    double dailyAvailableHours = 3,
  }) {
    if (dailyAvailableHours <= 0) {
      throw ArgumentError('dailyAvailableHours must be greater than zero.');
    }

    final start = _startOfDay(weekStart ?? DateTime.now());
    final prioritized = prioritizeTasks(tasks, now: start);
    final result = <StudyPlanItem>[];
    final usedHoursByDate = <DateTime, double>{};

    for (final task in prioritized) {
      var remaining = task.estimatedHours;
      var scheduledAny = false;

      for (var dayOffset = 0; dayOffset < 7 && remaining > 0; dayOffset++) {
        final date = start.add(Duration(days: dayOffset));
        final dayKey = _startOfDay(date);
        final used = usedHoursByDate[dayKey] ?? 0;
        final available = dailyAvailableHours - used;

        if (available <= 0) continue;

        final hoursForBlock = remaining < available ? remaining : available;

        final startTime = dayKey.add(
          Duration(
            hours: studyStartHour,
            minutes: (used * 60).round(),
          ),
        );

        final endTime = startTime.add(
          Duration(minutes: (hoursForBlock * 60).round()),
        );

        final isLate = endTime.isAfter(task.deadline);

        result.add(
          StudyPlanItem(
            id: '${task.id}-$dayOffset',
            taskId: task.id,
            taskTitle: task.title,
            courseCode: task.courseCode,
            startTime: startTime,
            endTime: endTime,
            priorityScore: task.priorityScore,
            recommendationReason: explainPriority(
              task,
              task.priorityScore,
              now: start,
            ),
            hasConflict: isLate,
            adjustmentSuggestion: isLate
                ? 'Move this task earlier or reduce other lower-priority blocks because the scheduled time passes the deadline.'
                : '',
          ),
        );

        usedHoursByDate[dayKey] = used + hoursForBlock;
        remaining -= hoursForBlock;
        scheduledAny = true;
      }

      if (!scheduledAny || remaining > 0) {
        result.add(
          StudyPlanItem(
            id: '${task.id}-unscheduled',
            taskId: task.id,
            taskTitle: task.title,
            courseCode: task.courseCode,
            startTime: start.add(const Duration(days: 6, hours: 18)),
            endTime: start.add(const Duration(days: 6, hours: 19)),
            priorityScore: task.priorityScore,
            recommendationReason: explainPriority(
              task,
              task.priorityScore,
              now: start,
            ),
            hasConflict: true,
            adjustmentSuggestion:
                'Not enough weekly study capacity. Add more study time or split this task into smaller pieces.',
          ),
        );
      }
    }

    result.sort((a, b) => a.startTime.compareTo(b.startTime));

    return result;
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}