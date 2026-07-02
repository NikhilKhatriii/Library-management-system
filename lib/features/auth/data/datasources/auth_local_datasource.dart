import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<void> saveRememberMe(bool rememberMe);
  Future<bool> getRememberMe();
}

class HiveAuthLocalDataSource implements AuthLocalDataSource {
  static const String _boxName = 'auth_box';
  static const String _userKey = 'current_user';
  static const String _rememberMeKey = 'remember_me';

  @override
  Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_userKey, user);
  }

  @override
  Future<UserModel?> getUser() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_userKey) as UserModel?;
  }

  @override
  Future<void> clearUser() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_userKey);
  }

  @override
  Future<void> saveRememberMe(bool rememberMe) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_rememberMeKey, rememberMe);
  }

  @override
  Future<bool> getRememberMe() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_rememberMeKey, defaultValue: false) as bool;
  }
}
