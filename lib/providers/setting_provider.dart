import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for app settings and preferences
class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Settings
  bool _gridView = false;
  bool _autoSave = true;
  int _autoSaveInterval = 5; // seconds
  String _defaultCategory = 'General';
  bool _showWordCount = true;
  bool _biometricLock = false;
  String _dateFormat = 'MMM dd, yyyy';
  bool _confirmDelete = true;

  // Getters
  bool get gridView => _gridView;
  bool get autoSave => _autoSave;
  int get autoSaveInterval => _autoSaveInterval;
  String get defaultCategory => _defaultCategory;
  bool get showWordCount => _showWordCount;
  bool get biometricLock => _biometricLock;
  String get dateFormat => _dateFormat;
  bool get confirmDelete => _confirmDelete;
  bool get isInitialized => _isInitialized;

  /// Initialize settings from SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load settings from SharedPreferences
  void _loadSettings() {
    _gridView = _prefs.getBool('gridView') ?? false;
    _autoSave = _prefs.getBool('autoSave') ?? true;
    _autoSaveInterval = _prefs.getInt('autoSaveInterval') ?? 5;
    _defaultCategory = _prefs.getString('defaultCategory') ?? 'General';
    _showWordCount = _prefs.getBool('showWordCount') ?? true;
    _biometricLock = _prefs.getBool('biometricLock') ?? false;
    _dateFormat = _prefs.getString('dateFormat') ?? 'MMM dd, yyyy';
    _confirmDelete = _prefs.getBool('confirmDelete') ?? true;
  }

  /// Toggle grid/list view
  Future<void> toggleGridView() async {
    _gridView = !_gridView;
    await _prefs.setBool('gridView', _gridView);
    notifyListeners();
  }

  /// Set auto-save
  Future<void> setAutoSave(bool value) async {
    _autoSave = value;
    await _prefs.setBool('autoSave', value);
    notifyListeners();
  }

  /// Set auto-save interval
  Future<void> setAutoSaveInterval(int seconds) async {
    _autoSaveInterval = seconds;
    await _prefs.setInt('autoSaveInterval', seconds);
    notifyListeners();
  }

  /// Set default category
  Future<void> setDefaultCategory(String category) async {
    _defaultCategory = category;
    await _prefs.setString('defaultCategory', category);
    notifyListeners();
  }

  /// Toggle word count display
  Future<void> toggleWordCount() async {
    _showWordCount = !_showWordCount;
    await _prefs.setBool('showWordCount', _showWordCount);
    notifyListeners();
  }

  /// Toggle biometric lock
  Future<void> toggleBiometricLock() async {
    _biometricLock = !_biometricLock;
    await _prefs.setBool('biometricLock', _biometricLock);
    notifyListeners();
  }

  /// Set date format
  Future<void> setDateFormat(String format) async {
    _dateFormat = format;
    await _prefs.setString('dateFormat', format);
    notifyListeners();
  }

  /// Toggle delete confirmation
  Future<void> toggleConfirmDelete() async {
    _confirmDelete = !_confirmDelete;
    await _prefs.setBool('confirmDelete', _confirmDelete);
    notifyListeners();
  }

  /// Reset all settings to default
  Future<void> resetSettings() async {
    await _prefs.clear();
    _loadSettings();
    notifyListeners();
  }
}