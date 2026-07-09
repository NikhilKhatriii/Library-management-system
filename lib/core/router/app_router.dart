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
import '../../features/members/presentation/screens/members_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
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
        pageBuilder: (context, state) => buildAppleTransitionPage(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => buildAppleTransitionPage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => buildAppleTransitionPage(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        pageBuilder: (context, state) => buildAppleTransitionPage(
          context: context,
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) => buildAppleTransitionPage(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.otp,
        name: RouteNames.otp,
        pageBuilder: (context, state) => buildAppleTransitionPage(
          context: context,
          state: state,
          child: const OtpScreen(),
        ),
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
                pageBuilder: (context, state) => buildAppleTransitionPage(
                  context: context,
                  state: state,
                  child: const _RoleDashboard(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.catalog,
                name: RouteNames.catalog,
                pageBuilder: (context, state) => buildAppleTransitionPage(
                  context: context,
                  state: state,
                  child: const BooksScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add_book',
                    pageBuilder: (context, state) => buildAppleTransitionPage(
                      context: context,
                      state: state,
                      child: const AddBookScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'details/:id',
                    name: 'book_details',
                    pageBuilder: (context, state) => buildAppleTransitionPage(
                      context: context,
                      state: state,
                      child: BookDetailScreen(
                        bookId: state.pathParameters['id']!,
                      ),
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
                pageBuilder: (context, state) => buildAppleTransitionPage(
                  context: context,
                  state: state,
                  child: const ActivityScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                pageBuilder: (context, state) => buildAppleTransitionPage(
                  context: context,
                  state: state,
                  child: const ProfileScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.members,
                name: RouteNames.members,
                pageBuilder: (context, state) => buildAppleTransitionPage(
                  context: context,
                  state: state,
                  child: const MembersScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.reports,
                name: RouteNames.reports,
                pageBuilder: (context, state) => buildAppleTransitionPage(
                  context: context,
                  state: state,
                  child: const ReportsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Premium Apple-inspired transition: zoom scale zoom-in/out combined with cross-fade.
CustomTransitionPage<T> buildAppleTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurveTween(curve: Curves.easeInOutCubic);
      return FadeTransition(
        opacity: animation.drive(curve),
        child: ScaleTransition(
          scale: animation.drive(Tween<double>(begin: 0.96, end: 1.0).chain(curve)),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
  );
}

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
