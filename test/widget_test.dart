import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_reader_app/core/theme/news_theme_extension.dart';
import 'package:news_reader_app/features/splash/pages/splash_screen.dart';

void main() {
  testWidgets('Splash screen shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const [NewsThemeExtension.light],
        ),
        home: const SplashScreen(),
      ),
    );

    expect(find.text('NewsReader'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Remove SplashScreen before delayed navigation executes
    await tester.pumpWidget(const SizedBox.shrink());
  });
}