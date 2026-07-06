import '../../domain/models/task_item.dart';
import '../../domain/repositories/task_repository.dart';
import '../data_sources/task_local_data_source.dart';

class LocalTaskRepository implements TaskRepository {
  const LocalTaskRepository(this._dataSource);

  final TaskLocalDataSource _dataSource;

  @override
  Future<List<TaskItem>> getTasks() {
    return _dataSource.getTasks();
  }

  @override
  Future<void> addTask(TaskItem task) {
    return _dataSource.saveTask(task);
  }

  @override
  Future<void> updateTask(TaskItem task) {
    return _dataSource.saveTask(task);
  }

  @override
  Future<void> toggleCompleted(String taskId) async {
    final task = await _dataSource.getTaskById(taskId);
    if (task == null || task.isDeleted) {
      return;
    }

    await _dataSource.saveTask(task.toggledCompleted());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final task = await _dataSource.getTaskById(taskId);
    if (task == null || task.isDeleted) {
      return;
    }

    await _dataSource.saveTask(task.markedDeleted());
  }
}
