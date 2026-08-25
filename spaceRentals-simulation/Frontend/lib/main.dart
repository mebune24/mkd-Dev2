import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'providers/locale_provider.dart';
import 'widgets/error_boundary.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow runtime fetching so google_fonts can load Inter variants from network
  // GoogleFonts.config.allowRuntimeFetching = false;
  setupGlobalErrorHandling();
  runApp(
    const ProviderScope(
      child: SpaceRentalsApp(),
    ),
  );
}

class SpaceRentalsApp extends ConsumerWidget {
  const SpaceRentalsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'SpaceRentals',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
