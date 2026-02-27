import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api = ApiService();
  User? user;
  bool isLoading = false;
  String? error;

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await api.login(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await api.register(name, email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await api.logout();
    user = null;
    notifyListeners();
  }

  bool get isAuthenticated => user != null;
}