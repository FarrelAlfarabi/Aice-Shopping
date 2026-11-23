import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/format.dart';
import 'package:aice_shopping/pricing.dart';
import 'package:aice_shopping/tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cone = productById('cone-vanila');
  final cone2 = productById('cone-cokelat');
  final tub = productById('tub-stroberi');
  final bundle = productById('bundle-pesta');

  test('rupiah format', () {
    expect(rp(5000), 'Rp5.000');
    expect(rp(0), 'Rp0');
    expect(rp(1250000), 'Rp1.250.000');
    expect(rp(-1500), '-Rp1.500');
  });

  test('empty cart has no fee', () {
    final p = computePricing({}, null);
    expect(p.total, 0);
    expect(p.delivery, 0);
  });

  test('sums and adds delivery fee below threshold', () {
    final p = computePricing({cone: 2, tub: 1}, null);
    expect(p.subtotal, 42000);
    expect(p.delivery, 5000);
    expect(p.total, 47000);
  });

  test('3 cones mixed get 10% off the cones only', () {
    final p = computePricing({cone: 2, cone2: 1, tub: 1}, null);
    // cones: 10000 + 6000 = 16000 -> 1600 off
    expect(p.multiBuy, 1600);
    expect(computePricing({cone: 2, tub: 1}, null).multiBuy, 0);
  });

  test('free delivery progress and fee', () {
    final p = computePricing({tub: 1, cone: 2}, null); // 42.000
    expect(p.delivery, 5000);
    expect(p.toFreeDelivery, 8000);
    final q = computePricing({tub: 2}, null); // 64.000
    expect(q.delivery, 0);
  });

  test('minimum order', () {
    final p = computePricing({cone: 2}, null);
    expect(p.canCheckout, false);
    expect(p.toMinOrder, 10000);
    expect(computePricing({tub: 1}, null).canCheckout, true);
  });

  test('voucher checks', () {
    expect(checkVoucher('', 50000).status, VoucherStatus.none);
    expect(checkVoucher('XYZ', 50000).status, VoucherStatus.wrong);
    final low = checkVoucher('hemat10', 20000);
    expect(low.status, VoucherStatus.notMet);
    expect(low.shortBy, 10000);
    expect(checkVoucher('hemat10', 42000).status, VoucherStatus.ok);
  });

  test('percent voucher is capped and free ship voucher removes the fee', () {
    final v10 = vouchers.firstWhere((v) => v.code == 'HEMAT10');
    final p = computePricing({tub: 1, cone: 2}, v10); // 42.000
    expect(p.voucherDiscount, 4200);
    final ship = vouchers.firstWhere((v) => v.code == 'GRATISONGKIR');
    expect(computePricing({tub: 1, cone: 2}, ship).delivery, 0);
    final big = computePricing({bundle: 2}, v10);
    expect(big.voucherDiscount, 10000);
  });

  test('voucher below its minimum gives no discount', () {
    final v = vouchers.firstWhere((v) => v.code == 'PESTA20');
    expect(computePricing({tub: 1}, v).voucherDiscount, 0);
  });

  test('tracking phases and ETA', () {
    expect(trackAt(0, 75).phase, Phase.received);
    expect(trackAt(20, 75).phase, Phase.preparing);
    expect(trackAt(40, 75).phase, Phase.onTheWay);
    expect(trackAt(75, 75).phase, Phase.arrived);
    expect(trackAt(0, 75).minutesLeft, 15);
  });

  test('late order shows the guarantee after the grace time', () {
    expect(trackAt(76, 75, forceLate: true).guarantee, false);
    expect(trackAt(75 + 20, 75, forceLate: true).guarantee, true); // 13 min
    expect(trackAt(75 + 20, 75, forceLate: true).delivered, false);
    expect(trackAt(75 + 40, 75, forceLate: true).delivered, true); // 26 min
    expect(lateGuarantee(10), false);
    expect(lateGuarantee(10.1), true);
  });

  test('clock text', () {
    expect(clock(12.5), '12:30');
    expect(clock(0), '00:00');
  });
}
