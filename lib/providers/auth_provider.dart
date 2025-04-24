import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    _userEmail = prefs.getString('user_email');
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    // Implement your authentication logic here
    // For demo purposes, we'll just save the state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', true);
    await prefs.setString('user_email', email);

    _isAuthenticated = true;
    _userEmail = email;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    // TODO: Implement actual sign-up logic here
    // This is a placeholder implementation
    try {
      // Simulate a network request
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, we'll just save the state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_email', email);

      _isAuthenticated = true;
      _userEmail = email;
      notifyListeners();
    } catch (e) {
      // Handle sign-up errors
      print('Sign-up error: $e');
      // You might want to show an error message to the user here
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', false);
    await prefs.remove('user_email');

    _isAuthenticated = false;
    _userEmail = null;
    notifyListeners();
  }
}