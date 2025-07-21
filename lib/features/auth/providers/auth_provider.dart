import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is already logged in
      // This will be implemented with Firebase Auth
      await Future.delayed(const Duration(seconds: 2)); // Simulate loading
      
      // For now, set as not authenticated
      _isAuthenticated = false;
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with phone OTP
  Future<bool> loginWithPhone(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Implement Firebase Auth phone login
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Create dummy user for now
      _currentUser = UserModel(
        id: 'user_123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: phoneNumber,
        createdAt: DateTime.now(),
        preferences: UserPreferences(),
      );
      
      _isAuthenticated = true;
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Implement OTP verification
      await Future.delayed(const Duration(seconds: 1));
      
      if (otp == '123456') { // Dummy verification
        _isAuthenticated = true;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('OTP verification error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate Google Sign-In process
      await Future.delayed(const Duration(seconds: 2));
      
      // Create user with Google account details
      _currentUser = UserModel(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        name: 'John Smith',
        email: 'john.smith@gmail.com',
        phone: '+91 9876543210',
        createdAt: DateTime.now(),
        preferences: UserPreferences(
          preferredCity: 'Bangalore',
          maxBudget: 50000,
        ),
      );
      
      _isAuthenticated = true;
      return true;
    } catch (e) {
      debugPrint('Google login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await logout();
  }

  // Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Profile update error: $e');
      return false;
    }
  }
}