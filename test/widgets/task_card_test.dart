import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_app/models/task_model.dart';
import 'package:task_tracking_app/widgets/task_card.dart';

void main() {
  testWidgets('shows task details and reports selected status', (
    WidgetTester tester,
  ) async {
    final statuses = <String>[];
    var wasTapped = false;
    final task = TaskModel(
      id: 'task-1',
      title: 'Prepare report',
      description: 'Summarize this week',
      assignedTo: 'intern-1',
      assignedBy: 'intern-1',
      createdBy: 'intern-1',
      dueDate: DateTime(2026, 10, 12),
      createdAt: DateTime(2026, 10, 10),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onStatusChanged: statuses.add,
            onTap: () => wasTapped = true,
            extraInfo: 'Assigned to: intern-1',
          ),
        ),
      ),
    );

    expect(find.text('Prepare report'), findsOneWidget);
    expect(find.text('Summarize this week'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Assigned to: intern-1'), findsOneWidget);

    await tester.tap(find.text('Prepare report'));
    expect(wasTapped, isTrue);

    await tester.tap(find.byTooltip('Task actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('In Progress').last);
    await tester.pumpAndSettle();

    expect(statuses, ['in_progress']);
  });

  testWidgets('only shows delete when a delete callback is supplied', (
    WidgetTester tester,
  ) async {
    final task = TaskModel(
      id: 'task-2',
      title: 'Review design',
      description: '',
      assignedTo: 'intern-1',
      assignedBy: 'intern-1',
      createdBy: 'intern-1',
      dueDate: DateTime(2026, 10, 12),
      createdAt: DateTime(2026, 10, 10),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(task: task, onStatusChanged: (_) {}),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Task actions'));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsNothing);
  });
}
