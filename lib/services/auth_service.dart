import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersBoxName = 'users';
  static const String _currentUserKey = 'current_user_id';
  static Box<User>? _usersBox;

  // Initialize
  static Future<void> init() async {
    Hive.registerAdapter(UserAdapter());
    _usersBox = await Hive.openBox<User>(_usersBoxName);
  }

  // Get users box
  static Box<User> get usersBox {
    if (_usersBox == null) {
      throw Exception('AuthService not initialized');
    }
    return _usersBox!;
  }

  // Hash password
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return {'success': false, 'message': 'Invalid email format'};
      }

      // Check if email already exists
      final existingUser = usersBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
        orElse: () => User(
          id: '',
          email: '',
          passwordHash: '',
          name: '',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        ),
      );

      if (existingUser.id.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Validate password strength
      if (password.length < 6) {
        return {'success': false, 'message': 'Password must be at least 6 characters'};
      }

      // Create new user
      final user = User(
        id: const Uuid().v4(),
        email: email.toLowerCase(),
        passwordHash: _hashPassword(password),
        name: name,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await usersBox.put(user.id, user);
      await _setCurrentUser(user.id);

      return {'success': true, 'message': 'Registration successful', 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Find user by email
      final user = usersBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
        orElse: () => User(
          id: '',
          email: '',
          passwordHash: '',
          name: '',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        ),
      );

      if (user.id.isEmpty) {
        return {'success': false, 'message': 'User not found'};
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        return {'success': false, 'message': 'Incorrect password'};
      }

      // Update last login
      user.lastLoginAt = DateTime.now();
      await user.save();

      await _setCurrentUser(user.id);

      return {'success': true, 'message': 'Login successful', 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await Hive.openBox('preferences');
    await prefs.delete(_currentUserKey);
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await Hive.openBox('preferences');
      final userId = prefs.get(_currentUserKey);
      
      if (userId == null) return null;
      
      return usersBox.get(userId);
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Set current user
  static Future<void> _setCurrentUser(String userId) async {
    final prefs = await Hive.openBox('preferences');
    await prefs.put(_currentUserKey, userId);
  }

  // Update user profile
  static Future<bool> updateProfile({
    required String userId,
    String? name,
  }) async {
    try {
      final user = usersBox.get(userId);
      if (user == null) return false;

      if (name != null) user.name = name;
      await user.save();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = usersBox.get(userId);
      if (user == null) {
        return {'success': false, 'message': 'User not found'};
      }

      // Verify old password
      final hashedOldPassword = _hashPassword(oldPassword);
      if (user.passwordHash != hashedOldPassword) {
        return {'success': false, 'message': 'Current password is incorrect'};
      }

      // Validate new password
      if (newPassword.length < 6) {
        return {'success': false, 'message': 'New password must be at least 6 characters'};
      }

      // Update password
      user.passwordHash = _hashPassword(newPassword);
      await user.save();

      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to change password: $e'};
    }
  }

  // Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Delete account
  static Future<bool> deleteAccount(String userId) async {
    try {
      await usersBox.delete(userId);
      await logout();
      return true;
    } catch (e) {
      return false;
    }
  }
}
