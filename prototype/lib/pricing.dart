import 'dart:math';
import 'data.dart';

/// All amounts are in whole Rupiah. Every number here is a sample rule.
class Voucher {
  final String code;
  final String description;
  final int minSubtotal;
  final int percent; // 0 when not a percent voucher
  final int maxDiscount;
  final int amount; // fixed discount, 0 when not used
  final bool freeShip;
  const Voucher(
    this.code,
    this.description,
    this.minSubtotal, {
    this.percent = 0,
    this.maxDiscount = 0,
    this.amount = 0,
    this.freeShip = false,
  });
}

const vouchers = <Voucher>[
  Voucher('HEMAT10', 'Diskon 10% (maks. Rp10.000), min. belanja Rp30.000', 30000,
      percent: 10, maxDiscount: 10000),
  Voucher('GRATISONGKIR', 'Gratis ongkir, min. belanja Rp20.000', 20000,
      freeShip: true),
  Voucher('PESTA20', 'Potongan Rp20.000, min. belanja Rp100.000', 100000,
      amount: 20000),
];

/// Mix pack: pick any 6, 8 or 12 cones or sticks for one set price.
/// Sample numbers, kept here only (guidebook: promises in one config).
const mixPackPrices = <int, int>{6: 31000, 8: 41000, 12: 60000};

/// Quantity tiers for the non-cone categories: (minimum units of ONE product,
/// percent off that product's line). Cones keep their mix and match rule
/// (see [Pricing.multiBuyQty]). Sample numbers, kept here only.
const tierRules = <String, List<(int, int)>>{
  'stick': [(6, 5), (12, 8)],
  'tub': [(2, 5), (4, 8)],
  'cup': [(4, 5), (10, 8)],
  'frozen': [(4, 5), (10, 8)],
  'drink': [(6, 5), (12, 10)],
};

/// Extra percent off for VIP demo accounts ("harga member"). Sample number.
const vipPercent = 5;

/// Units in one carton per category, and the percent off when you buy a whole
/// carton. Shown as the "Harga 1 karton" line. Sample numbers.
const cartonUnits = <String, int>{
  'cone': 12,
  'stick': 12,
  'tub': 6,
  'cup': 12,
  'drink': 12,
  'bundle': 4,
  'frozen': 10,
};
const cartonPercent = 8;

int cartonPrice(Product p) =>
    (p.price * (cartonUnits[p.category] ?? 1) * (100 - cartonPercent)) ~/ 100;

/// Text for the tier line on a product, or null when it has none.
String? tierText(Product p) {
  if (p.multiBuy) {
    return '≥${Pricing.multiBuyQty} cone campur rasa -${Pricing.multiBuyPercent}%';
  }
  final t = tierRules[p.category];
  if (t == null) return null;
  return [for (final r in t) '≥${r.$1} -${r.$2}%'].join(' · ');
}

/// Percent off for [qty] units of one non-cone product.
int tierPercent(String category, int qty) {
  var best = 0;
  for (final r in tierRules[category] ?? const <(int, int)>[]) {
    if (qty >= r.$1) best = r.$2;
  }
  return best;
}

enum VoucherStatus { none, ok, wrong, notMet }

class VoucherResult {
  final VoucherStatus status;
  final Voucher? voucher;
  final int shortBy;
  const VoucherResult(this.status, {this.voucher, this.shortBy = 0});
}

VoucherResult checkVoucher(String code, int subtotal) {
  final c = code.trim().toUpperCase();
  if (c.isEmpty) return const VoucherResult(VoucherStatus.none);
  final matches = vouchers.where((v) => v.code == c);
  if (matches.isEmpty) return const VoucherResult(VoucherStatus.wrong);
  final v = matches.first;
  if (subtotal < v.minSubtotal) {
    return VoucherResult(VoucherStatus.notMet,
        voucher: v, shortBy: v.minSubtotal - subtotal);
  }
  return VoucherResult(VoucherStatus.ok, voucher: v);
}

class Pricing {
  static const baseFee = 5000;
  static const freeThreshold = 50000;
  static const minOrder = 20000;

  /// Extra fee when the cart is under [minOrder]. Checkout still works
  /// (sample value for the demo; change it here only).
  static const smallOrderFee = 5000;
  static const multiBuyQty = 3;
  static const multiBuyPercent = 10;

  final int subtotal;
  final int multiBuy;
  final int voucherDiscount;
  final int delivery;
  final int tier; // quantity tier discount (non-cone products)
  final int vip; // VIP member discount
  const Pricing({
    required this.subtotal,
    required this.multiBuy,
    required this.voucherDiscount,
    required this.delivery,
    this.tier = 0,
    this.vip = 0,
  });

  bool get belowMinOrder => subtotal > 0 && subtotal < minOrder;
  int get smallFee => belowMinOrder ? smallOrderFee : 0;
  int get total =>
      subtotal - multiBuy - tier - vip - voucherDiscount + delivery + smallFee;
  int get afterMultiBuy => subtotal - multiBuy - tier - vip;
  int get toMinOrder => max(0, minOrder - subtotal);
  int get toFreeDelivery => max(0, freeThreshold - afterMultiBuy);
  double get freeProgress => min(1.0, afterMultiBuy / freeThreshold);
}

/// Cones mix and match: 3 or more cones together get 10% off the cones.
Pricing computePricing(Map<Product, int> lines, Voucher? voucher,
    {bool vip = false}) {
  var subtotal = 0;
  var coneTotal = 0;
  var coneQty = 0;
  var tier = 0;
  lines.forEach((p, q) {
    subtotal += p.price * q;
    if (!p.multiBuy) tier += (p.price * q * tierPercent(p.category, q)) ~/ 100;
    if (p.multiBuy) {
      coneTotal += p.price * q;
      coneQty += q;
    }
  });
  final multiBuy = coneQty >= Pricing.multiBuyQty
      ? (coneTotal * Pricing.multiBuyPercent) ~/ 100
      : 0;
  final vipOff = vip ? ((subtotal - multiBuy - tier) * vipPercent) ~/ 100 : 0;
  final base = subtotal - multiBuy - tier - vipOff;

  var disc = 0;
  var freeShip = false;
  if (voucher != null && subtotal >= voucher.minSubtotal) {
    if (voucher.percent > 0) {
      disc = min(voucher.maxDiscount, (base * voucher.percent) ~/ 100);
    }
    disc += voucher.amount;
    freeShip = voucher.freeShip;
  }
  disc = min(disc, base);

  final fee = (subtotal == 0 || base >= Pricing.freeThreshold || freeShip)
      ? 0
      : Pricing.baseFee;
  return Pricing(
    subtotal: subtotal,
    multiBuy: multiBuy,
    voucherDiscount: disc,
    delivery: fee,
    tier: tier,
    vip: vipOff,
  );
}
