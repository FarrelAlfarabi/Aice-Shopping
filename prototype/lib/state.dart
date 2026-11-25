import 'package:flutter/material.dart';
import 'data.dart';
import 'pricing.dart';

class OrderLine {
  final String name;
  final int qty;
  final int price;
  final String? productId; // null for a mix pack (it cannot be re-ordered)
  final String? detail; // for a mix pack: which flavours
  const OrderLine(this.name, this.qty, this.price,
      {this.productId, this.detail});
}

/// One item in the notification list (sample text, shown as "contoh").
class AppNotice {
  final String id;
  final String text;
  bool read;
  AppNotice(this.id, this.text, {this.read = false});
}

List<AppNotice> _seedNotices() => [
      AppNotice('n1', 'Beli 3 cone, diskon 10% hari ini (contoh).'),
      AppNotice('n2', 'Pesananmu #AC-0987 sudah tiba (contoh).', read: true),
      AppNotice('n3', 'Voucher HEMAT10 berlaku sampai akhir pekan (contoh).'),
    ];

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

  // Mix packs built by the person (device only). Each one is a cart item.
  final Map<String, Product> _mix = {};
  int _mixNo = 1;

  // Saved addresses and notifications (device only)
  final List<String> saved = List.of(savedAddresses);
  final List<AppNotice> notices = _seedNotices();

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
          if (e.value > 0) _find(e.key): e.value,
      };
  Product _find(String id) => _mix[id] ?? productById(id);
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

  /// Adds a mix pack to the cart. [picks] must hold exactly [size] items and
  /// [size] must be a size in [mixPackPrices]. Returns the cart item.
  Product addMixPack(int size, Map<Product, int> picks) {
    final price = mixPackPrices[size];
    final count = picks.values.fold(0, (a, b) => a + b);
    if (price == null || count != size) {
      throw ArgumentError('A mix pack of $size needs exactly $size items');
    }
    final detail = [
      for (final e in picks.entries)
        if (e.value > 0) '${e.value} ${e.key.name}',
    ].join(', ');
    final p = Product('mix-${_mixNo++}', 'Paket Mix $size', 'mix', detail, price,
        photo: 'paket-cone.webp');
    _mix[p.id] = p;
    add(p);
    return p;
  }

  /// Puts the items of a past order back in the cart. Returns how many lines
  /// could not be added (mix packs, or products that are sold out now).
  int reorder(Order o) {
    var skipped = 0;
    for (final l in o.lines) {
      final id = l.productId;
      final p = id == null ? null : catalog.where((x) => x.id == id).firstOrNull;
      if (p == null || p.soldOut) {
        skipped++;
      } else {
        add(p, l.qty);
      }
    }
    return skipped;
  }

  int get unreadCount => notices.where((n) => !n.read).length;

  void markNoticeRead(AppNotice n) {
    n.read = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in notices) {
      n.read = true;
    }
    notifyListeners();
  }

  void addAddress(String a) {
    final t = a.trim();
    if (t.isEmpty || saved.contains(t)) return;
    saved.add(t);
    notifyListeners();
  }

  void removeAddress(String a) {
    saved.remove(a);
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
          if (e.key.category == 'mix')
            OrderLine(e.key.name, e.value, e.key.price, detail: e.key.size)
          else
            OrderLine(e.key.name, e.value, e.key.price, productId: e.key.id),
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
    notices.insert(0, AppNotice('o${o.id}', 'Pesanan ${o.id} diterima toko (contoh).'));
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
    _mix.clear();
    saved
      ..clear()
      ..addAll(savedAddresses);
    notices
      ..clear()
      ..addAll(_seedNotices());
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
      lines: const [
        OrderLine('Cone Vanila Stroberi', 3, 5000, productId: 'cone-vanila')
      ],
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
