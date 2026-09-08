import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'providers/locale_provider.dart';
import 'widgets/error_boundary.dart';
import 'widgets/logo_watermark.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final initialLocale = await LocaleNotifier.loadPersistedLocale();
  // Allow runtime fetching so google_fonts can load Inter variants from network
  // GoogleFonts.config.allowRuntimeFetching = false;
  setupGlobalErrorHandling();
  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith(() => LocaleNotifier(initialLocale)),
      ],
      child: const SpaceRentalsApp(),
    ),
  );
}

class SpaceRentalsApp extends ConsumerWidget {
  const SpaceRentalsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(goRouterProvider);
    final currentPath = router.routerDelegate.currentConfiguration.uri.path;
    final showWatermark = currentPath != '/tenant' && currentPath != '/splash';
    return MaterialApp.router(
      title: 'SpaceRentals',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          if (child != null) child,
          if (showWatermark) const LogoWatermark(),
        ],
      ),
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
