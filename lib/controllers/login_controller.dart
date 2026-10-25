import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';

enum LoginStatus { initial, loading, success, error }

class LoginController extends ChangeNotifier {
  UserRole _selectedRole = UserRole.resident;
  String _identifier = '';
  String _password = '';
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  LoginStatus _status = LoginStatus.initial;
  String? _errorMessage;

  // Predefined credentials mapping (for self-seeding in Firebase Auth if not already existing)
  static const Map<String, String> _predefinedCredentials = {
    'user1@lakshya.com': 'password123',
    'user2@lakshya.com': 'password123',
    'manager@lakshya.com': 'password123',
    'admin@lakshya.com': 'password123',
  };

  // Getters
  UserRole get selectedRole => _selectedRole;
  String get identifier => _identifier;
  String get password => _password;
  bool get rememberMe => _rememberMe;
  bool get isPasswordVisible => _isPasswordVisible;
  LoginStatus get status => _status;
  bool get isLoading => _status == LoginStatus.loading;
  String? get errorMessage => _errorMessage;

  // Setters & Actions
  void setRole(UserRole role) {
    if (_selectedRole != role) {
      _selectedRole = role;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void setIdentifier(String value) {
    _identifier = value.trim();
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void setPassword(String value) {
    _password = value;
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  bool validate() {
    if (_identifier.isEmpty) {
      _errorMessage = 'Please enter your email address';
      notifyListeners();
      return false;
    }
    // Simple email pattern check
    if (!_identifier.contains('@') || !_identifier.contains('.')) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }
    if (_password.isEmpty) {
      _errorMessage = 'Please enter your password';
      notifyListeners();
      return false;
    }
    if (_password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    return true;
  }

  Future<bool> login() async {
    if (!validate()) return false;

    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final lowercaseEmail = _identifier.toLowerCase();

    debugPrint("DEBUG AUTH: Attempting login...");
    debugPrint("DEBUG AUTH: email='$lowercaseEmail'");
    debugPrint("DEBUG AUTH: role='$_selectedRole'");
    debugPrint("DEBUG AUTH: password='$_password'");

    // Prevent incorrect role log-ins
    if (_selectedRole == UserRole.resident) {
      if (lowercaseEmail == 'admin@lakshya.com' || lowercaseEmail == 'manager@lakshya.com') {
        _status = LoginStatus.error;
        _errorMessage = 'Please sign in as Manager to access this account.';
        debugPrint("DEBUG AUTH: Prevented admin/manager login through resident role portal.");
        notifyListeners();
        return false;
      }
    } else if (_selectedRole == UserRole.owner) {
      if (lowercaseEmail == 'user1@lakshya.com' || lowercaseEmail == 'user2@lakshya.com') {
        _status = LoginStatus.error;
        _errorMessage = 'Please sign in as User to access this account.';
        debugPrint("DEBUG AUTH: Prevented resident login through owner/manager role portal.");
        notifyListeners();
        return false;
      }
    }

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final isPredefined = _predefinedCredentials.containsKey(lowercaseEmail);
      final isCorrectPredefinedPassword = isPredefined && _predefinedCredentials[lowercaseEmail] == _password;

      debugPrint("DEBUG AUTH: isPredefined=$isPredefined, isCorrectPredefinedPassword=$isCorrectPredefinedPassword");

      UserCredential? credential;

      try {
        credential = await auth.signInWithEmailAndPassword(
          email: lowercaseEmail,
          password: _password,
        );
      } on FirebaseAuthException catch (signInError) {
        debugPrint("DEBUG AUTH: signInError code='${signInError.code}', message='${signInError.message}'");
        // Under Email Enumeration Protection (enabled by default on new Firebase projects), 
        // Firebase returns 'invalid-credential' (or 'INVALID_LOGIN_CREDENTIALS') 
        // instead of 'user-not-found' to prevent enumeration.
        if (isCorrectPredefinedPassword &&
            (signInError.code == 'invalid-credential' ||
             signInError.code == 'user-not-found' ||
             signInError.code == 'INVALID_LOGIN_CREDENTIALS' ||
             signInError.code == 'wrong-password')) {
          try {
            debugPrint("DEBUG AUTH: Attempting to self-seed/create user on-the-fly...");
            credential = await auth.createUserWithEmailAndPassword(
              email: lowercaseEmail,
              password: _password,
            );
          } on FirebaseAuthException catch (signUpError) {
            debugPrint("DEBUG AUTH: signUpError code='${signUpError.code}', message='${signUpError.message}'");
            if (signUpError.code == 'email-already-in-use') {
              // User exists, but the sign-in failed (likely incorrect password entered by user)
              throw signInError;
            } else {
              throw signUpError;
            }
          }
        } else {
          throw signInError;
        }
      }

      if (credential != null && credential.user != null) {
        _status = LoginStatus.success;
        debugPrint("DEBUG AUTH: Authentication successful!");
        notifyListeners();
        return true;
      }

      _status = LoginStatus.error;
      _errorMessage = 'Authentication failed. Please check your credentials.';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("DEBUG AUTH: Firebase Auth Exception caught in outer handler: code='${e.code}', message='${e.message}'");
      _status = LoginStatus.error;
      if (e.code == 'user-not-found') {
        _errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        _errorMessage = 'Invalid email or password. Please verify credentials.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'The email address is badly formatted.';
      } else if (e.code == 'user-disabled') {
        _errorMessage = 'This user account has been disabled.';
      } else if (e.code == 'operation-not-allowed') {
        _errorMessage = 'Email/Password login is disabled in Firebase Console. Please enable it under Authentication > Sign-in method.';
      } else {
        _errorMessage = e.message ?? 'Authentication failed.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("DEBUG AUTH: Unexpected exception caught in outer handler: $e");
      _status = LoginStatus.error;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = LoginStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
