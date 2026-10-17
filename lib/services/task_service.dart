import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class TaskService {
  final CollectionReference<Map<String, dynamic>> _tasks = FirebaseFirestore
      .instance
      .collection('tasks');

  Future<void> addTask(TaskModel task) async {
    await _tasks.add(task.toMap());
  }

  /// Tasks of one intern (real-time). Sorted in Dart to avoid a Firestore index.
  Stream<List<TaskModel>> internTasks(String uid) {
    return _tasks.where('assignedTo', isEqualTo: uid).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => TaskModel.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// All tasks (admin).
  Stream<List<TaskModel>> allTasks() {
    return _tasks.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => TaskModel.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await _tasks.doc(id).update({
      'status': status,
      'completedAt': status == 'completed' ? Timestamp.now() : null,
    });
  }

  /// Edit task details (status / completedAt are not touched).
  Future<void> updateTask(TaskModel task) async {
    await _tasks.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'assignedTo': task.assignedTo,
      'priority': task.priority,
      'dueDate': Timestamp.fromDate(task.dueDate),
    });
  }

  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }
}
