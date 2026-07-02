/// App-wide, non-color design tokens and static configuration.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);
}

abstract final class AppStrings {
  static const String appName = 'LibreFlow';
  static const String tagline = 'Your library, beautifully organized.';
}

abstract final class StorageKeys {
  static const String sessionToken = 'session_token';
  static const String rememberMe = 'remember_me';
  static const String currentUser = 'current_user';
  static const String themeMode = 'theme_mode';
  static const String onboardingSeen = 'onboarding_seen';
}
