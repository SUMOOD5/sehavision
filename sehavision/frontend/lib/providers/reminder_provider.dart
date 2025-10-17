import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/api_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Reminder> get activeReminders {
    return _reminders.where((reminder) => reminder.isActive).toList();
  }

  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    return _reminders.where((reminder) {
      return reminder.isActive && reminder.scheduledTime.isAfter(now);
    }).toList();
  }

  List<Reminder> get overdueReminders {
    final now = DateTime.now();
    return _reminders.where((reminder) {
      return reminder.isActive && reminder.scheduledTime.isBefore(now);
    }).toList();
  }

  ReminderProvider() {
    loadReminders();
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

  Future<void> loadReminders({String? token}) async {
    if (token == null) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.get('/reminders', token: token);

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        _reminders = (data['reminders'] as List)
            .map((json) => Reminder.fromJson(json))
            .toList();
      } else {
        _setError(ApiService.getErrorMessage(response));
      }
    } catch (e) {
      _setError('Failed to load reminders');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createReminder(Reminder reminder, String token) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post(
        '/reminders',
        reminder.toJson(),
        token: token,
      );

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        final newReminder = Reminder.fromJson(data['reminder']);
        _reminders.add(newReminder);
        notifyListeners();
        return true;
      } else {
        _setError(ApiService.getErrorMessage(response));
        return false;
      }
    } catch (e) {
      _setError('Failed to create reminder');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateReminder(Reminder reminder, String token) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put(
        '/reminders/${reminder.id}',
        reminder.toJson(),
        token: token,
      );

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        final updatedReminder = Reminder.fromJson(data['reminder']);

        final index = _reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          _reminders[index] = updatedReminder;
          notifyListeners();
        }
        return true;
      } else {
        _setError(ApiService.getErrorMessage(response));
        return false;
      }
    } catch (e) {
      _setError('Failed to update reminder');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteReminder(int id, String token) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.delete('/reminders/$id', token: token);

      if (ApiService.isSuccess(response)) {
        _reminders.removeWhere((reminder) => reminder.id == id);
        notifyListeners();
        return true;
      } else {
        _setError(ApiService.getErrorMessage(response));
        return false;
      }
    } catch (e) {
      _setError('Failed to delete reminder');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleReminder(int id, String token) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.patch(
        '/reminders/$id/toggle',
        {},
        token: token,
      );

      if (ApiService.isSuccess(response)) {
        final index = _reminders.indexWhere((reminder) => reminder.id == id);
        if (index != -1) {
          _reminders[index] = _reminders[index].copyWith(
            isActive: !_reminders[index].isActive,
          );
          notifyListeners();
        }
        return true;
      } else {
        _setError(ApiService.getErrorMessage(response));
        return false;
      }
    } catch (e) {
      _setError('Failed to toggle reminder');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Reminder>> getUpcomingReminders(String token) async {
    try {
      final response = await ApiService.get(
        '/reminders/upcoming/24h',
        token: token,
      );

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        return (data['upcoming_reminders'] as List)
            .map((json) => Reminder.fromJson(json))
            .toList();
      } else {
        _setError(ApiService.getErrorMessage(response));
        return [];
      }
    } catch (e) {
      _setError('Failed to load upcoming reminders');
      return [];
    }
  }

  void clearError() {
    _clearError();
  }

  // Get reminders for a specific medicine
  List<Reminder> getRemindersForMedicine(int medicineId) {
    return _reminders
        .where((reminder) => reminder.medicineId == medicineId)
        .toList();
  }

  // Get reminders by frequency
  List<Reminder> getRemindersByFrequency(String frequency) {
    return _reminders
        .where((reminder) => reminder.frequency == frequency)
        .toList();
  }

  // Get reminders for today
  List<Reminder> getTodaysReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _reminders.where((reminder) {
      return reminder.isActive &&
          reminder.scheduledTime.isAfter(today) &&
          reminder.scheduledTime.isBefore(tomorrow);
    }).toList();
  }

  // Get reminders for this week
  List<Reminder> getThisWeeksReminders() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return _reminders.where((reminder) {
      return reminder.isActive &&
          reminder.scheduledTime.isAfter(startOfWeek) &&
          reminder.scheduledTime.isBefore(endOfWeek);
    }).toList();
  }

  // Get reminder statistics
  Map<String, int> getReminderStatistics() {
    final total = _reminders.length;
    final active = _reminders.where((reminder) => reminder.isActive).length;
    final inactive = total - active;
    final today = getTodaysReminders().length;
    final thisWeek = getThisWeeksReminders().length;

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'today': today,
      'this_week': thisWeek,
    };
  }
}
