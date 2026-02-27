import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../model/task_model.dart';
import '../provider/task_provider.dart';
import '../utils/app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();
  final uuid = Uuid();
  String status = 'pending';
  bool isLoading = false;

  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.description;
      dueDateController.text = widget.task!.dueDate;
      status = widget.task!.status;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => isLoading = true);

    final task = Task(
      id: isEdit ? widget.task!.id : uuid.v4(),
      name: titleController.text.trim(),
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      status: status,
      dueDate: dueDateController.text,
    );

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (isEdit) {
        await taskProvider.updateTask(task);
      } else {
        await taskProvider.addTask(task);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Task updated successfully' : 'Task added successfully',
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? "Couldn't update task" : "Couldn't add task"),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final initialDate = dueDateController.text.isNotEmpty
        ? DateTime.tryParse(dueDateController.text) ?? DateTime.now()
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: AppTheme.surface,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      dueDateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppTheme.textSecondary,
      letterSpacing: 0.2,
    ),
  );

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
      filled: true,
      fillColor: AppTheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        borderSide: BorderSide(color: AppTheme.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        borderSide: BorderSide(color: AppTheme.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        borderSide: const BorderSide(color: AppTheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        borderSide: const BorderSide(color: AppTheme.error, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
        ),
        leadingWidth: 80,
        centerTitle: true,
        title: Text(
          isEdit ? 'Edit Task' : 'New Task',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  )
                : Text(
                    isEdit ? 'Update' : 'Done',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: AppTheme.divider, height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          children: [
            _label('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              decoration: _fieldDecoration('Enter task title'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Title required' : null,
            ),
            const SizedBox(height: 24),
            _label('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: descriptionController,
              maxLines: 5,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              decoration: _fieldDecoration('Enter task description'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Description required' : null,
            ),
            const SizedBox(height: 24),
            _label('Due date'),
            const SizedBox(height: 8),
            TextFormField(
              controller: dueDateController,
              readOnly: true,
              onTap: _pickDate,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              decoration: _fieldDecoration('Select date').copyWith(
                suffixIcon: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppTheme.primary,
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Select due date' : null,
            ),
            const SizedBox(height: 32),
            Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 32),
            _label('Status'),
            const SizedBox(height: 12),
            Row(
              children: ['pending', 'completed'].map((s) {
                final isSelected = status == s;
                final activeColor = s == 'completed'
                    ? AppTheme.primary
                    : const Color(0xFFFF9800);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: s == 'pending' ? 8 : 0,
                        left: s == 'completed' ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? activeColor
                            : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: isSelected
                            ? null
                            : Border.all(color: AppTheme.divider, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            s == 'completed'
                                ? Icons.check_circle_outline_rounded
                                : Icons.schedule_rounded,
                            size: 16,
                            color: isSelected
                                ? Colors.black
                                : AppTheme.textHint,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s[0].toUpperCase() + s.substring(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.black
                                  : AppTheme.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit ? 'Update Task' : 'Add Task',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
