import 'package:flutter_test/flutter_test.dart';

import '../lib/models/study_task.dart';
import '../lib/services/study_planner_service.dart';

void main() {
  group('StudyPlannerService', () {
    late StudyPlannerService planner;
    late DateTime now;

    setUp(() {
      planner = StudyPlannerService();
      now = DateTime(2026, 4, 27, 9);
    });

    test('prioritizes urgent, high-effort, high-weight tasks first', () {
      final easyLater = StudyTask(
        id: 'easy-later',
        userId: 'u1',
        title: 'Easy reading',
        courseCode: 'CSC4360',
        deadline: now.add(const Duration(days: 10)),
        estimatedHours: 1,
        courseWeight: 3,
        createdAt: now,
        updatedAt: now,
      );

      final urgentMajor = StudyTask(
        id: 'urgent-major',
        userId: 'u1',
        title: 'Final project backend',
        courseCode: 'CSC4360',
        deadline: now.add(const Duration(days: 1)),
        estimatedHours: 4,
        courseWeight: 9,
        createdAt: now,
        updatedAt: now,
      );

      final sorted = planner.prioritizeTasks(
        [easyLater, urgentMajor],
        now: now,
      );

      expect(sorted.first.id, 'urgent-major');
      expect(sorted.first.priorityScore, greaterThan(sorted.last.priorityScore));
    });

    test('does not schedule completed tasks', () {
      final doneTask = StudyTask(
        id: 'done',
        userId: 'u1',
        title: 'Already finished',
        courseCode: 'CSC4360',
        deadline: now.add(const Duration(days: 2)),
        estimatedHours: 2,
        courseWeight: 5,
        status: TaskStatus.done,
        createdAt: now,
        updatedAt: now,
      );

      final sorted = planner.prioritizeTasks(
        [doneTask],
        now: now,
      );

      expect(sorted, isEmpty);
    });

    test('generates a weekly plan with conflict suggestions when capacity is too low', () {
      final heavyTask = StudyTask(
        id: 'heavy',
        userId: 'u1',
        title: 'Large project',
        courseCode: 'CSC4360',
        deadline: now.add(const Duration(days: 1)),
        estimatedHours: 30,
        courseWeight: 10,
        createdAt: now,
        updatedAt: now,
      );

      final plan = planner.generateWeeklyPlan(
        tasks: [heavyTask],
        weekStart: now,
        dailyAvailableHours: 2,
      );

      expect(plan, isNotEmpty);
      expect(plan.any((item) => item.hasConflict), isTrue);
      expect(
        plan.any((item) => item.adjustmentSuggestion.isNotEmpty),
        isTrue,
      );
    });
  });
}