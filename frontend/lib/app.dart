import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root application widget. Wires together theming (light + dark-mode-ready,
/// per the PDF's "Dark mode architecture prepared" requirement) and routing.
class FlacronSocialAutoApp extends ConsumerWidget {
  const FlacronSocialAutoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // MVP defaults to light mode regardless of system setting, per the
      // "clean, modern, white background" UI requirement — flip this to
      // ThemeMode.system once a user-facing dark mode toggle ships.
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
