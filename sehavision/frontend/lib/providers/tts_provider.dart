import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSProvider extends ChangeNotifier {
  static const String _ttsEnabledKey = 'tts_enabled';
  static const String _ttsLanguageKey = 'tts_language';
  static const String _ttsRateKey = 'tts_rate';
  static const String _ttsPitchKey = 'tts_pitch';
  static const String _ttsVolumeKey = 'tts_volume';

  final FlutterTts _flutterTts = FlutterTts();

  bool _isEnabled = false;
  bool _isSpeaking = false;
  bool _isInitialized = false;
  String _language = 'en-US';
  double _rate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String? _error;

  bool get isEnabled => _isEnabled;
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
  String get language => _language;
  double get rate => _rate;
  double get pitch => _pitch;
  double get volume => _volume;
  String? get error => _error;

  TTSProvider() {
    _initializeTTS();
    _loadSettings();
  }

  Future<void> _initializeTTS() async {
    try {
      // Get available languages
      final languages = await _flutterTts.getLanguages;
      print('Available TTS languages: $languages');

      // Set up event handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        _error = message;
        notifyListeners();
      });

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize TTS: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_ttsEnabledKey) ?? false;
      _language = prefs.getString(_ttsLanguageKey) ?? 'en-US';
      _rate = prefs.getDouble(_ttsRateKey) ?? 0.5;
      _pitch = prefs.getDouble(_ttsPitchKey) ?? 1.0;
      _volume = prefs.getDouble(_ttsVolumeKey) ?? 1.0;

      await _applySettings();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load TTS settings: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_ttsEnabledKey, _isEnabled);
      await prefs.setString(_ttsLanguageKey, _language);
      await prefs.setDouble(_ttsRateKey, _rate);
      await prefs.setDouble(_ttsPitchKey, _pitch);
      await prefs.setDouble(_ttsVolumeKey, _volume);
    } catch (e) {
      _error = 'Failed to save TTS settings: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _applySettings() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.setLanguage(_language);
      await _flutterTts.setSpeechRate(_rate);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setVolume(_volume);
    } catch (e) {
      _error = 'Failed to apply TTS settings: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> setEnabled(bool enabled) async {
    if (_isEnabled == enabled) return;

    _isEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_language == language) return;

    _language = language;
    await _applySettings();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setRate(double rate) async {
    if (_rate == rate) return;

    _rate = rate.clamp(0.1, 1.0);
    await _applySettings();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    if (_pitch == pitch) return;

    _pitch = pitch.clamp(0.5, 2.0);
    await _applySettings();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    if (_volume == volume) return;

    _volume = volume.clamp(0.0, 1.0);
    await _applySettings();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (!_isEnabled || !_isInitialized || text.isEmpty) return;

    try {
      _error = null;
      await _flutterTts.speak(text);
    } catch (e) {
      _error = 'Failed to speak text: ${e.toString()}';
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to stop TTS: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.pause();
    } catch (e) {
      _error = 'Failed to pause TTS: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) return [];

    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      _error = 'Failed to get available languages: ${e.toString()}';
      return [];
    }
  }

  Future<List<String>> getAvailableVoices() async {
    if (!_isInitialized) return [];

    try {
      final voices = await _flutterTts.getVoices;
      return voices.map((voice) => voice['name'] as String).toList();
    } catch (e) {
      _error = 'Failed to get available voices: ${e.toString()}';
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper method to speak medicine information
  Future<void> speakMedicineInfo(
    String name,
    String? brand,
    String? dosage,
    String? instructions,
  ) async {
    if (!_isEnabled) return;

    final text = StringBuffer();
    text.write('Medicine: $name');

    if (brand != null && brand.isNotEmpty) {
      text.write(', Brand: $brand');
    }

    if (dosage != null && dosage.isNotEmpty) {
      text.write(', Dosage: $dosage');
    }

    if (instructions != null && instructions.isNotEmpty) {
      text.write('. Instructions: $instructions');
    }

    await speak(text.toString());
  }

  // Helper method to speak reminder
  Future<void> speakReminder(String title, String? description) async {
    if (!_isEnabled) return;

    final text = StringBuffer();
    text.write('Reminder: $title');

    if (description != null && description.isNotEmpty) {
      text.write('. $description');
    }

    await speak(text.toString());
  }

  // Helper method to speak scan result
  Future<void> speakScanResult(String medicineName, double confidence) async {
    if (!_isEnabled) return;

    final confidencePercent = (confidence * 100).round();
    final text =
        'Medicine recognized: $medicineName. Confidence: $confidencePercent percent.';

    await speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
