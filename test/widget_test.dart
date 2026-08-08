import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi_ui/main.dart';
import 'package:nyaya_saathi_ui/providers/theme_provider.dart';
import 'package:nyaya_saathi_ui/providers/language_provider.dart';
import 'package:nyaya_saathi_ui/providers/draft_provider.dart';
import 'package:nyaya_saathi_ui/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App initializes smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => DraftProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const NyayaSaathiApp(),
      ),
    );
    expect(find.byType(NyayaSaathiApp), findsOneWidget);
  });
}
