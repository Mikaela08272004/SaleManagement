import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'auth_provider.dart';

abstract class BaseProvider<T> extends ChangeNotifier {
  final String boxName;
  final AuthProvider _authProvider = AuthProvider();
  Box<T>? _box;

  BaseProvider(this.boxName);

  // Get the current user's ID for data isolation
  String? get _currentUserId {
    final user = _authProvider.currentUser;
    if (user == null) {
      debugPrint('No user logged in');
      return null;
    }
    return user.id;
  }

  // Generate a user-specific key for data storage
  String _getUserKey(String key) {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('No user logged in');
    }
    return 'user_${userId}_$key';
  }

  // Initialize the box
  Future<void> initialize() async {
    if (_box != null) return;

    try {
      _box = await Hive.openBox<T>(boxName);
      debugPrint('Initialized box: $boxName');
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing box $boxName: $e');
      rethrow;
    }
  }

  // Store data with user-specific key
  Future<void> put(String key, T value) async {
    try {
      await initialize();
      if (_box == null) {
        throw Exception('Box not initialized');
      }

      final userKey = _getUserKey(key);
      await _box!.put(userKey, value);
      debugPrint('Stored data with key: $userKey');
      notifyListeners();
    } catch (e) {
      debugPrint('Error storing data: $e');
      rethrow;
    }
  }

  // Get data with user-specific key
  T? get(String key) {
    try {
      if (_box == null) {
        debugPrint('Box not initialized');
        return null;
      }

      final userKey = _getUserKey(key);
      return _box!.get(userKey);
    } catch (e) {
      debugPrint('Error getting data: $e');
      return null;
    }
  }

  // Get all values for current user
  List<T> getAllForCurrentUser() {
    try {
      if (_box == null) {
        debugPrint('Box not initialized');
        return [];
      }

      final userId = _currentUserId;
      if (userId == null) {
        debugPrint('No user logged in');
        return [];
      }

      final prefix = 'user_${userId}_';
      final values = _box!.keys
          .where((key) => key.toString().startsWith(prefix))
          .map((key) => _box!.get(key))
          .whereType<T>()
          .toList();

      debugPrint('Retrieved ${values.length} items for user $userId');
      return values;
    } catch (e) {
      debugPrint('Error getting all data: $e');
      return [];
    }
  }

  // Delete data with user-specific key
  Future<void> delete(String key) async {
    try {
      if (_box == null) {
        throw Exception('Box not initialized');
      }

      final userKey = _getUserKey(key);
      await _box!.delete(userKey);
      debugPrint('Deleted data with key: $userKey');
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting data: $e');
      rethrow;
    }
  }

  // Clear all data for current user
  Future<void> clearUserData() async {
    try {
      if (_box == null) {
        throw Exception('Box not initialized');
      }

      final userId = _currentUserId;
      if (userId == null) return;

      final prefix = 'user_${userId}_';
      final keysToDelete = _box!.keys
          .where((key) => key.toString().startsWith(prefix))
          .toList();

      for (final key in keysToDelete) {
        await _box!.delete(key);
      }
      debugPrint('Cleared all data for user $userId');
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      rethrow;
    }
  }

  // Close the box
  Future<void> close() async {
    try {
      await _box?.close();
      _box = null;
      debugPrint('Closed box: $boxName');
      notifyListeners();
    } catch (e) {
      debugPrint('Error closing box: $e');
      rethrow;
    }
  }
} 