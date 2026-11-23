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
  static const multiBuyQty = 3;
  static const multiBuyPercent = 10;

  final int subtotal;
  final int multiBuy;
  final int voucherDiscount;
  final int delivery;
  const Pricing({
    required this.subtotal,
    required this.multiBuy,
    required this.voucherDiscount,
    required this.delivery,
  });

  int get total => subtotal - multiBuy - voucherDiscount + delivery;
  int get afterMultiBuy => subtotal - multiBuy;
  bool get canCheckout => subtotal >= minOrder;
  int get toMinOrder => max(0, minOrder - subtotal);
  int get toFreeDelivery => max(0, freeThreshold - afterMultiBuy);
  double get freeProgress => min(1.0, afterMultiBuy / freeThreshold);
}

/// Cones mix and match: 3 or more cones together get 10% off the cones.
Pricing computePricing(Map<Product, int> lines, Voucher? voucher) {
  var subtotal = 0;
  var coneTotal = 0;
  var coneQty = 0;
  lines.forEach((p, q) {
    subtotal += p.price * q;
    if (p.multiBuy) {
      coneTotal += p.price * q;
      coneQty += q;
    }
  });
  final multiBuy = coneQty >= Pricing.multiBuyQty
      ? (coneTotal * Pricing.multiBuyPercent) ~/ 100
      : 0;
  final base = subtotal - multiBuy;

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
  );
}
