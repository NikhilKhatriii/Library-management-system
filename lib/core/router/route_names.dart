/// String identifiers for every named route in the app. Keeping these in
/// one place avoids typo-driven navigation bugs and makes refactors safe.
abstract final class RouteNames {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String otp = 'otp';

  static const String dashboard = 'dashboard';
  static const String catalog = 'catalog';
  static const String activity = 'activity';
  static const String profile = 'profile';
  static const String members = 'members';
  static const String reports = 'reports';
}

abstract final class RoutePaths {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';

  static const String dashboard = '/dashboard';
  static const String catalog = '/catalog';
  static const String activity = '/activity';
  static const String profile = '/profile';
  static const String members = '/members';
  static const String reports = '/reports';
}
