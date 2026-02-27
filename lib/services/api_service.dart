import 'dart:convert';
import 'package:flowly/services/secure_storage_services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/task_model.dart';
import '../model/user_model.dart';

class ApiService {
  final String baseUrl = 'https://nexora.cscollaborators.online/api';
  final SecureStorageService storage = SecureStorageService();

  // LOGIN
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']['token'];
      await storage.saveToken(token);
      return User.fromJson(data['data']['user']);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // REGISTER
  Future<User> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['data']['token'];
      await storage.saveToken(token);
      return User.fromJson(data['data']['user']);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await storage.clearToken();
  }

  // FETCH TASKS
  Future<List<Task>> fetchTasks() async {
    final token = await storage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tasksJson = data['data'] as List;
      return tasksJson.map((t) => Task.fromJson(t)).toList();
    } else {
      throw Exception('Failed to fetch tasks: ${response.body}');
    }
  }

  // CREATE TASk
  Future<Task> createTask(Task task) async {
    final token = await storage.getToken();
    if (token == null) throw Exception('No token found');

    // Format due date to YYYY-MM-DD
    final dueDateTime = DateTime.parse(
      task.dueDate,
    ); // converts String → DateTime
    final formattedDueDate = DateFormat('yyyy-MM-dd').format(dueDateTime);

    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // ensures JSON response
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': task.name,
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'due_date': formattedDueDate,
      }),
    );

    // Debug prints
    print('Status code: ${response.statusCode}');
    print('Raw response: ${response.body}');

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return Task.fromJson(data['data']);
      } else if (response.statusCode == 422) {
        // Laravel validation errors
        throw Exception('Validation Error: ${data['errors']}');
      } else {
        throw Exception(
          'Failed to add task: ${data['message'] ?? response.body}',
        );
      }
    } catch (e) {
      // If JSON parsing fails
      throw Exception('Invalid JSON response from server: ${response.body}');
    }
  }

  Future<Task> updateTask(Task task) async {
    final token = await storage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': task.name,
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'due_date': task.dueDate,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Task.fromJson(data['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Task not found');
    } else if (response.statusCode == 422) {
      throw Exception('Validation error: ${data['errors']}');
    } else {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  Future<void> deleteTask(String id) async {
    final token = await storage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      // Successfully deleted, nothing to return
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Task not found');
    } else {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }
}
