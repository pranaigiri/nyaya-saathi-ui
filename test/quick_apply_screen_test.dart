import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi/screens/citizen/quick_apply_screen.dart';
import 'package:nyaya_saathi/providers/auth_provider.dart';
import 'package:nyaya_saathi/providers/theme_provider.dart';
import 'package:nyaya_saathi/providers/language_provider.dart';
import 'package:nyaya_saathi/providers/apply_data_provider.dart';
import 'package:nyaya_saathi/data/repositories/local_apply_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ApplyDataProvider(LocalApplyRepository())),
      ],
      child: const MaterialApp(
        home: QuickApplyScreen(),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('QuickApplyScreen Widget Tests', () {
    testWidgets('renders all essential Quick Apply form elements', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check title header presence
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && (w.data?.contains('Quick Apply') == true || w.data?.contains('quick_apply_title') == true),
        ),
        findsWidgets,
      );

      // Check visible input fields exist
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows validation error on empty phone submission', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ensure submit button is in view and tap it without entering phone
      final submitButton = find.byType(ElevatedButton);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Form validation error should appear
      expect(find.text('Phone number is required'), findsOneWidget);
    });

    testWidgets('shows validation error when entering invalid phone prefix (e.g. 5xxxx)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter number starting with 5 into visible phone TextFormField (at index 0)
      final phoneField = find.byType(TextFormField).first;
      await tester.ensureVisible(phoneField);
      await tester.enterText(phoneField, '5123456789');
      await tester.pumpAndSettle();

      final submitButton = find.byType(ElevatedButton);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Mobile number must start with 6, 7, 8, or 9'), findsOneWidget);
    });

    testWidgets('honeypot field is offstage and excluded from semantics', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify honeypot is inside Visibility(visible: false, maintainState: true)
      final hiddenHoneypotFinder = find.byWidgetPredicate(
        (w) => w is Visibility && !w.visible && w.maintainState,
      );
      expect(hiddenHoneypotFinder, findsOneWidget);

      // Verify that ExcludeSemantics is used inside it (with skipOffstage: false)
      expect(
        find.byType(ExcludeSemantics, skipOffstage: false),
        findsWidgets,
      );
    });
  });
}
