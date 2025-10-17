import 'package:flutter/material.dart';
import 'dart:io';
import '../models/medicine.dart';
import '../services/api_service.dart';

class ScanResult {
  final bool success;
  final Medicine? medicine;
  final double confidence;
  final String? scanImage;
  final String? error;
  final int processingTime;

  ScanResult({
    required this.success,
    this.medicine,
    this.confidence = 0.0,
    this.scanImage,
    this.error,
    this.processingTime = 0,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      success: json['success'] ?? false,
      medicine: json['medicine'] != null
          ? Medicine.fromJson(json['medicine'])
          : null,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      scanImage: json['scan_image'],
      error: json['error'],
      processingTime: json['processing_time'] ?? 0,
    );
  }
}

class ScanProvider extends ChangeNotifier {
  ScanResult? _lastScanResult;
  bool _isScanning = false;
  String? _error;
  List<ScanResult> _scanHistory = [];

  ScanResult? get lastScanResult => _lastScanResult;
  bool get isScanning => _isScanning;
  String? get error => _error;
  List<ScanResult> get scanHistory => _scanHistory;

  void _setScanning(bool scanning) {
    _isScanning = scanning;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<ScanResult> scanImage(File imageFile, String token) async {
    _setScanning(true);
    _clearError();

    try {
      final response = await ApiService.postMultipart('/scan/image', {}, {
        'image': imageFile,
      }, token: token);

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        final result = ScanResult.fromJson(data);
        _lastScanResult = result;
        _scanHistory.insert(0, result);

        // Keep only last 50 scans
        if (_scanHistory.length > 50) {
          _scanHistory = _scanHistory.take(50).toList();
        }

        _setScanning(false);
        return result;
      } else {
        final error = ApiService.getErrorMessage(response);
        _setError(error);
        final result = ScanResult(success: false, error: error);
        _lastScanResult = result;
        _setScanning(false);
        return result;
      }
    } catch (e) {
      final error = 'Failed to scan image: ${e.toString()}';
      _setError(error);
      final result = ScanResult(success: false, error: error);
      _lastScanResult = result;
      _setScanning(false);
      return result;
    }
  }

  Future<ScanResult> scanBarcode(String barcode, String token) async {
    _setScanning(true);
    _clearError();

    try {
      final response = await ApiService.post('/scan/barcode', {
        'barcode': barcode,
      }, token: token);

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        final result = ScanResult.fromJson(data);
        _lastScanResult = result;
        _scanHistory.insert(0, result);

        // Keep only last 50 scans
        if (_scanHistory.length > 50) {
          _scanHistory = _scanHistory.take(50).toList();
        }

        _setScanning(false);
        return result;
      } else {
        final error = ApiService.getErrorMessage(response);
        _setError(error);
        final result = ScanResult(success: false, error: error);
        _lastScanResult = result;
        _setScanning(false);
        return result;
      }
    } catch (e) {
      final error = 'Failed to scan barcode: ${e.toString()}';
      _setError(error);
      final result = ScanResult(success: false, error: error);
      _lastScanResult = result;
      _setScanning(false);
      return result;
    }
  }

  Future<void> loadScanHistory(String token) async {
    try {
      final response = await ApiService.get('/scan/history', token: token);

      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        // Handle scan history if implemented in backend
        // For now, we'll keep the local history
      }
    } catch (e) {
      // Handle error silently for history loading
    }
  }

  void clearLastResult() {
    _lastScanResult = null;
    _clearError();
    notifyListeners();
  }

  void clearHistory() {
    _scanHistory.clear();
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Get successful scans only
  List<ScanResult> getSuccessfulScans() {
    return _scanHistory.where((scan) => scan.success).toList();
  }

  // Get failed scans only
  List<ScanResult> getFailedScans() {
    return _scanHistory.where((scan) => !scan.success).toList();
  }

  // Get scans with high confidence
  List<ScanResult> getHighConfidenceScans() {
    return _scanHistory.where((scan) => scan.confidence >= 0.8).toList();
  }

  // Get recent scans (last 10)
  List<ScanResult> getRecentScans() {
    return _scanHistory.take(10).toList();
  }

  // Get scan statistics
  Map<String, int> getScanStatistics() {
    final total = _scanHistory.length;
    final successful = _scanHistory.where((scan) => scan.success).length;
    final failed = total - successful;
    final highConfidence = _scanHistory
        .where((scan) => scan.confidence >= 0.8)
        .length;

    return {
      'total': total,
      'successful': successful,
      'failed': failed,
      'high_confidence': highConfidence,
    };
  }
}
