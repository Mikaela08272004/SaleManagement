import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;
  AuthProvider._internal();

  static const String _userBoxName = 'users';
  static const String _currentUserKey = 'current_user';
  Box<User>? _userBox;
  User? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  User? get currentUser => _currentUser;

  // Initialize Hive and open boxes
  Future<void> initialize() async {
    if (_userBox != null) return; // Already initialized

    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    _userBox = await Hive.openBox<User>(_userBoxName);
    
    // Try to restore current user session
    _currentUser = _userBox?.get(_currentUserKey);
    notifyListeners();
    printRegisteredUsers(); // Debug: Print users on initialization
  }

  Future<bool> register(String username, String password) async {
    await _ensureInitialized();

    try {
      // Check if username already exists in registered users
      final existingUsers = _userBox!.values.toList();
      if (existingUsers.any((user) => user.username.toLowerCase() == username.toLowerCase())) {
        print('Username already exists: $username');
        return false;
      }

      // Create new user with unique key
      final user = User(username: username, password: password);
      final key = 'user_${user.id}';
      await _userBox!.put(key, user);
      
      print('User registered successfully: $username');
      printRegisteredUsers(); // Debug: Print users after registration
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    await _ensureInitialized();

    try {
      print('Attempting login for username: $username'); // Debug
      printRegisteredUsers(); // Debug: Print all users before login attempt

      final allUsers = _userBox!.values.toList();
      
      final matchingUser = allUsers.firstWhere(
        (user) => user.username.toLowerCase() == username.toLowerCase() && user.password == password,
        orElse: () => User(username: '', password: ''),
      );

      if (matchingUser.username.isEmpty) {
        print('Login failed: Invalid credentials for $username');
        return false;
      }

      // Create a new instance for current user storage
      final newCurrentUser = User(
        username: matchingUser.username,
        password: matchingUser.password,
        id: matchingUser.id,
      );
      
      await _userBox!.put(_currentUserKey, newCurrentUser);
      _currentUser = newCurrentUser;
      print('Login successful for user: $username');
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _ensureInitialized();
    if (_currentUser != null) {
      print('Logging out user: ${_currentUser!.username}');
      await _userBox?.delete(_currentUserKey);
    }
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (_userBox == null) {
      await initialize();
    }
  }

  // Debug method to check registered users
  void printRegisteredUsers() {
    final users = _userBox?.values.toList() ?? [];
    print('=== Registered Users ===');
    if (users.isEmpty) {
      print('No users registered');
    } else {
      for (var user in users) {
        print('Username: ${user.username} (ID: ${user.id})');
      }
    }
    print('=====================');
  }

  // Debug method to clear all users (use carefully!)
  Future<void> clearAllUsers() async {
    await _ensureInitialized();
    await _userBox?.clear();
    _currentUser = null;
    notifyListeners();
    print('All users cleared');
  }
} 