import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/task.dart';

// Firebase database configured with the correct URL
final FirebaseDatabase database = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL:
      'https://academitrack-b195c-default-rtdb.asia-southeast1.firebasedatabase.app',
);

class TaskProvider with ChangeNotifier {
  final Map<String, List<Task>> _tasks = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TaskProvider() {
    // Fetch tasks whenever auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchTasks();
      } else {
        _tasks.clear();
        notifyListeners();
      }
    });
  }

  List<Task> get tasks => _tasks.values.expand((taskList) => taskList).toList();

  List<Task> getTasksByProject(String projectId) => _tasks[projectId] ?? [];

  Future<void> fetchTasks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = database.ref('tasks/${user.uid}');
    final snapshot = await ref.get();

    _tasks.clear();

    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        if (value is Map) {
          final taskMap = Map<String, dynamic>.from(value);
          final task = Task.fromMap(taskMap);
          final keyStr = task.projectId.toString();
          _tasks.putIfAbsent(keyStr, () => []).add(task);
        }
      });
      notifyListeners();
    } else {
      debugPrint("fetchTasks(): Snapshot is not a Map, skipping...");
    }
  }

  Future<void> addTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = database.ref('tasks/${user.uid}').push();
    final newTask = task.copyWith(id: ref.key);

    try {
      await ref.set(newTask.toMap());
      final keyStr = newTask.projectId.toString();
      _tasks.putIfAbsent(keyStr, () => []).add(newTask);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null || task.id == null) return;

    final ref = database.ref('tasks/${user.uid}/${task.id}');
    await ref.update(task.toMap());

    final keyStr = task.projectId.toString();
    final tasksList = _tasks[keyStr];
    if (tasksList != null) {
      final index = tasksList.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasksList[index] = task;
        notifyListeners();
      }
    }
  }

  Future<void> deleteTask(String projectId, String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = database.ref('tasks/${user.uid}/$taskId');
    await ref.remove();

    _tasks[projectId]?.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  Future<void> toggleTaskStatus(String projectId, String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final tasksList = _tasks[projectId];
    if (tasksList != null) {
      final task = tasksList.firstWhere(
        (t) => t.id == taskId,
        orElse: () => Task(
          id: taskId,
          projectId: projectId,
          title: 'Unknown',
          description: '',
          dueDate: DateTime.now(),
          isCompleted: false,
        ),
      );

      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
    }
  }
}
