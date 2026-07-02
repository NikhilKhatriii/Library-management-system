import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/models/user_model.dart';
import '../domain/models/user_role.dart';

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

/// Handles authentication for the app.
///
/// NOTE: This currently uses an in-memory + SharedPreferences mock backend
/// so the UI is fully interactive out of the box. Swap [_mockNetworkLogin]
/// for a real repository call once the REST API is available — the rest of
/// the app only depends on this provider's public interface, so no other
/// code needs to change.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(StorageKeys.rememberMe) ?? false;
    final rawUser = prefs.getString(StorageKeys.currentUser);

    if (remember && rawUser != null) {
      final user = UserModel.fromJson(
        jsonDecode(rawUser) as Map<String, dynamic>,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
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
    final user = await _mockNetworkLogin(email: email, role: role);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.rememberMe, rememberMe);
    await prefs.setString(
      StorageKeys.currentUser,
      jsonEncode(user.toJson()),
    );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: role,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.rememberMe, true);
    await prefs.setString(
      StorageKeys.currentUser,
      jsonEncode(user.toJson()),
    );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    state = state.copyWith(isLoading: false);
  }

  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isLoading: false);
    return code.length == 6;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.currentUser);
    await prefs.setBool(StorageKeys.rememberMe, false);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<UserModel> _mockNetworkLogin({
    required String email,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final namePart = email.split('@').first.replaceAll('.', ' ');
    final displayName = namePart
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

    return UserModel(
      id: email.hashCode.toString(),
      name: displayName.isEmpty ? 'LibreFlow User' : displayName,
      email: email,
      role: role,
      membershipNumber: role == UserRole.student || role == UserRole.teacher
          ? 'LF-${1000 + email.hashCode.abs() % 9000}'
          : null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
