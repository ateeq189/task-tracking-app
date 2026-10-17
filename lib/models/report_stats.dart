import 'task_model.dart';
import 'user_model.dart';

enum ReportPeriod { week, month, all }

extension ReportPeriodX on ReportPeriod {
  String get label {
    switch (this) {
      case ReportPeriod.week:
        return 'Last 7 days';
      case ReportPeriod.month:
        return 'This month';
      case ReportPeriod.all:
        return 'All time';
    }
  }

  /// Tasks created on/after this date are included (null = everything).
  DateTime? startDateAt(DateTime now) {
    switch (this) {
      case ReportPeriod.week:
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
      case ReportPeriod.month:
        return DateTime(now.year, now.month, 1);
      case ReportPeriod.all:
        return null;
    }
  }

  DateTime? get startDate => startDateAt(DateTime.now());

  List<TaskModel> filterTasks(List<TaskModel> tasks, {DateTime? now}) {
    final start = startDateAt(now ?? DateTime.now());
    return start == null
        ? tasks
        : tasks.where((task) => !task.createdAt.isBefore(start)).toList();
  }
}

extension TaskReportX on TaskModel {
  DateTime get deadlineExclusive =>
      DateTime(dueDate.year, dueDate.month, dueDate.day + 1);

  bool get isOverdue => isOverdueAt(DateTime.now());

  bool isOverdueAt(DateTime now) =>
      status != 'completed' && !now.isBefore(deadlineExclusive);

  bool get isDoneOnTime {
    final done = completedAt;
    if (status != 'completed' || done == null) return false;
    return done.isBefore(deadlineExclusive);
  }
}

class InternStats {
  final UserModel intern;
  final int total;
  final int completed;
  final int onTime;
  final int overdue;

  InternStats({
    required this.intern,
    required this.total,
    required this.completed,
    required this.onTime,
    required this.overdue,
  });

  int get late => completed - onTime;
  double get completionRate => total == 0 ? 0 : completed / total;
  double get onTimeRate => completed == 0 ? 0 : onTime / completed;

  /// Score (0-100) = 60% completion + 40% on-time.
  double get score => (completionRate * 0.6 + onTimeRate * 0.4) * 100;
}

List<InternStats> buildInternStats(
  List<UserModel> interns,
  List<TaskModel> tasks, {
  DateTime? now,
}) {
  final currentTime = now ?? DateTime.now();
  return interns.map((u) {
    final mine = tasks.where((t) => t.assignedTo == u.uid).toList();
    final done = mine.where((t) => t.status == 'completed').toList();
    return InternStats(
      intern: u,
      total: mine.length,
      completed: done.length,
      onTime: done.where((t) => t.isDoneOnTime).length,
      overdue: mine.where((t) => t.isOverdueAt(currentTime)).length,
    );
  }).toList();
}
