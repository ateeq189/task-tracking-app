import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_app/models/task_model.dart';

void main() {
  group('TaskModel', () {
    test('uses the document ID and round-trips task fields', () {
      final dueDate = DateTime.utc(2026, 10, 12);
      final createdAt = DateTime.utc(2026, 10, 10, 8);
      final completedAt = DateTime.utc(2026, 10, 11, 15);
      final task = TaskModel(
        id: 'task-1',
        title: 'Prepare report',
        description: 'Summarize this week',
        assignedTo: 'intern-1',
        assignedBy: 'admin-1',
        createdBy: 'admin-1',
        status: 'completed',
        priority: 'high',
        dueDate: dueDate,
        createdAt: createdAt,
        completedAt: completedAt,
      );

      final data = task.toMap();
      final restored = TaskModel.fromMap(data, task.id);

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.description, task.description);
      expect(restored.assignedTo, task.assignedTo);
      expect(restored.assignedBy, task.assignedBy);
      expect(restored.createdBy, task.createdBy);
      expect(restored.status, 'completed');
      expect(restored.priority, 'high');
      expect(restored.dueDate, dueDate);
      expect(restored.createdAt, createdAt);
      expect(restored.completedAt, completedAt);
      expect(data, isNot(contains('id')));
      expect(data['dueDate'], isA<Timestamp>());
      expect(data['completedAt'], isA<Timestamp>());
    });

    test(
      'uses default status and priority and allows null completion time',
      () {
        final task = TaskModel(
          id: 'task-2',
          title: 'Review design',
          description: '',
          assignedTo: 'intern-1',
          assignedBy: 'admin-1',
          createdBy: 'admin-1',
          dueDate: DateTime.utc(2026, 10, 12),
          createdAt: DateTime.utc(2026, 10, 10),
        );

        final restored = TaskModel.fromMap(task.toMap(), task.id);

        expect(task.status, 'pending');
        expect(task.priority, 'medium');
        expect(restored.status, 'pending');
        expect(restored.priority, 'medium');
        expect(restored.completedAt, isNull);
        expect(task.toMap()['completedAt'], isNull);
      },
    );

    test('defaults missing optional text fields', () {
      final task = TaskModel.fromMap({
        'dueDate': Timestamp.fromDate(DateTime.utc(2026, 10, 12)),
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 10, 10)),
      }, 'task-3');

      expect(task.id, 'task-3');
      expect(task.title, isEmpty);
      expect(task.description, isEmpty);
      expect(task.assignedTo, isEmpty);
      expect(task.assignedBy, isEmpty);
      expect(task.createdBy, isEmpty);
      expect(task.status, 'pending');
      expect(task.priority, 'medium');
    });
  });
}
