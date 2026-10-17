import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_app/models/report_stats.dart';
import 'package:task_tracking_app/models/task_model.dart';
import 'package:task_tracking_app/models/user_model.dart';

void main() {
  final intern = UserModel(
    uid: 'intern-1',
    name: 'Ayesha Khan',
    email: 'ayesha@example.com',
    role: 'intern',
    createdAt: DateTime(2026, 1, 1),
  );
  final otherIntern = UserModel(
    uid: 'intern-2',
    name: 'Bilal Ali',
    email: 'bilal@example.com',
    role: 'intern',
    createdAt: DateTime(2026, 1, 1),
  );

  TaskModel task({
    required String id,
    required DateTime dueDate,
    required DateTime createdAt,
    String status = 'pending',
    DateTime? completedAt,
    String assignedTo = 'intern-1',
  }) => TaskModel(
    id: id,
    title: id,
    description: '',
    assignedTo: assignedTo,
    assignedBy: 'admin-1',
    createdBy: 'admin-1',
    status: status,
    dueDate: dueDate,
    createdAt: createdAt,
    completedAt: completedAt,
  );

  group('ReportPeriodX', () {
    final now = DateTime(2026, 10, 11, 14);

    test('filters weekly, monthly, and all-time tasks by creation date', () {
      final tasks = [
        task(
          id: 'before-week',
          dueDate: DateTime(2026, 10, 10),
          createdAt: DateTime(2026, 10, 4, 23, 59),
        ),
        task(
          id: 'start-week',
          dueDate: DateTime(2026, 10, 10),
          createdAt: DateTime(2026, 10, 5),
        ),
        task(
          id: 'start-month',
          dueDate: DateTime(2026, 10, 10),
          createdAt: DateTime(2026, 10, 1),
        ),
      ];

      expect(ReportPeriod.week.filterTasks(tasks, now: now).map((t) => t.id), [
        'start-week',
      ]);
      expect(ReportPeriod.month.filterTasks(tasks, now: now).map((t) => t.id), [
        'before-week',
        'start-week',
        'start-month',
      ]);
      expect(ReportPeriod.all.filterTasks(tasks, now: now), tasks);
    });
  });

  group('TaskReportX', () {
    test('counts completion through the end of the due date as on time', () {
      final dueDate = DateTime(2026, 10, 10);
      final onTimeTask = task(
        id: 'on-time',
        dueDate: dueDate,
        createdAt: DateTime(2026, 10, 1),
        status: 'completed',
        completedAt: DateTime(2026, 10, 10, 23, 59, 59, 999),
      );
      final lateTask = task(
        id: 'late',
        dueDate: dueDate,
        createdAt: DateTime(2026, 10, 1),
        status: 'completed',
        completedAt: DateTime(2026, 10, 11),
      );

      expect(onTimeTask.isDoneOnTime, isTrue);
      expect(lateTask.isDoneOnTime, isFalse);
      expect(
        task(
          id: 'overdue',
          dueDate: dueDate,
          createdAt: DateTime(2026, 10, 1),
        ).isOverdueAt(DateTime(2026, 10, 11)),
        isTrue,
      );
      expect(
        task(
          id: 'not-overdue',
          dueDate: dueDate,
          createdAt: DateTime(2026, 10, 1),
        ).isOverdueAt(DateTime(2026, 10, 10, 23, 59, 59)),
        isFalse,
      );
    });
  });

  group('buildInternStats', () {
    test('calculates rates, late tasks, overdue tasks, and score', () {
      final tasks = [
        task(
          id: 'on-time',
          dueDate: DateTime(2026, 10, 8),
          createdAt: DateTime(2026, 10, 1),
          status: 'completed',
          completedAt: DateTime(2026, 10, 8, 12),
        ),
        task(
          id: 'late',
          dueDate: DateTime(2026, 10, 8),
          createdAt: DateTime(2026, 10, 1),
          status: 'completed',
          completedAt: DateTime(2026, 10, 9),
        ),
        task(
          id: 'overdue',
          dueDate: DateTime(2026, 10, 8),
          createdAt: DateTime(2026, 10, 1),
        ),
        task(
          id: 'other-intern',
          dueDate: DateTime(2026, 10, 8),
          createdAt: DateTime(2026, 10, 1),
          assignedTo: 'intern-2',
        ),
      ];

      final stats = buildInternStats(
        [intern, otherIntern],
        tasks,
        now: DateTime(2026, 10, 11),
      );
      final internStats = stats.first;

      expect(internStats.total, 3);
      expect(internStats.completed, 2);
      expect(internStats.onTime, 1);
      expect(internStats.late, 1);
      expect(internStats.overdue, 1);
      expect(internStats.completionRate, closeTo(2 / 3, 0.0001));
      expect(internStats.onTimeRate, 0.5);
      expect(internStats.score, closeTo(60, 0.0001));
      expect(stats.last.score, 0);
    });
  });
}
