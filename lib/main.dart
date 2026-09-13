import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/config/supabase_config.dart';
import 'data/repositories/supabase_apply_repository.dart';
import 'data/repositories/application_repository.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/apply_data_provider.dart';
import 'providers/draft_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/application_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'widgets/friendly_error_view.dart';
import 'core/theme/always_scrollbar_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (details) => FriendlyErrorView(details: details);

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  // Try to initialize Firebase first (needed by the notification service).
  try {
    await Firebase.initializeApp();
    // Notification permission prompt / channel setup does not need to block
    // the first frame — run it in the background to reduce launch time.
    unawaited(NotificationService.instance.initialize());
  } catch (e) {
    // ignore: avoid_print
    print('[Main] Firebase initialization warning: $e');
  }

  final applyRepository = SupabaseApplyRepository();
  final applicationRepository = ApplicationRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadPreferences(),
        ),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..init()),
        ChangeNotifierProvider(
          create: (_) => ApplyDataProvider(applyRepository),
        ),
        ChangeNotifierProxyProvider<ApplyDataProvider, DraftProvider>(
          create: (_) => DraftProvider(),
          update: (_, applyDataProvider, draftProvider) {
            if (draftProvider != null) {
              draftProvider.setApplyDataProvider(applyDataProvider);
            }
            return draftProvider ?? DraftProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            authProvider.listenToAuthChanges();
            return authProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ApplicationProvider(applicationRepository),
        ),
      ],
      child: const NyayaSaathiApp(),
    ),
  );
}

class NyayaSaathiApp extends StatelessWidget {
  const NyayaSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      navigatorKey: NotificationService.instance.navigatorKey,
      title: 'Nyaya Saathi',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AlwaysScrollbarBehavior(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.15),
          ),
          child: child!,
        );
      },
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme(themeProvider.fontScale),
      darkTheme: AppTheme.darkTheme(themeProvider.fontScale),
      locale: langProvider.locale,
      supportedLocales: const [Locale('en', ''), Locale('ne', '')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
