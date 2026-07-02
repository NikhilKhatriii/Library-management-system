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
  static const double lg = 24; // Apple-like rounded corners
  static const double xl = 32;
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

  // Onboarding
  static const String onboardingTitle1 = 'Welcome to LibreFlow';
  static const String onboardingDesc1 = 'Manage your entire library from one intelligent workspace.';
  static const String onboardingTitle2 = 'Smart Book Management';
  static const String onboardingDesc2 = 'Easily organize thousands of books with categories, shelves, ISBN, QR codes, and advanced search.';
  static const String onboardingTitle3 = 'Issue & Return';
  static const String onboardingDesc3 = 'Issue books, return books, monitor overdue items, and manage fines effortlessly.';
  static const String onboardingTitle4 = 'Analytics & Reports';
  static const String onboardingDesc4 = 'Monitor library performance using beautiful dashboards, statistics, charts, and reports.';
  static const String onboardingTitle5 = 'Everything in One Place';
  static const String onboardingDesc5 = 'Members, books, reservations, staff, notifications, and reports—all managed from one modern application.';
}

abstract final class StorageKeys {
  static const String sessionToken = 'session_token';
  static const String rememberMe = 'remember_me';
  static const String currentUser = 'current_user';
  static const String themeMode = 'theme_mode';
  static const String onboardingSeen = 'onboarding_seen';
}
