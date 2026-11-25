import 'package:aice_shopping/accounts.dart';
import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/payment_ui.dart';
import 'package:aice_shopping/pricing.dart';
import 'package:aice_shopping/state.dart';
import 'package:aice_shopping/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => loopMotion = false);

  AppState member(String pay) {
    final s = AppState()..signIn(demoAccounts[2]); // 210 points
    s.setPayment(pay);
    s.add(productById('tub-stroberi'), 2);
    return s;
  }

  test('four options live in the config', () {
    expect(paymentOptions.map((o) => o.flow).toSet(), PayFlow.values.toSet());
    expect(paymentOptions.length, 4);
  });

  test('bank transfer: waits, buyer reports, admin confirms, points then', () {
    final s = member('Transfer bank');
    final o = s.placeOrder();
    expect(o.status, OrderStatus.pendingPayment);
    expect(o.isPaid, isFalse);
    s.claimTransfer(o);
    expect(o.transferClaimed, isTrue);
    expect(s.balance, 210);
    s.confirmTransfer(o);
    expect(o.status, OrderStatus.pendingPrep);
    expect(s.balance, 210 + o.pointsEarn);
  });

  for (final id in ['QRIS', 'E-wallet']) {
    test('$id confirms at once and gives points at once', () {
      final s = member(id);
      final o = s.placeOrder();
      expect(o.status, OrderStatus.shipping);
      expect(o.isPaid, isTrue);
      expect(s.balance, 210 + o.pointsEarn);
      s.claimTransfer(o); // not a bank order: ignored
      expect(o.transferClaimed, isFalse);
    });
  }

  test('COD: prepared at once, paid and points only when marked done', () {
    final s = member('Bayar di tempat (COD)');
    final o = s.placeOrder();
    expect(o.status, OrderStatus.pendingPrep);
    expect(o.isPaid, isFalse);
    expect(s.balance, 210);
    s.confirmTransfer(o); // not a bank order: ignored
    expect(o.status, OrderStatus.pendingPrep);
    s.startDelivery(o);
    s.markDelivered(o);
    expect(o.isPaid, isTrue);
    expect(s.balance, 210 + o.pointsEarn);
    s.markDelivered(o); // no double award
    expect(s.balance, 210 + o.pointsEarn);
  });

  testWidgets('cart row opens the picker and the choice is the default', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final st = AppState()..finishIntro();
    await tester.pumpWidget(
      AppScope(
        state: st,
        child: MaterialApp(
          theme: buildTheme(),
          home: const Scaffold(body: PaymentRow()),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('payment-row')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('pay-cod-Bayar di tempat (COD)')),
    );
    await tester.pumpAndSettle();
    expect(st.payment, 'Bayar di tempat (COD)');
    expect(find.text('Bayar di tempat (COD)'), findsOneWidget);
  });
}
