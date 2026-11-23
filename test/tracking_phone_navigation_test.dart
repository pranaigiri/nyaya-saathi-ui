import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi/screens/citizen/application_detail_screen.dart';
import 'package:nyaya_saathi/providers/theme_provider.dart';
import 'package:nyaya_saathi/providers/language_provider.dart';
import 'package:nyaya_saathi/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createAppDetailScreen({required String trackingNumber, String? phoneNumber}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        home: ApplicationDetailScreen(
          trackingNumber: trackingNumber,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }

  group('Track Detail Instant Navigation & Loader Tests', () {
    testWidgets('ApplicationDetailScreen accepts trackingNumber and displays loader and app bar with case number', (tester) async {
      await tester.pumpWidget(
        createAppDetailScreen(
          trackingNumber: 'SK-GTK-26-00034',
          phoneNumber: '9876543210',
        ),
      );

      // Verify that while loading, the app bar shows the case tracking number
      expect(find.textContaining('SK-GTK-26-00034'), findsOneWidget);

      // Verify that the body shows the loading indicator and loading text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading application details...'), findsOneWidget);
    });
  });
}
