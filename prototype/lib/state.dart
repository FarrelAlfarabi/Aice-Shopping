import 'package:flutter/material.dart';
import 'data.dart';
import 'pricing.dart';

class OrderLine {
  final String name;
  final int qty;
  final int price;
  const OrderLine(this.name, this.qty, this.price);
}

class Order {
  final String id;
  final List<OrderLine> lines;
  final Pricing pricing;
  final String storeName;
  final String address;
  final String payment;
  final DateTime placedAt;
  final bool late; // demo control "Make this order late"
  final int demoSeconds;
  final bool sample; // fixed sample history order
  bool reported = false;
  Order({
    required this.id,
    required this.lines,
    required this.pricing,
    required this.storeName,
    required this.address,
    required this.payment,
    required this.placedAt,
    required this.late,
    required this.demoSeconds,
    this.sample = false,
  });
}

class AppState extends ChangeNotifier {
  // Choices
  Store store = stores.first;
  String address = ''; // empty until the person sets it
  String slot = 'Sekarang';
  String payment = 'E-wallet';
  bool introSeen = false;

  // Cart (device only)
  final Map<String, int> _qty = {};
  String voucherInput = '';
  Voucher? _voucher;
  VoucherStatus voucherStatus = VoucherStatus.none;
  int voucherShortBy = 0;

  // Orders
  Order? current;
  final List<Order> history = [_sampleOrder()];
  int _orderNo = 1;

  // Demo controls
  int demoSeconds = 75;
  bool makeLate = false;
  final bool dataLocal = true;

  Map<Product, int> get lines => {
        for (final e in _qty.entries)
          if (e.value > 0) productById(e.key): e.value,
      };
  int qtyOf(String id) => _qty[id] ?? 0;
  int get itemCount => _qty.values.fold(0, (a, b) => a + b);
  bool get cartEmpty => itemCount == 0;

  bool get hasAddress => address.trim().isNotEmpty;

  Voucher? get voucher => voucherStatus == VoucherStatus.ok ? _voucher : null;
  Pricing get pricing => computePricing(lines, voucher);

  void chooseStore(Store s) {
    store = s;
    notifyListeners();
  }

  void setAddress(String a) {
    address = a;
    notifyListeners();
  }

  void finishIntro() {
    introSeen = true;
    notifyListeners();
  }

  void add(Product p, [int n = 1]) {
    if (p.soldOut) return;
    _qty[p.id] = (_qty[p.id] ?? 0) + n;
    _recheckVoucher();
    notifyListeners();
  }

  void remove(Product p) {
    final q = (_qty[p.id] ?? 0) - 1;
    if (q <= 0) {
      _qty.remove(p.id);
    } else {
      _qty[p.id] = q;
    }
    _recheckVoucher();
    notifyListeners();
  }

  void setSlot(String s) {
    slot = s;
    notifyListeners();
  }

  void setPayment(String p) {
    payment = p;
    notifyListeners();
  }

  void applyVoucher(String code) {
    voucherInput = code.trim().toUpperCase();
    _recheckVoucher();
    notifyListeners();
  }

  void clearVoucher() {
    voucherInput = '';
    _recheckVoucher();
    notifyListeners();
  }

  void _recheckVoucher() {
    final subtotal = computePricing(lines, null).subtotal;
    final r = checkVoucher(voucherInput, subtotal);
    voucherStatus = r.status;
    _voucher = r.voucher;
    voucherShortBy = r.shortBy;
  }

  /// Turns the cart into an order and clears the cart.
  Order placeOrder() {
    final p = pricing;
    final o = Order(
      id: '#AC-${(1000 + _orderNo++).toString()}',
      lines: [
        for (final e in lines.entries)
          OrderLine(e.key.name, e.value, e.key.price),
      ],
      pricing: p,
      storeName: store.name,
      address: address,
      payment: payment,
      placedAt: DateTime.now(),
      late: makeLate,
      demoSeconds: demoSeconds,
    );
    current = o;
    history.insert(0, o);
    _qty.clear();
    voucherInput = '';
    _recheckVoucher();
    notifyListeners();
    return o;
  }

  void setSpeed(int seconds) {
    demoSeconds = seconds;
    notifyListeners();
  }

  void setMakeLate(bool v) {
    makeLate = v;
    notifyListeners();
  }

  void markReported(Order o) {
    o.reported = true;
    notifyListeners();
  }

  /// Clears the device cart, orders and chosen address for a clean second run.
  void resetDemo() {
    _qty.clear();
    voucherInput = '';
    _recheckVoucher();
    current = null;
    history
      ..clear()
      ..add(_sampleOrder());
    store = stores.first;
    address = '';
    slot = 'Sekarang';
    payment = 'E-wallet';
    makeLate = false;
    introSeen = false;
    notifyListeners();
  }
}

Order _sampleOrder() => Order(
      id: '#AC-0987',
      lines: const [OrderLine('Cone Vanila Stroberi', 3, 5000)],
      pricing: computePricing({productById('cone-vanila'): 3}, null),
      storeName: 'Toko Contoh 1',
      address: savedAddresses.first,
      payment: 'QRIS',
      placedAt: DateTime(2026, 11, 20, 19, 30),
      late: false,
      demoSeconds: 75,
      sample: true,
    );

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
