import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import 'common.dart';

/// One form for three jobs:
///  * admin assigns a task      -> pass [interns]
///  * admin edits a task        -> pass [interns] and [task]
///  * intern adds personal task -> leave [interns] null
class TaskForm extends StatefulWidget {
  final UserModel currentUser;
  final List<UserModel>? interns;
  final TaskModel? task;
  final String submitLabel;
  final IconData submitIcon;
  final VoidCallback? onSaved;

  const TaskForm({
    super.key,
    required this.currentUser,
    this.interns,
    this.task,
    required this.submitLabel,
    this.submitIcon = Icons.add,
    this.onSaved,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  String? _internId;
  late String _priority;
  late DateTime _dueDate;
  bool _loading = false;
  int _resetCount = 0;

  bool get _isEdit => widget.task != null;
  bool get _assignMode => widget.interns != null;

  static DateTime _tomorrow() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day + 1);
  }

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _internId = t?.assignedTo;
    _priority = t?.priority ?? 'medium';
    _dueDate = t?.dueDate ?? _tomorrow();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final first = _dueDate.isBefore(today) ? _dueDate : today;
    var last = today.add(const Duration(days: 730));
    if (_dueDate.isAfter(last)) last = _dueDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);

    try {
      final service = TaskService();
      final assignTo = _assignMode ? _internId! : widget.currentUser.uid;

      if (_isEdit) {
        final old = widget.task!;
        await service.updateTask(
          TaskModel(
            id: old.id,
            title: _title.text.trim(),
            description: _description.text.trim(),
            assignedTo: assignTo,
            assignedBy: old.assignedBy,
            status: old.status,
            priority: _priority,
            dueDate: _dueDate,
            createdAt: old.createdAt,
            completedAt: old.completedAt,
          ),
        );
        showToastOn(messenger, 'Task updated successfully');
        widget.onSaved?.call();
      } else {
        await service.addTask(
          TaskModel(
            id: '',
            title: _title.text.trim(),
            description: _description.text.trim(),
            assignedTo: assignTo,
            assignedBy: widget.currentUser.uid,
            priority: _priority,
            dueDate: _dueDate,
            createdAt: DateTime.now(),
          ),
        );
        showToastOn(
          messenger,
          _assignMode
              ? 'Task assigned successfully!'
              : 'Task added successfully!',
        );
        if (mounted) {
          _formKey.currentState?.reset();
          _title.clear();
          _description.clear();
          setState(() {
            _internId = null;
            _priority = 'medium';
            _dueDate = _tomorrow();
            _resetCount++;
          });
        }
        widget.onSaved?.call();
      }
    } catch (e) {
      showToastOn(messenger, 'Failed to save task: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabeledField(
            label: 'Task Title',
            child: TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [LengthLimitingTextInputFormatter(80)],
              decoration: const InputDecoration(hintText: 'Enter task title'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Description',
            child: TextFormField(
              controller: _description,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Enter task description',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter a description'
                  : null,
            ),
          ),
          if (_assignMode) ...[
            const SizedBox(height: 16),
            LabeledField(
              label: 'Assign To',
              child: DropdownButtonFormField<String>(
                key: ValueKey('assignee-$_resetCount'),
                initialValue: widget.interns!.any((u) => u.uid == _internId)
                    ? _internId
                    : null,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                hint: const Text(
                  'Select an intern',
                  style: TextStyle(color: AppColors.hint),
                ),
                items: [
                  for (final u in widget.interns!)
                    DropdownMenuItem(
                      value: u.uid,
                      child: Text(u.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => _internId = v),
                validator: (v) => v == null ? 'Select an intern' : null,
              ),
            ),
          ],
          const SizedBox(height: 16),
          LabeledField(
            label: 'Priority',
            child: PillToggle<String>(
              selected: _priority,
              onChanged: (v) => setState(() => _priority = v),
              options: const [
                PillOption('low', 'Low'),
                PillOption('medium', 'Medium'),
                PillOption('high', 'High'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Due Date',
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.textSoft,
                  ),
                ),
                child: Text(
                  DateFormat('MMM d, yyyy').format(_dueDate),
                  style: const TextStyle(fontSize: 16, color: AppColors.text),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.submitIcon, size: 20),
                      const SizedBox(width: 8),
                      Text(widget.submitLabel),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
