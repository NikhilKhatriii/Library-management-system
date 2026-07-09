import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/domain/models/user_model.dart';
import 'features/auth/domain/models/user_role.dart';
import 'features/books/domain/models/book.dart';
import 'features/members/domain/models/member_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await Hive.initFlutter();
  
  // Register ALL Hive Adapters
  Hive.registerAdapter(UserRoleAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(BookStatusAdapter());
  Hive.registerAdapter(BookConditionAdapter());
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(MemberStatusAdapter());
  Hive.registerAdapter(MemberTypeAdapter());
  Hive.registerAdapter(MemberModelAdapter());

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
