import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/domain/models/user_role.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/onboarding/application/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/librarian_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/books/presentation/screens/add_book_screen.dart';
import '../../features/books/presentation/screens/book_detail_screen.dart';
import '../../features/books/presentation/screens/books_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/module_placeholder.dart';
import 'route_names.dart';

/// A [Listenable] bridge so [GoRouter] refreshes its redirect logic whenever
/// Riverpod's [authProvider] state changes (login/logout/session restore).
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(onboardingProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthRefreshListenable(ref);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final onboardingSeen = ref.read(onboardingProvider);
      
      final atSplash = state.matchedLocation == RoutePaths.splash;
      final atOnboarding = state.matchedLocation == RoutePaths.onboarding;

      if (!onboardingSeen && !atSplash && !atOnboarding) {
        return RoutePaths.onboarding;
      }

      final loggingIn = {
        RoutePaths.login,
        RoutePaths.register,
        RoutePaths.forgotPassword,
        RoutePaths.otp,
        RoutePaths.onboarding,
      }.contains(state.matchedLocation);

      switch (authState.status) {
        case AuthStatus.unknown:
          return atSplash ? null : RoutePaths.splash;
        case AuthStatus.unauthenticated:
          if (atOnboarding && !onboardingSeen) return null;
          return loggingIn ? null : RoutePaths.login;
        case AuthStatus.authenticated:
          return (loggingIn || atSplash) ? RoutePaths.dashboard : null;
      }
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.otp,
        name: RouteNames.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                name: RouteNames.dashboard,
                builder: (context, state) => const _RoleDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.catalog,
                name: RouteNames.catalog,
                builder: (context, state) => const BooksScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add_book',
                    builder: (context, state) => const AddBookScreen(),
                  ),
                  GoRoute(
                    path: 'details/:id',
                    name: 'book_details',
                    builder: (context, state) => BookDetailScreen(
                      bookId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.activity,
                name: RouteNames.activity,
                builder: (context, state) => const ModulePlaceholder(
                  title: 'Activity',
                  description:
                      'Issue / return history, fines, reservations and QR '
                      'check-in/out will appear here once that module is built.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Renders the correct dashboard screen for the current user's role.
class _RoleDashboard extends ConsumerWidget {
  const _RoleDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role;
    switch (role) {
      case UserRole.admin:
        return const AdminDashboardScreen();
      case UserRole.librarian:
        return const LibrarianDashboardScreen();
      case UserRole.teacher:
        return const TeacherDashboardScreen();
      case UserRole.student:
      case null:
        return const StudentDashboardScreen();
    }
  }
}
