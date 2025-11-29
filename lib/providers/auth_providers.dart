

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashwisecollector/auth_service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerCollector(
        fullName: fullName,
        email: email,
        password: password,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
  isLoading = false;
  if (e is FirebaseAuthException) {
    errorMessage = e.message;
  } else {
    errorMessage = e.toString();
  }
  notifyListeners();
  return false;
}
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.loginCollector(email: email, password: password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
