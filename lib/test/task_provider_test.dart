import 'package:flowly/provider/task_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../model/task_model.dart';

void main() {
  late TaskProvider taskProvider;

  setUp(() {
    taskProvider = TaskProvider();
  });

  group('TaskProvider', () {
    test('initial tasks list should be empty', () {
      expect(taskProvider.tasks, []);
    });

    test('addTask should add a task', () async {
      final task = Task(id: '1', name: 'Test', title: 'Test', description: 'Desc', status: 'pending', dueDate: '2026-02-27');
      await taskProvider.addTask(task);
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks.first.title, 'Test');
    });
  });
}