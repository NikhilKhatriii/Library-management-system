import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/domain/models/user_model.dart';
import 'features/auth/domain/models/user_role.dart';
import 'firebase_options.dart';

/// Whether Firebase was successfully initialized.
/// Used by providers to choose between Firebase and mock backends.
bool firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await Hive.initFlutter();
  Hive.registerAdapter(UserRoleAdapter());
  Hive.registerAdapter(UserModelAdapter());

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (DefaultFirebaseOptions.currentPlatform.apiKey.contains('mock-key')) {
      firebaseInitialized = false;
      debugPrint('⚠️ Using mock API key, falling back to mock backends');
    } else {
      firebaseInitialized = true;
      debugPrint('✅ Firebase initialized successfully');
    }
  } catch (e) {
    firebaseInitialized = false;
    debugPrint('⚠️ Firebase init failed, using mock backends: $e');
  }

  runApp(const ProviderScope(child: LibreFlowApp()));
}

class LibreFlowApp extends ConsumerWidget {
  const LibreFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
