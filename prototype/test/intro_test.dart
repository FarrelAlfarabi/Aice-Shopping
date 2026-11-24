import 'package:aice_shopping/intro.dart';
import 'package:aice_shopping/main.dart';
import 'package:aice_shopping/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('intro shows first, Mulai leads to onboarding', (tester) async {
    await tester.pumpWidget(const AiceApp());
    await tester.pump(const Duration(milliseconds: 1200)); // splash done
    await tester.pump();

    expect(find.byType(IntroScreen), findsOneWidget);
    expect(find.text('Es krim, tetap beku.'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);
    expect(find.text('Alamat pengiriman'), findsNothing);

    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.byType(IntroScreen), findsNothing);
    expect(find.text('Alamat pengiriman'), findsOneWidget);
  });

  testWidgets('slides can be swiped', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AppScope(state: AppState(), child: const IntroScreen()),
    ));
    expect(find.text(introSlides[0].title), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text(introSlides[1].title), findsOneWidget);
  });

  test('reset demo brings the intro back', () {
    final s = AppState()
      ..finishIntro()
      ..finishOnboarding();
    s.resetDemo();
    expect(s.introSeen, false);
    expect(s.onboarded, false);
  });
}
