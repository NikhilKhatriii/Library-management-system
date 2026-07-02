import '../../../../core/utils/result.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._localDataSource);

  @override
  Future<Result<UserModel>> login({
    required String email,
    required String password,
    required UserRole role,
    bool rememberMe = false,
  }) async {
    try {
      // Simulate network delay
      await Future<void>.delayed(const Duration(milliseconds: 900));

      // Mock login logic moved to data layer
      final namePart = email.split('@').first.replaceAll('.', ' ');
      final displayName = namePart
          .split(' ')
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');

      final user = UserModel(
        id: email.hashCode.toString(),
        name: displayName.isEmpty ? 'LibreFlow User' : displayName,
        email: email,
        role: role,
        membershipNumber: role == UserRole.student || role == UserRole.teacher
            ? 'LF-${1000 + email.hashCode.abs() % 9000}'
            : null,
      );

      await _localDataSource.saveUser(user);
      await _localDataSource.saveRememberMe(rememberMe);
      return Success(user);
    } catch (e) {
      return Failure('Login failed', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
      );

      await _localDataSource.saveUser(user);
      return Success(user);
    } catch (e) {
      return Failure('Registration failed', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _localDataSource.clearUser();
      await _localDataSource.saveRememberMe(false);
      return const Success(null);
    } catch (e) {
      return Failure('Logout failed', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<UserModel?>> restoreSession() async {
    try {
      final rememberMe = await _localDataSource.getRememberMe();
      if (!rememberMe) return const Success(null);
      
      final user = await _localDataSource.getUser();
      return Success(user);
    } catch (e) {
      return Failure('Session restoration failed', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      return const Success(null);
    } catch (e) {
      return Failure('Failed to send reset email', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<bool>> verifyOtp(String code) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return Success(code.length == 6);
    } catch (e) {
      return Failure('OTP verification failed', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<UserModel>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final currentUser = await _localDataSource.getUser();
      if (currentUser == null) {
        return const Failure('No user session found');
      }

      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
      );

      await _localDataSource.saveUser(updatedUser);
      return Success(updatedUser);
    } catch (e) {
      return Failure('Failed to update profile', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return const Success(null);
    } catch (e) {
      return Failure('Failed to change password', e is Exception ? e : Exception(e.toString()));
    }
  }
}
