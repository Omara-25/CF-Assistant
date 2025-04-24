import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // Font size settings
  double _fontSize = 16.0; // Default font size
  String _fontSizeLabel = 'Medium'; // Default label

  // Notification settings
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;

  // Privacy settings
  bool _dataCollectionEnabled = true;

  // Getters
  double get fontSize => _fontSize;
  String get fontSizeLabel => _fontSizeLabel;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  bool get dataCollectionEnabled => _dataCollectionEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load font size settings
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _fontSizeLabel = prefs.getString('fontSizeLabel') ?? 'Medium';
    
    // Load notification settings
    _pushNotificationsEnabled = prefs.getBool('pushNotificationsEnabled') ?? true;
    _emailNotificationsEnabled = prefs.getBool('emailNotificationsEnabled') ?? false;
    
    // Load privacy settings
    _dataCollectionEnabled = prefs.getBool('dataCollectionEnabled') ?? true;
    
    notifyListeners();
  }

  // Font size methods
  Future<void> setFontSize(double size, String label) async {
    _fontSize = size;
    _fontSizeLabel = label;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    await prefs.setString('fontSizeLabel', label);
  }

  // Notification methods
  Future<void> togglePushNotifications(bool value) async {
    _pushNotificationsEnabled = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotificationsEnabled', value);
  }

  Future<void> toggleEmailNotifications(bool value) async {
    _emailNotificationsEnabled = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailNotificationsEnabled', value);
  }

  // Privacy methods
  Future<void> toggleDataCollection(bool value) async {
    _dataCollectionEnabled = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dataCollectionEnabled', value);
  }
}
