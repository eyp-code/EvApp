import '../models/task_item.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getTasks();

  Future<void> addTask(TaskItem task);

  Future<void> updateTask(TaskItem task);

  Future<void> toggleCompleted(String taskId);

  Future<void> deleteTask(String taskId);
}
