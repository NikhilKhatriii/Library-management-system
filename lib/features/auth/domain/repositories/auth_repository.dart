import '../../../../core/utils/result.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

abstract interface class AuthRepository {
  Future<Result<UserModel>> login({
    required String email,
    required String password,
    required UserRole role,
    bool rememberMe = false,
  });

  Future<Result<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<Result<void>> logout();

  Future<Result<UserModel?>> restoreSession();

  Future<Result<void>> sendPasswordReset(String email);

  Future<Result<bool>> verifyOtp(String code);

  Future<Result<UserModel>> updateProfile({
    required String name,
    required String email,
  });

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
