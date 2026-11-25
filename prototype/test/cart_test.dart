import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/pricing.dart';
import 'package:aice_shopping/screens_a.dart';
import 'package:aice_shopping/screens_b.dart';
import 'package:aice_shopping/state.dart';
import 'package:aice_shopping/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The cart must never be a dead end: the pay button always works, and the
/// minimum order and free delivery limits are labelled as two separate rules.
void main() {
  setUpAll(() => loopMotion = false);

  Future<AppState> openCart(WidgetTester tester, {int cones = 2}) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final st = AppState()..finishIntro();
    for (var i = 0; i < cones; i++) {
      st.add(productById('cone-vanila'));
    }
    await tester.pumpWidget(AppScope(
      state: st,
      child: MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(body: CartTab()),
      ),
    ));
    await tester.pumpAndSettle();
    return st;
  }

  testWidgets('under the minimum: button is tappable and explains why',
      (tester) async {
    final st = await openCart(tester, cones: 1);
    expect(st.pricing.canCheckout, isFalse);
    final button = tester.widget<FilledButton>(find.byType(FilledButton).last);
    expect(button.onPressed, isNotNull, reason: 'no greyed-out dead button');
    expect(find.byKey(const Key('min-order-note')), findsOneWidget);

    await tester.tap(find.text('Lanjut bayar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Minimum order Rp20.000, tambah'), findsOneWidget);
    expect(find.byType(CheckoutScreen), findsNothing);
  });

  testWidgets('"Tambah item" goes back to Home', (tester) async {
    await openCart(tester, cones: 1);
    tabIndex.value = 1;
    await tester.ensureVisible(find.text('Tambah item').first);
    await tester.tap(find.text('Tambah item').first);
    await tester.pump();
    expect(tabIndex.value, 0);
  });

  testWidgets('min order and free delivery are labelled separately',
      (tester) async {
    await openCart(tester, cones: 1);
    expect(find.textContaining('Gratis ongkir (belanja Rp50.000)'),
        findsOneWidget);
    expect(find.textContaining('Minimum order Rp20.000'), findsOneWidget);
  });

  testWidgets('at or above the minimum: no warning, goes to checkout',
      (tester) async {
    final st = await openCart(tester, cones: 4);
    expect(st.pricing.canCheckout, isTrue);
    expect(find.byKey(const Key('min-order-note')), findsNothing);
    await tester.tap(find.text('Lanjut bayar'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutScreen), findsOneWidget);
  });

  test('the two limits are different numbers kept in Pricing', () {
    expect(Pricing.minOrder, 20000);
    expect(Pricing.freeThreshold, 50000);
  });
}
