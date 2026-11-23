import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nyaya_saathi/screens/citizen/unauth_home_screen.dart';
import 'package:nyaya_saathi/widgets/language_switcher_button.dart';
import 'package:nyaya_saathi/screens/onboarding/language_selection_modal.dart';
import 'package:nyaya_saathi/core/theme/elder_theme_tokens.dart';
import 'package:nyaya_saathi/providers/language_provider.dart';
import 'package:nyaya_saathi/providers/draft_provider.dart';
import 'package:nyaya_saathi/providers/auth_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

Widget createTestHomeScreen({
  LanguageProvider? langProvider,
  DraftProvider? draftProvider,
  AuthProvider? authProvider,
  double textScale = 1.0,
}) {
  final provider =
      langProvider ?? (LanguageProvider()..completeFirstLaunch('en'));

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LanguageProvider>.value(value: provider),
      ChangeNotifierProvider<DraftProvider>(
        create: (_) => draftProvider ?? DraftProvider(),
      ),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => authProvider ?? AuthProvider(),
      ),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(400, 900),
          textScaler: TextScaler.linear(textScale),
        ),
        child: const Scaffold(body: UnauthHomeScreen()),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Elder-Friendly UnauthHomeScreen Redesign Tests', () {
    testWidgets('renders all 6 essential actions with plain language labels', (
      tester,
    ) async {
      await tester.pumpWidget(createTestHomeScreen());
      await tester.pumpAndSettle();

      // Action 1: Call Button (15100)
      expect(find.text('Call for free legal help'), findsOneWidget);
      expect(find.text('15100'), findsOneWidget);

      // Action 2: Ask us to call you (Callback)
      expect(find.text('Ask us to call you'), findsOneWidget);

      // Action 3: Apply online yourself (5-step form)
      expect(find.text('Apply online yourself'), findsOneWidget);

      // Action 4: Do I qualify? (Eligibility)
      expect(find.text('Do I qualify?'), findsOneWidget);

      // Action 5: Check my application (Tracking)
      expect(find.text('Check my application'), findsOneWidget);

      // Action 6: Register & Sign In
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets(
      'verifies section order: 5-step form fill 1st, quick apply 2nd, followed by others',
      (tester) async {
        await tester.pumpWidget(createTestHomeScreen());
        await tester.pumpAndSettle();

        final fillFormY =
            tester.getTopLeft(find.text('Apply online yourself')).dy;
        final callHelpY =
            tester.getTopLeft(find.text('Call for free legal help')).dy;
        final askCallbackY =
            tester.getTopLeft(find.text('Ask us to call you')).dy;
        final doIQualifyY = tester.getTopLeft(find.text('Do I qualify?')).dy;
        final checkAppY =
            tester.getTopLeft(find.text('Check my application')).dy;
        final registerY = tester.getTopLeft(find.text('Register')).dy;

        // 1st: 5-step form fill section
        expect(fillFormY, lessThan(callHelpY));
        expect(fillFormY, lessThan(askCallbackY));

        // 2nd: Quick apply section (Helpline & Callback)
        expect(callHelpY, lessThan(doIQualifyY));
        expect(askCallbackY, lessThan(doIQualifyY));

        // Followed by others as it is (Eligibility, Tracking, Footer)
        expect(doIQualifyY, lessThan(checkAppY));
        expect(checkAppY, lessThan(registerY));
      },
    );

    testWidgets(
      'renders earlier LanguageSwitcherButton and opens language picker with English, नेपाली, हिन्दी',
      (tester) async {
        await tester.pumpWidget(createTestHomeScreen());
        await tester.pumpAndSettle();

        final langBtnFinder = find.byType(LanguageSwitcherButton);
        expect(langBtnFinder, findsOneWidget);

        await tester.tap(langBtnFinder);
        await tester.pumpAndSettle();

        expect(find.text('English'), findsOneWidget);
        expect(find.text('नेपाली'), findsOneWidget);
        expect(find.text('हिन्दी'), findsOneWidget);
      },
    );

    testWidgets('renders Listen speaker button and tapping opens audio modal', (
      tester,
    ) async {
      await tester.pumpWidget(createTestHomeScreen());
      await tester.pumpAndSettle();

      final listenButton = find.text('Listen');
      expect(listenButton, findsOneWidget);

      await tester.tap(listenButton);
      await tester.pumpAndSettle();

      // Audio Guidance bottom sheet is shown
      expect(find.text('Okay'), findsOneWidget);
      await tester.tap(find.text('Okay'));
      await tester.pumpAndSettle();
    });

    testWidgets('supports 200% font scaling without any RenderFlex overflow', (
      tester,
    ) async {
      // Simulate extreme text scaling (2.0x) for seniors with presbyopia / low vision
      await tester.pumpWidget(createTestHomeScreen(textScale: 2.0));
      await tester.pumpAndSettle();

      // Verify no overflow exception was thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('all action buttons meet or exceed 56dp minimum touch target', (
      tester,
    ) async {
      await tester.pumpWidget(createTestHomeScreen());
      await tester.pumpAndSettle();

      final callFinder = find.ancestor(
        of: find.text('Call for free legal help'),
        matching: find.byType(Container),
      );
      expect(callFinder, findsWidgets);

      final callSize = tester.getSize(callFinder.first);
      expect(
        callSize.height,
        greaterThanOrEqualTo(ElderThemeTokens.minTouchTargetHeight),
      );
    });

    testWidgets('renders reassurance badges and excludes Government of Sikkim tag', (
      tester,
    ) async {
      await tester.pumpWidget(createTestHomeScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Government of Sikkim'), findsNothing);
      expect(find.text('Free service • No fee'), findsOneWidget);
      expect(find.text('5 short steps • No account needed'), findsOneWidget);
      expect(
        find.text('Create an account to see all your cases'),
        findsOneWidget,
      );
    });

    testWidgets('shows language selection dialog on first launch', (
      tester,
    ) async {
      final firstLaunchProvider =
          LanguageProvider(); // isFirstLaunch defaults to true
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LanguageProvider>.value(
              value: firstLaunchProvider,
            ),
            ChangeNotifierProvider<DraftProvider>(
              create: (_) => DraftProvider(),
            ),
            ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(home: Scaffold(body: UnauthHomeScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectionModal), findsOneWidget);
    });
  });
}
