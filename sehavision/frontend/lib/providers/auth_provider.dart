import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final token = prefs.getString('token');

      if (userJson != null && token != null) {
        _user = User.fromJson(json.decode(userJson));
        _token = token;
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null && _token != null) {
        await prefs.setString('user', json.encode(_user!.toJson()));
        await prefs.setString('token', _token!);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');
    } catch (e) {
      // Handle error silently
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        _token = response['token'];
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _setError(response['error'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String? phone,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });

      if (response['success'] == true || response['message'] != null) {
        _user = User.fromJson(response['user']);
        _token = response['token'];
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _setError(response['error'] ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;
    await _clearUserData();
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String? phone) async {
    if (!isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/auth/profile', {
        'name': name,
        'phone': phone,
      }, token: _token);

      if (response['success'] == true || response['user'] != null) {
        _user = User.fromJson(response['user'] ?? response);
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _setError(response['error'] ?? 'Profile update failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (!isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/auth/change-password', {
        'current_password': currentPassword,
        'new_password': newPassword,
      }, token: _token);

      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _setError(response['error'] ?? 'Password change failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
