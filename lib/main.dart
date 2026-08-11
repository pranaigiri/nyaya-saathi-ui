import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/supabase_service.dart';
import 'data/repositories/local_apply_repository.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/apply_data_provider.dart';
import 'providers/draft_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadPreferences()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..init()),
        ChangeNotifierProvider(create: (_) => ApplyDataProvider(LocalApplyRepository())),
        ChangeNotifierProxyProvider<ApplyDataProvider, DraftProvider>(
          create: (_) => DraftProvider(),
          update: (_, applyDataProvider, draftProvider) {
            if (draftProvider != null) {
              draftProvider.setApplyDataProvider(applyDataProvider);
            }
            return draftProvider ?? DraftProvider();
          },
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
      title: 'Nyaya Saathi',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme(themeProvider.fontScale),
      darkTheme: AppTheme.darkTheme(themeProvider.fontScale),
      locale: langProvider.locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ne', ''),
      ],
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
