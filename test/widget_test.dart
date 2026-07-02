import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_managementsystem/main.dart';
import 'package:library_managementsystem/core/utils/result.dart';
import 'package:library_managementsystem/features/auth/application/auth_provider.dart';
import 'package:library_managementsystem/features/auth/domain/repositories/auth_repository.dart';
import 'package:library_managementsystem/features/auth/domain/models/user_model.dart';
import 'package:library_managementsystem/features/auth/domain/models/user_role.dart';
import 'package:library_managementsystem/features/onboarding/application/onboarding_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifierMock()),
          onboardingProvider.overrideWith((ref) => OnboardingNotifierMock()),
        ],
        child: const LibreFlowApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class AuthNotifierMock extends AuthNotifier {
  AuthNotifierMock() : super(DummyAuthRepository());

  @override
  Future<void> _restoreSession() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

class OnboardingNotifierMock extends OnboardingNotifier {
  @override
  Future<void> _init() async {
    state = true;
  }
}

class DummyAuthRepository implements AuthRepository {
  @override
  Future<Result<UserModel>> login({
    required String email,
    required String password,
    required UserRole role,
    bool rememberMe = false,
  }) async {
    return const Failure('Mock not implemented');
  }

  @override
  Future<Result<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    return const Failure('Mock not implemented');
  }

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<UserModel?>> restoreSession() async => const Success(null);

  @override
  Future<Result<void>> sendPasswordReset(String email) async => const Success(null);

  @override
  Future<Result<bool>> verifyOtp(String code) async => const Success(true);

  @override
  Future<Result<UserModel>> updateProfile({
    required String name,
    required String email,
  }) async {
    return const Failure('Mock not implemented');
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return const Success(null);
  }
}
