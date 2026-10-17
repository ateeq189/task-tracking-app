import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({
    super.key,
    required this.admin,
    this.task,
    this.assignedTo,
  });

  final UserModel admin;
  final TaskModel? task;
  final String? assignedTo;

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskService = TaskService();
  late final Stream<List<UserModel>> _interns;
  late DateTime _dueDate;
  late String _priority;
  late String? _selectedInternUid;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _interns = UserService().interns();
    _titleController.text = task?.title ?? '';
    _descriptionController.text = task?.description ?? '';
    _dueDate =
        task?.dueDate ??
        DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1)));
    _priority = task?.priority ?? 'medium';
    _selectedInternUid = task?.assignedTo ?? widget.assignedTo;
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = DateUtils.dateOnly(picked));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final assignedTo = _selectedInternUid;
    if (assignedTo == null) return;

    setState(() => _isSaving = true);
    final current = widget.task;
    final task = TaskModel(
      id: current?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      assignedTo: assignedTo,
      assignedBy: current?.assignedBy ?? widget.admin.uid,
      createdBy: current?.createdBy ?? widget.admin.uid,
      status: current?.status ?? 'pending',
      priority: _priority,
      dueDate: _dueDate,
      createdAt: current?.createdAt ?? DateTime.now(),
      completedAt: current?.completedAt,
    );

    try {
      if (current == null) {
        await _taskService.addTask(task);
      } else {
        await _taskService.updateTask(task);
      }
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task ${current == null ? 'assign' : 'update'} nahi hua: $error',
          ),
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.task == null ? 'Assign Task' : 'Edit Task'),
    ),
    body: StreamBuilder<List<UserModel>>(
      stream: _interns,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Interns load nahi ho sake: ${snapshot.error}'),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final interns = snapshot.data ?? const <UserModel>[];
        final selectedInternIsAvailable = interns.any(
          (intern) => intern.uid == _selectedInternUid,
        );
        final selectedIntern = selectedInternIsAvailable
            ? _selectedInternUid
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedIntern,
                  decoration: const InputDecoration(
                    labelText: 'Assign to intern',
                    border: OutlineInputBorder(),
                  ),
                  items: interns
                      .map(
                        (intern) => DropdownMenuItem(
                          value: intern.uid,
                          child: Text(
                            intern.name.isEmpty ? intern.email : intern.name,
                          ),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Select an intern' : null,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedInternUid = value);
                          }
                        },
                ),
                if (interns.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Abhi koi intern account available nahi hai.'),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) setState(() => _priority = value);
                        },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _isSaving ? null : _pickDueDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(_dueDate)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _isSaving || interns.isEmpty ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.task == null
                                ? 'Assign Task'
                                : 'Save Changes',
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
