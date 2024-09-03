import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _email;
  String? _token;
  bool _skippedSignIn = false;

  String? get email => _email;
  String? get token => _token;
  bool get skippedSignIn => _skippedSignIn;

  bool get isLoggedIn => _token != null && !_skippedSignIn;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _email = prefs.getString('email');
    _token = prefs.getString('token');
    _skippedSignIn = prefs.getBool('skippedSignIn') ?? false;
    notifyListeners();
  }

  Future<void> setUser(String email, String token) async {
    _email = email;
    _token = token;
    _skippedSignIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('token', token);
    await prefs.setBool('skippedSignIn', false);
    notifyListeners();
  }

  Future<void> setSkippedSignIn(bool skipped) async {
    _skippedSignIn = skipped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skippedSignIn', skipped);
    notifyListeners();
  }

  Future<void> clearUser() async {
    _email = null;
    _token = null;
    _skippedSignIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('token');
    await prefs.setBool('skippedSignIn', false);
    notifyListeners();
  }

  void signOut() {
    clearUser();
  }
}
