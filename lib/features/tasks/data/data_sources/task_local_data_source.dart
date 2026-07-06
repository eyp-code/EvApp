import 'package:hive/hive.dart';

import '../../domain/models/task_item.dart';

class TaskLocalDataSource {
  const TaskLocalDataSource(this._box);

  final Box<Map> _box;

  Future<List<TaskItem>> getTasks() async {
    final tasks = _box.values
        .map((value) => TaskItem.fromJson(Map<String, dynamic>.from(value)))
        .where((task) => !task.isDeleted)
        .toList();

    tasks.sort((first, second) {
      if (first.isCompleted != second.isCompleted) {
        return first.isCompleted ? 1 : -1;
      }

      final dueDateA = first.dueDate;
      final dueDateB = second.dueDate;
      if (dueDateA != null && dueDateB != null) {
        final dueComparison = dueDateA.compareTo(dueDateB);
        if (dueComparison != 0) {
          return dueComparison;
        }
      } else if (dueDateA != null) {
        return -1;
      } else if (dueDateB != null) {
        return 1;
      }

      return second.createdAt.compareTo(first.createdAt);
    });

    return tasks;
  }

  Future<void> saveTask(TaskItem task) async {
    await _box.put(task.id, task.toJson());
  }

  Future<TaskItem?> getTaskById(String id) async {
    final value = _box.get(id);
    if (value == null) {
      return null;
    }

    return TaskItem.fromJson(Map<String, dynamic>.from(value));
  }
}
