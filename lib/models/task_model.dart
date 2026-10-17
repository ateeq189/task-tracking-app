import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedTo; // intern uid
  final String assignedBy; // admin uid (or the intern for self-created tasks)
  final String createdBy;
  final String status; // pending / in_progress / completed
  final String priority; // low / medium / high
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  DateTime get deadline => dueDate;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedBy,
    String? createdBy,
    this.status = 'pending',
    this.priority = 'medium',
    required this.dueDate,
    required this.createdAt,
    this.completedAt,
  }) : createdBy = createdBy ?? assignedBy;

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      assignedBy: map['assignedBy'] ?? '',
      createdBy: map['createdBy'] ?? map['assignedBy'] ?? '',
      status: map['status'] ?? 'pending',
      priority: map['priority'] ?? 'medium',
      dueDate:
          (map['dueDate'] as Timestamp?)?.toDate().toUtc() ??
          DateTime.now().toUtc(),
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate().toUtc() ??
          DateTime.now().toUtc(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate().toUtc(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'createdBy': createdBy,
      'status': status,
      'priority': priority,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }
}
