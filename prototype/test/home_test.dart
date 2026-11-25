import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/pricing.dart';
import 'package:aice_shopping/screens_a.dart';
import 'package:aice_shopping/state.dart';
import 'package:aice_shopping/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => loopMotion = false);

  test('Flash Sale takes its percent off, and stops when time is up', () {
    final s = AppState();
    final p = productById(flashDeals.keys.first);
    s.add(p, 2);
    final on = s.pricing;
    expect(on.flash, (p.price - flashUnitPrice(p)) * 2);
    s.flashEnd = DateTime.now().subtract(const Duration(seconds: 1));
    expect(s.flashOn, isFalse);
    expect(s.pricing.flash, 0);
    s.resetDemo();
    expect(s.flashOn, isTrue);
  });

  Future<AppState> open(WidgetTester tester, AppState st) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AppScope(
        state: st,
        child: MaterialApp(theme: buildTheme(), home: const Shell()),
      ),
    );
    await tester.pumpAndSettle();
    return st;
  }

  testWidgets('home shows tiles, flash sale and the Tanya AI button', (
    tester,
  ) async {
    await open(tester, AppState()..finishIntro());
    expect(find.byKey(const ValueKey('ask-ai-fab')), findsOneWidget);
    expect(find.byKey(const ValueKey('mini-cart')), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('flash-sale')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('flash-countdown')), findsOneWidget);
    expect(find.byKey(const ValueKey('category-tiles')), findsOneWidget);
  });

  testWidgets('mini-cart appears with an item and opens the cart', (
    tester,
  ) async {
    final st = AppState()..finishIntro();
    await open(tester, st);
    st.add(productById('cone-vanila'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('mini-cart')), findsOneWidget);
    expect(find.textContaining('lagi untuk gratis ongkir'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('mini-cart-open')));
    await tester.pumpAndSettle();
    expect(tabIndex.value, 1);
    tabIndex.value = 0;
  });
}
