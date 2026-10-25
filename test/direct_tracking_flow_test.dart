import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi/screens/citizen/tracking_screen.dart';
import 'package:nyaya_saathi/providers/auth_provider.dart';
import 'package:nyaya_saathi/providers/theme_provider.dart';
import 'package:nyaya_saathi/providers/language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTrackingScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MaterialApp(
        home: TrackingScreen(),
      ),
    );
  }

  group('Direct ID Tracking UI & Behavior Tests', () {
    testWidgets('Mode switcher displays By Phone, By District, and Direct ID tabs', (tester) async {
      await tester.pumpWidget(createTrackingScreen());
      await tester.pumpAndSettle();

      expect(find.text('By Phone'), findsOneWidget);
      expect(find.text('By District'), findsOneWidget);
      expect(find.text('Direct ID'), findsOneWidget);
    });

    testWidgets('Direct ID mode hides the Registered Mobile Number field entirely', (tester) async {
      await tester.pumpWidget(createTrackingScreen());
      await tester.pumpAndSettle();

      // Switch to Direct ID
      await tester.tap(find.text('Direct ID'));
      await tester.pumpAndSettle();

      // Main search input card for Direct ID should be visible
      expect(find.text('Instant Tracking Search'), findsOneWidget);
      expect(find.text('Full Tracking ID *'), findsOneWidget);

      // Registered Mobile Number field must NOT be present in Direct ID mode
      expect(find.text('Registered Mobile Number *'), findsNothing);
      expect(find.text('10-digit registered number (e.g. 9876543210)'), findsNothing);
    });

    testWidgets('By District mode retains the Registered Mobile Number field', (tester) async {
      await tester.pumpWidget(createTrackingScreen());
      await tester.pumpAndSettle();

      // Switch to By District
      await tester.tap(find.text('By District'));
      await tester.pumpAndSettle();

      // District selector and mobile number field should both be present
      expect(find.text('Select District'), findsOneWidget);
      expect(find.text('Registered Mobile Number *'), findsOneWidget);
    });

    testWidgets('Direct ID mode allows submitting without mobile number validation', (tester) async {
      await tester.pumpWidget(createTrackingScreen());
      await tester.pumpAndSettle();

      // Switch to Direct ID
      await tester.tap(find.text('Direct ID'));
      await tester.pumpAndSettle();

      // Fill in a valid tracking ID
      final trackingField = find.widgetWithText(TextFormField, 'Full Tracking ID *');
      expect(trackingField, findsOneWidget);
      await tester.enterText(trackingField, 'SK-GTK-26-00034');
      await tester.pumpAndSettle();

      // Tap Track button
      final trackButton = find.widgetWithIcon(ElevatedButton, Icons.search_rounded);
      expect(trackButton, findsOneWidget);
      await tester.tap(trackButton);
      await tester.pump();

      // Does NOT show "Please enter registered phone number" error
      expect(find.text('Please enter registered phone number'), findsNothing);
      expect(find.text('Phone number must be at least 10 digits'), findsNothing);
    });

    testWidgets('Direct ID mode shows error when tracking ID is left empty', (tester) async {
      await tester.pumpWidget(createTrackingScreen());
      await tester.pumpAndSettle();

      // Switch to Direct ID
      await tester.tap(find.text('Direct ID'));
      await tester.pumpAndSettle();

      // Tap Track button without entering tracking ID
      final trackButton = find.widgetWithIcon(ElevatedButton, Icons.search_rounded);
      await tester.tap(trackButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your Application Number'), findsOneWidget);
    });
  });
}
