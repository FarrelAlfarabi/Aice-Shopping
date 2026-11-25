import 'package:aice_shopping/accounts.dart';
import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/pricing.dart';
import 'package:aice_shopping/state.dart';
import 'package:flutter_test/flutter_test.dart';

/// The consumer app and the admin read one AppState. These tests walk the
/// link between them (guidebook: demo must show the whole story).
void main() {
  group('bank transfer link', () {
    test('transfer order waits, admin confirms, then it is a delivery task', () {
      final s = AppState();
      s.payment = 'Transfer bank';
      s.add(productById('cone-vanila'), 4);
      final o = s.placeOrder();
      expect(o.status, OrderStatus.pendingPayment);
      expect(s.unpaidOrders, contains(o));
      expect(s.history.first, same(o)); // the consumer sees it
      final unpaidBefore = s.unpaidTotal;
      final paidBefore = s.paymentsThisMonth;

      s.confirmTransfer(o);
      expect(o.status, OrderStatus.pendingPrep);
      expect(s.prepTasks, contains(o));
      expect(s.unpaidTotal, unpaidBefore - o.pricing.total);
      expect(s.paymentsThisMonth, paidBefore + o.pricing.total);
      expect(s.notices.first.text, contains('dikonfirmasi'));

      s.startDelivery(o);
      expect(o.status, OrderStatus.shipping);
      s.markDelivered(o);
      expect(o.status, OrderStatus.delivered);
    });

    test('paying with QRIS skips the wait', () {
      final s = AppState();
      s.payment = 'QRIS';
      s.add(productById('cone-vanila'));
      final o = s.placeOrder();
      expect(o.status, OrderStatus.shipping);
      expect(o.paidAt, isNotNull);
    });

    test('confirm does nothing twice', () {
      final s = AppState();
      final o = s.unpaidOrders.first;
      s.confirmTransfer(o);
      final at = o.paidAt;
      s.confirmTransfer(o);
      expect(o.paidAt, at);
    });

    test('the consumer sees only their own orders, admin sees all', () {
      final s = AppState();
      expect(s.history.length, 1); // the guest sample order
      expect(s.allOrders.length, greaterThan(3));
      s.signIn(demoAccounts[0]);
      expect(s.history.every((o) => o.customerId == 'c-jaya'), isTrue);
      expect(s.history, isNotEmpty);
    });
  });

  group('stock and alarms', () {
    test('ordering takes stock out and can raise a low stock alarm', () {
      final s = AppState();
      final id = 'tub-stroberi';
      final before = s.stock[id]!.stock;
      expect(s.lowStock.any((e) => e.key.id == id), isFalse);
      s.add(productById(id), before - s.stock[id]!.reorder);
      s.placeOrder();
      expect(s.stock[id]!.stock, s.stock[id]!.reorder);
      expect(s.lowStock.any((e) => e.key.id == id), isTrue);
    });

    test('stock never goes below zero', () {
      final s = AppState();
      s.add(productById('cone-vanila'), 99);
      s.placeOrder();
      expect(s.stock['cone-vanila']!.stock, 0);
    });

    test('restock clears the alarm and cold chain alarm can be resolved', () {
      final s = AppState();
      expect(s.lowStock.any((e) => e.key.id == 'cone-vanila'), isTrue);
      s.restock('cone-vanila');
      expect(s.lowStock.any((e) => e.key.id == 'cone-vanila'), isFalse);
      expect(s.openColdAlarms, 1);
      s.resolveCold(s.coldAlarms.first);
      expect(s.openColdAlarms, 0);
      s.simulateColdFailure();
      expect(s.openColdAlarms, 1);
    });

    test('reset data restores the sample start but keeps role and language', () {
      final s = AppState();
      s.setRole(AppRole.admin);
      s.setLang('en');
      s.confirmTransfer(s.unpaidOrders.first);
      s.restock('cone-vanila');
      s.resetData();
      expect(s.unpaidOrders.length, 2);
      expect(s.stock['cone-vanila']!.stock, 15);
      expect(s.role, AppRole.admin);
      expect(s.lang, 'en');
      s.setLang('id');
    });

    test('new products are in the stock data, chilled and frozen', () {
      final s = AppState();
      expect(productById('cup-original').chilled, isTrue);
      expect(productById('cup-original').shelfLifeDays, 28);
      expect(productById('frozen-naget').chilled, isFalse);
      for (final id in ['cup-original', 'frozen-naget']) {
        expect(s.stock[id], isNotNull, reason: id);
      }
      expect(s.lowStock.map((e) => e.key.id), contains('frozen-naget'));
    });
  });

  group('prices from the one config', () {
    test('quantity tiers apply per product, cones keep their own rule', () {
      final stick = productById('stik-cokelat');
      final p6 = computePricing({stick: 6}, null);
      expect(p6.tier, stick.price * 6 * 5 ~/ 100);
      final p5 = computePricing({stick: 5}, null);
      expect(p5.tier, 0);
      final p12 = computePricing({stick: 12}, null);
      expect(p12.tier, stick.price * 12 * 8 ~/ 100);
      // Two different sticks do not add up to a tier.
      final mixed = computePricing(
          {stick: 3, productById('stik-dark'): 3}, null);
      expect(mixed.tier, 0);
      final cones = computePricing({productById('cone-vanila'): 3}, null);
      expect(cones.tier, 0);
      expect(cones.multiBuy, greaterThan(0));
    });

    test('VIP price takes a percent off and shows in the total', () {
      final lines = {productById('tub-stroberi'): 1};
      final plain = computePricing(lines, null);
      final vip = computePricing(lines, null, vip: true);
      expect(vip.vip, plain.subtotal * vipPercent ~/ 100);
      expect(vip.total, lessThan(plain.total));
      expect(plain.vip, 0);
    });

    test('signing in as VIP changes the cart total, signing out reverts', () {
      final s = AppState();
      s.add(productById('tub-stroberi'));
      final before = s.pricing.total;
      s.signIn(demoAccounts[0]);
      expect(s.pricing.total, lessThan(before));
      s.signOut();
      expect(s.pricing.total, before);
    });

    test('carton price is cheaper than buying the pieces', () {
      for (final p in catalog) {
        expect(cartonPrice(p), lessThan(p.price * (cartonUnits[p.category] ?? 1)),
            reason: p.id);
      }
    });
  });

  group('demo sign in', () {
    test('finds a demo account by phone, ignores spaces and dashes', () {
      final s = AppState();
      expect(s.findByPhone('821 3333 4403')?.id, 'c-jaya');
      expect(s.findByPhone('+62 822-8888-9908')?.id, 'c-kios');
      expect(s.findByPhone('12345'), isNull);
      expect(s.findByPhone(''), isNull);
    });

    test('register makes a new account; the sample invite code makes it VIP', () {
      final s = AppState();
      final a = s.register('Toko Baru', '0811', 'salah');
      expect(s.isVip, isFalse);
      expect(s.balance, signupBonusPoints);
      expect(s.customer, a);
      s.register('Toko VIP', '0812', inviteCodeVip.toLowerCase());
      expect(s.isVip, isTrue);
      expect(s.customers.length, demoAccounts.length + 2);
    });

    test('every sample account is marked as sample data', () {
      for (final c in demoAccounts) {
        expect(c.sample, isTrue);
      }
    });
  });
}
