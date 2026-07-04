import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/models/user_model.dart';
import '../domain/models/user_role.dart';
import '../domain/repositories/auth_repository.dart';

/// Authentication status used to drive [GoRouter] redirects.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(HiveAuthLocalDataSource());
});

/// Handles authentication for the app.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState()) {
    _restoreSession();
  }

  final AuthRepository _repository;

  Future<void> _restoreSession() async {
    final result = await _repository.restoreSession();
    
    if (result is Success<UserModel?> && result.data != null) {
      state = state.copyWith(status: AuthStatus.authenticated, user: result.data);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required UserRole role,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.login(
      email: email,
      password: password,
      role: role,
      rememberMe: rememberMe,
    );

    if (result is Success<UserModel>) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.data,
        isLoading: false,
      );
    } else if (result is Failure<UserModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    if (result is Success<UserModel>) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.data,
        isLoading: false,
      );
    } else if (result is Failure<UserModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.sendPasswordReset(email);
    state = state.copyWith(
      isLoading: false,
      errorMessage: result is Failure ? result.message : null,
    );
  }

  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.verifyOtp(code);
    state = state.copyWith(isLoading: false);
    
    if (result is Success<bool>) {
      return result.data;
    }
    return false;
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<Result<UserModel>> updateProfile({
    required String name,
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updateProfile(name: name, email: email);
    if (result is Success<UserModel>) {
      state = state.copyWith(
        user: result.data,
        isLoading: false,
      );
    } else if (result is Failure<UserModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
    }
    return result;
  }

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    state = state.copyWith(isLoading: false);
    if (result is Failure) {
      state = state.copyWith(errorMessage: result.message);
    }
    return result;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
