import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/core/utils/phone_utils.dart';
import 'package:nyaya_saathi/widgets/quick_apply_choice_modal.dart';
import 'package:nyaya_saathi/screens/citizen/quick_apply_screen.dart';
import 'package:nyaya_saathi/screens/citizen/tabs/home_tab.dart';
import 'package:nyaya_saathi/providers/theme_provider.dart';
import 'package:nyaya_saathi/providers/language_provider.dart';
import 'package:nyaya_saathi/providers/auth_provider.dart';
import 'package:nyaya_saathi/providers/apply_data_provider.dart';
import 'package:nyaya_saathi/providers/draft_provider.dart';
import 'package:nyaya_saathi/providers/application_provider.dart';
import 'package:nyaya_saathi/data/repositories/application_repository.dart';
import 'package:nyaya_saathi/data/repositories/local_apply_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DraftProvider()),
        ChangeNotifierProvider(
          create: (_) => ApplicationProvider(ApplicationRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ApplyDataProvider(LocalApplyRepository()),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('Quick Apply Two Methods Tests', () {
    test('PhoneUtils defines correct NALSA helpline number', () {
      expect(PhoneUtils.nalsaHelplineNumber, '15100');
    });

    test('PhoneUtils formats Indian mobile numbers for display', () {
      expect(PhoneUtils.formatForDisplay('9876543210'), '+91 98765 43210');
      expect(PhoneUtils.formatForDisplay('+919876543210'), '+91 98765 43210');
      expect(PhoneUtils.formatForDisplay('919876543210'), '+91 98765 43210');
    });

    testWidgets('QuickApplyChoiceModal displays both Method 1 and Method 2', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => QuickApplyChoiceModal.show(ctx),
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Check title and methods
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains('Quick Apply') == true ||
                  w.data?.contains('quick_apply_choice_title') == true),
        ),
        findsWidgets,
      );

      // Method 1: Dial 15100
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains('15100') == true ||
                  w.data?.contains('Dial') == true ||
                  w.data?.contains('quick_apply_dial') == true),
        ),
        findsWidgets,
      );

      // Method 2: Callback / Form
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains('Callback') == true ||
                  w.data?.contains('Form') == true ||
                  w.data?.contains('quick_apply_form') == true),
        ),
        findsWidgets,
      );
    });

    testWidgets('HomeTab renders two independent Quick Apply action cards', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createWidgetUnderTest(
          child: const HomeTab(),
        ),
      );
      await tester.pumpAndSettle();

      // Action 1: Call NALSA Helpline (15100) card
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains('15100') == true ||
                  w.data?.contains('Call NALSA') == true ||
                  w.data?.contains('call_nalsa_title') == true),
        ),
        findsWidgets,
      );

      // Action 2: Request a Callback card
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains('Request a Callback') == true ||
                  w.data?.contains('request_callback_title') == true),
        ),
        findsWidgets,
      );
    });

    testWidgets('QuickApplyScreen does NOT display duplicate NALSA helpline card', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: const QuickApplyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that the duplicate 15100 card is absent from the callback form screen
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.data?.contains('15100') == true,
        ),
        findsNothing,
      );

      // Verify Request a Callback title is present
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains('Request a Callback') == true ||
                  w.data?.contains('request_callback_title') == true),
        ),
        findsWidgets,
      );
    });
  });
}
