import 'package:aice_shopping/accounts.dart';
import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/membership.dart';
import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/pricing.dart';
import 'package:aice_shopping/screens_a.dart';
import 'package:aice_shopping/state.dart';
import 'package:aice_shopping/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => loopMotion = false);

  group('tiers and points rules (all from Pricing config)', () {
    test('tier thresholds', () {
      expect(tierForPoints(0).key, 'reg');
      expect(tierForPoints(499).key, 'reg');
      expect(tierForPoints(500).key, 'silver');
      expect(tierForPoints(1499).key, 'silver');
      expect(tierForPoints(1500).key, 'gold');
      expect(tierForPoints(1500).vipPrice, isTrue);
      expect(tierForPoints(500).freeDelivery, isTrue);
      expect(tierForPoints(500).vipPrice, isFalse);
      expect(nextTier(1500), isNull);
      expect(nextTier(0)?.key, 'silver');
    });

    test('1 point per Rp1.000, 100 points = Rp1.000', () {
      expect(pointsFor(96000), 96);
      expect(pointsFor(999), 0);
      expect(100 * pointValueRp, 1000);
    });

    test('sample members match the preview', () {
      final s = AppState();
      expect(s.tierOf(demoAccounts[0]).key, 'gold');
      expect(s.accountOf(demoAccounts[0]).balance, 1320);
      expect(s.tierOf(demoAccounts[1]).key, 'silver');
      expect(s.accountOf(demoAccounts[1]).balance, 760);
      expect(s.tierOf(demoAccounts[2]).key, 'reg');
      expect(s.accountOf(demoAccounts[2]).balance, 210);
    });

    test('redeem is capped at 50% of the subtotal and at the balance', () {
      final s = AppState()..signIn(demoAccounts[0]);
      s.add(productById('cone-vanila'), 10); // gold: 1320 points
      final subtotal = s.pricing.subtotal;
      s.setRedeem(100000);
      expect(s.pricing.pointsOff, lessThanOrEqualTo(subtotal * 50 ~/ 100));
      expect(s.pricing.total, greaterThan(0));
      final r = AppState()..signIn(demoAccounts[2]); // 210 points
      r.add(productById('tub-stroberi'), 4);
      r.setRedeem(100000);
      expect(r.redeem, lessThanOrEqualTo(210));
    });
  });

  group('points ledger', () {
    test('transfer order: points only after admin confirms', () {
      final s = AppState()..signIn(demoAccounts[2]);
      s.payment = 'Transfer bank';
      s.add(productById('tub-stroberi'), 2);
      s.setRedeem(100);
      final total = s.pricing.total;
      final used = s.pricing.pointsUsed;
      expect(used, 100);
      final o = s.placeOrder();
      expect(s.balance, 210 - 100); // redeemed at once
      expect(o.pointsEarn, pointsFor(total));
      s.confirmTransfer(o);
      expect(s.balance, 210 - 100 + pointsFor(total));
      expect(s.accountOf(s.customer).lifetime, 210 + pointsFor(total));
      s.confirmTransfer(o); // no double award
      expect(s.balance, 210 - 100 + pointsFor(total));
    });

    test('ewallet order earns at once', () {
      final s = AppState()..signIn(demoAccounts[2]);
      s.payment = 'E-wallet';
      s.add(productById('tub-stroberi'), 2);
      final o = s.placeOrder();
      expect(s.balance, 210 + o.pointsEarn);
    });

    test('guest earns nothing; new account gets the bonus; reset restores', () {
      final g = AppState();
      g.add(productById('tub-stroberi'), 2);
      expect(g.placeOrder().pointsEarn, 0);
      final s = AppState()..register('Toko Baru', '0811', '');
      expect(s.balance, signupBonusPoints);
      expect(s.accountOf(s.customer).history.single.kind, PointKind.bonus);
      s.resetDemo();
      expect(s.accountOf(demoAccounts[0]).balance, 1320);
    });

    test('Silver gets free delivery, Gold also the VIP price', () {
      final sil = AppState()..signIn(demoAccounts[1]);
      sil.add(productById('cone-vanila'), 1);
      expect(sil.pricing.delivery, 0);
      expect(sil.pricing.vip, 0);
      final gold = AppState()..signIn(demoAccounts[0]);
      gold.add(productById('cone-vanila'), 1);
      expect(gold.pricing.delivery, 0);
      expect(gold.pricing.vip, greaterThan(0));
      final reg = AppState()..signIn(demoAccounts[2]);
      reg.add(productById('cone-vanila'), 1);
      expect(reg.pricing.delivery, Pricing.baseFee);
    });
  });

  testWidgets('home chip opens the member card with history and progress',
      (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final st = AppState()
      ..finishIntro()
      ..signIn(demoAccounts[1]);
    await tester.pumpWidget(AppScope(
      state: st,
      child: MaterialApp(theme: buildTheme(), home: const Scaffold(body: HomeTab())),
    ));
    await tester.pumpAndSettle();
    expect(find.text('760 Poin · Silver'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('points-chip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('points-chip')));
    await tester.pumpAndSettle();
    expect(find.byType(MemberScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('member-card')), findsOneWidget);
    expect(find.text('740 poin lagi ke Gold'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
