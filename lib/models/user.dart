import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String username;
  
  @HiveField(1)
  final String password;
  
  @HiveField(2)
  final String id;

  User({
    required this.username,
    required this.password,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Create a copy of the user with optional new values
  User copyWith({
    String? username,
    String? password,
    String? id,
  }) {
    return User(
      username: username ?? this.username,
      password: password ?? this.password,
      id: id ?? this.id,
    );
  }

  @override
  String toString() => 'User(username: $username)';
} 