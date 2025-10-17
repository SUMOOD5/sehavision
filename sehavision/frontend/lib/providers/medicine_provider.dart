import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/api_service.dart';

class MedicineProvider extends ChangeNotifier {
  List<Medicine> _medicines = [];
  Medicine? _selectedMedicine;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Medicine> get medicines => _medicines;
  Medicine? get selectedMedicine => _selectedMedicine;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  List<Medicine> get filteredMedicines {
    if (_searchQuery.isEmpty) return _medicines;

    return _medicines.where((medicine) {
      final query = _searchQuery.toLowerCase();
      return medicine.name.toLowerCase().contains(query) ||
          (medicine.brand?.toLowerCase().contains(query) ?? false) ||
          (medicine.barcode?.contains(query) ?? false);
    }).toList();
  }

  MedicineProvider() {
    loadMedicines();
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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> loadMedicines({String? search}) async {
    _setLoading(true);
    _clearError();

    try {
      final endpoint = search != null
          ? '/medicines?search=$search'
          : '/medicines';
      final response = await ApiService.get(endpoint);

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        _medicines = (data['medicines'] as List)
            .map((json) => Medicine.fromJson(json))
            .toList();
      } else {
        _setError(ApiService.getErrorMessage(response));
      }
    } catch (e) {
      _setError('Failed to load medicines');
    } finally {
      _setLoading(false);
    }
  }

  Future<Medicine?> getMedicineById(int id) async {
    try {
      final response = await ApiService.get('/medicines/$id');

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        return Medicine.fromJson(data['medicine']);
      } else {
        _setError(ApiService.getErrorMessage(response));
        return null;
      }
    } catch (e) {
      _setError('Failed to load medicine');
      return null;
    }
  }

  Future<bool> createMedicine(Medicine medicine) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post('/medicines', medicine.toJson());

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        final newMedicine = Medicine.fromJson(data['medicine']);
        _medicines.add(newMedicine);
        notifyListeners();
        return true;
      } else {
        _setError(ApiService.getErrorMessage(response));
        return false;
      }
    } catch (e) {
      _setError('Failed to create medicine');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateMedicine(Medicine medicine) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put(
        '/medicines/${medicine.id}',
        medicine.toJson(),
      );

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        final updatedMedicine = Medicine.fromJson(data['medicine']);

        final index = _medicines.indexWhere((m) => m.id == medicine.id);
        if (index != -1) {
          _medicines[index] = updatedMedicine;
          notifyListeners();
        }
        return true;
      } else {
        _setError(ApiService.getErrorMessage(response));
        return false;
      }
    } catch (e) {
      _setError('Failed to update medicine');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteMedicine(int id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.delete('/medicines/$id');

      if (ApiService.isSuccess(response)) {
        _medicines.removeWhere((medicine) => medicine.id == id);
        notifyListeners();
        return true;
      } else {
        _setError(ApiService.getErrorMessage(response));
        return false;
      }
    } catch (e) {
      _setError('Failed to delete medicine');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void selectMedicine(Medicine? medicine) {
    _selectedMedicine = medicine;
    notifyListeners();
  }

  void clearSelection() {
    _selectedMedicine = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Search medicines locally
  List<Medicine> searchMedicines(String query) {
    if (query.isEmpty) return _medicines;

    final lowercaseQuery = query.toLowerCase();
    return _medicines.where((medicine) {
      return medicine.name.toLowerCase().contains(lowercaseQuery) ||
          (medicine.brand?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (medicine.barcode?.contains(query) ?? false) ||
          (medicine.dosage?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Get medicines by brand
  List<Medicine> getMedicinesByBrand(String brand) {
    return _medicines.where((medicine) => medicine.brand == brand).toList();
  }

  // Get expired medicines
  List<Medicine> getExpiredMedicines() {
    return _medicines.where((medicine) => medicine.isExpired).toList();
  }

  // Get medicines expiring soon
  List<Medicine> getMedicinesExpiringSoon() {
    return _medicines.where((medicine) => medicine.isExpiringSoon).toList();
  }

  // Get unique brands
  List<String> getUniqueBrands() {
    final brands = _medicines
        .where(
          (medicine) => medicine.brand != null && medicine.brand!.isNotEmpty,
        )
        .map((medicine) => medicine.brand!)
        .toSet()
        .toList();
    brands.sort();
    return brands;
  }
}
