import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskItem> _tasks = [];
  bool _isLoading = false;
  String _selectedCategory = 'সব';

  List<TaskItem> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<TaskItem> get filteredTasks {
    if (_selectedCategory == 'সব') {
      return _tasks;
    }
    return _tasks.where((t) => t.category == _selectedCategory).toList();
  }

  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get totalCount => _tasks.length;
  double get progressPercentage => totalCount > 0 ? completedCount / totalCount : 0.0;
  int get earnedPointsToday => _tasks.where((t) => t.isCompleted).fold(0, (sum, t) => sum + t.points);

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await TaskService.loadTodayTasks();
    } catch (e) {
      _tasks = TaskService.defaultTasks;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final current = _tasks[index];
      _tasks[index] = current.copyWith(isCompleted: !current.isCompleted);
      notifyListeners();
      await TaskService.saveTasks(_tasks);
    }
  }

  Future<void> addTask({
    required String title,
    required String category,
    int points = 10,
  }) async {
    final newTask = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      category: category,
      points: points,
    );
    _tasks.add(newTask);
    notifyListeners();
    await TaskService.saveTasks(_tasks);
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await TaskService.saveTasks(_tasks);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
