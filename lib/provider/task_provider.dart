import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/task_model.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  List<Task> tasks = [];
  bool isLoading = false;
  String? error;

  TaskProvider() {
    // Listen for connectivity changes to auto-sync offline tasks
    Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> results) {
      if (!results.contains(ConnectivityResult.none)) {
        _handleConnectivityChange();
      }
    });
  }

  Future<void> _handleConnectivityChange() async {
    try {
      final token = await storage.read(key: 'token'); // or getToken() method
      if (token != null) {
        await LocalDb.syncOfflineTasks(apiService.baseUrl, token);
        await loadTasks(); // refresh UI after sync
      }
    } catch (e) {
      print('Error syncing tasks: $e');
    }
  }


  Future<void> loadTasks() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // STEP 1: Always load local first
      final localTasks = await LocalDb.getTasks();
      tasks = localTasks;
      notifyListeners();

      // STEP 2: Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // STEP 3: Sync offline tasks first
        final token = await storage.read(key: 'token');
        if (token != null) {
          await LocalDb.syncOfflineTasks(apiService.baseUrl, token);
        }

        // STEP 4: Fetch fresh API tasks
        final apiTasks = await apiService.fetchTasks();

        // STEP 5: Cache them locally (preserves unsynced)
        await LocalDb.cacheTasksFromApi(apiTasks);

        // STEP 6: Reload from SQLite (single source of truth)
        final updatedLocalTasks = await LocalDb.getTasks();
        tasks = updatedLocalTasks;
      }

    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  /// ADD TASK (Offline-first)
  Future<void> addTask(Task task) async {
    error = null;
    notifyListeners();

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // ONLINE: create via API
        final createdTask = await apiService.createTask(task);

        tasks.insert(0, createdTask);
        await LocalDb.insertTask(createdTask, fromApi: true);
      } else {
        // OFFLINE: save locally as unsynced
        await LocalDb.insertTask(task, fromApi: false);
        tasks.insert(0, task);
      }

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// DELETE TASK
  Future<void> deleteTask(String id) async {
    error = null;

    try {
      // Remove locally
      await LocalDb.deleteTask(id);
      tasks.removeWhere((task) => task.id == id);
      notifyListeners();

      // Delete from API if online
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        await apiService.deleteTask(id);
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = await apiService.updateTask(task);

      final index = tasks.indexWhere((t) => t.id == task.id);

      if (index != -1) {
        tasks[index] = updatedTask;
        notifyListeners();
      }

    } catch (e) {
      rethrow;
    }
  }
  /// PULL TO REFRESH
  Future<void> refreshTasks() async {
    await loadTasks();
  }
}