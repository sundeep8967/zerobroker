import 'package:flutter/material.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static String? _currentUserId;
  static String? _currentUserPhone;
  static String? _currentUserName;
  
  // Getters
  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUserId => _currentUserId;
  static String? get currentUserPhone => _currentUserPhone;
  static String? get currentUserName => _currentUserName;
  
  // Mock phone OTP login
  static Future<AuthResult> sendOTP(String phoneNumber) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock validation - accept any 10-digit Indian number
    if (phoneNumber.length == 10 && phoneNumber.startsWith(RegExp(r'[6-9]'))) {
      return AuthResult(
        success: true,
        message: 'OTP sent successfully to +91 $phoneNumber',
        otpSent: true,
      );
    } else {
      return AuthResult(
        success: false,
        message: 'Please enter a valid 10-digit mobile number',
      );
    }
  }
  
  // Mock OTP verification
  static Future<AuthResult> verifyOTP(String phoneNumber, String otp) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock OTP verification - accept "123456" or last 6 digits of phone
    final validOTPs = ['123456', phoneNumber.substring(4)];
    
    if (validOTPs.contains(otp)) {
      _isLoggedIn = true;
      _currentUserId = 'user_${phoneNumber}';
      _currentUserPhone = '+91 $phoneNumber';
      _currentUserName = 'User'; // Will be updated in profile
      
      return AuthResult(
        success: true,
        message: 'Login successful',
        user: UserData(
          id: _currentUserId!,
          phone: _currentUserPhone!,
          name: _currentUserName!,
        ),
      );
    } else {
      return AuthResult(
        success: false,
        message: 'Invalid OTP. Please try again.',
      );
    }
  }
  
  // Google Sign-In mock
  static Future<AuthResult> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock Google sign-in success
    _isLoggedIn = true;
    _currentUserId = 'google_user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserPhone = '+91 9876543210'; // Mock phone
    _currentUserName = 'Google User';
    
    return AuthResult(
      success: true,
      message: 'Google sign-in successful',
      user: UserData(
        id: _currentUserId!,
        phone: _currentUserPhone!,
        name: _currentUserName!,
      ),
    );
  }
  
  // Logout
  static Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserPhone = null;
    _currentUserName = null;
  }
  
  // Update user profile
  static void updateUserProfile({String? name, String? phone}) {
    if (name != null) _currentUserName = name;
    if (phone != null) _currentUserPhone = phone;
  }
  
  // Check if user is new (for onboarding)
  static bool isNewUser() {
    // Mock logic - consider user new if name is still default
    return _currentUserName == 'User' || _currentUserName == 'Google User';
  }
}

class AuthResult {
  final bool success;
  final String message;
  final bool otpSent;
  final UserData? user;
  
  AuthResult({
    required this.success,
    required this.message,
    this.otpSent = false,
    this.user,
  });
}

class UserData {
  final String id;
  final String phone;
  final String name;
  final String? email;
  final String? profilePicture;
  
  UserData({
    required this.id,
    required this.phone,
    required this.name,
    this.email,
    this.profilePicture,
  });
}