import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firebase_service.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  User? get firebaseUser => _auth.currentUser;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });

    // Check if user is already signed in
    final user = _auth.currentUser;
    if (user != null) {
      await _loadUserProfile(user.uid);
    }
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final userProfile = await FirebaseService.getUser(userId);
      _currentUser = userProfile;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Phone authentication - Send OTP
  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _error = e.message ?? 'Verification failed';
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      _error = 'No verification ID found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      await _signInWithCredential(credential);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        // Check if user profile exists
        final existingUser = await FirebaseService.getUser(user.uid);
        
        if (existingUser == null) {
          // Create new user profile
          final newUser = UserModel(
            id: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            profilePictureUrl: user.photoURL,
            createdAt: DateTime.now(),
            isActive: true,
          );
          
          await FirebaseService.createUser(newUser);
          _currentUser = newUser;
        } else {
          _currentUser = existingUser;
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user profile exists
        final existingUser = await FirebaseService.getUser(user.uid);
        
        if (existingUser == null) {
          // Create new user profile
          final newUser = UserModel(
            id: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            profilePictureUrl: user.photoURL,
            createdAt: DateTime.now(),
            isActive: true,
          );
          
          await FirebaseService.createUser(newUser);
          _currentUser = newUser;
        } else {
          _currentUser = existingUser;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseService.updateUser(updatedUser);
      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(String imagePath) async {
    try {
      final fileName = 'profile_${_currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await FirebaseService.uploadImage(imagePath, 'profile_pictures/$fileName');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _currentUser = null;
      _verificationId = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Mark user as inactive in Firestore
        if (_currentUser != null) {
          final updatedUser = _currentUser!.copyWith(isActive: false);
          await FirebaseService.updateUser(updatedUser);
        }
        
        // Delete Firebase Auth account
        await user.delete();
        _currentUser = null;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}