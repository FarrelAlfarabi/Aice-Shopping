import 'package:flutter/material.dart';
import 'accounts.dart';
import 'data.dart';
import 'i18n.dart';
import 'pricing.dart';
import 'stock.dart';

enum AppRole { consumer, admin }

/// Where an order is. A bank transfer order starts at [pendingPayment] and
/// only moves on when the admin confirms the transfer. Other payments are
/// treated as paid straight away.
enum OrderStatus { pendingPayment, pendingPrep, shipping, delivered }

class OrderLine {
  final String name;
  final int qty;
  final int price;
  final String? productId; // null for a mix pack (it cannot be re-ordered)
  final String? detail; // for a mix pack: which flavours
  const OrderLine(
    this.name,
    this.qty,
    this.price, {
    this.productId,
    this.detail,
  });
}

/// One item in the notification list (sample text, shown as "contoh").
class AppNotice {
  final String id;
  final String text;
  bool read;
  AppNotice(this.id, this.text, {this.read = false});
}

List<AppNotice> _seedNotices() => [
  AppNotice('n1', 'Beli 3 cone, diskon 10% hari ini.'),
  AppNotice('n2', 'Pesananmu #AC-0987 sudah tiba.', read: true),
  AppNotice('n3', 'Voucher HEMAT10 berlaku sampai akhir pekan.'),
];

enum PointKind { earn, redeem, bonus }

class PointEntry {
  final DateTime at;
  final PointKind kind;
  final String ref; // order id, empty for the bonus
  final int points; // negative when redeemed
  const PointEntry(this.at, this.kind, this.ref, this.points);
}

/// Points of one demo member. In memory only, like everything else.
class MemberAccount {
  int balance;
  int lifetime; // points ever earned: decides the tier
  final List<PointEntry> history;
  MemberAccount(this.balance, this.lifetime, [List<PointEntry>? h])
    : history = h ?? [];
}

MemberAccount _seedAccount(Customer c) {
  final now = DateTime.now();
  PointEntry e(int daysAgo, PointKind k, String ref, int pts) =>
      PointEntry(now.subtract(Duration(days: daysAgo)), k, ref, pts);
  final h = switch (c.id) {
    'c-jaya' => [
      e(1, PointKind.earn, '#AC-1904', 96),
      e(5, PointKind.earn, '#AC-1911', 240),
      e(7, PointKind.redeem, '#AC-1907', -500),
    ],
    'c-kios' => [
      e(1, PointKind.earn, '#AC-1904', 96),
      e(13, PointKind.earn, '#AC-1902', 664),
    ],
    'c-rina' => [
      e(2, PointKind.earn, '#AC-1901', 54),
      e(15, PointKind.bonus, '', 156),
    ],
    _ => <PointEntry>[],
  };
  return MemberAccount(c.startBalance, c.startLifetime, h);
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
  final String customerId;
  final String customerName;
  OrderStatus status;
  DateTime? paidAt;
  DateTime trackStart; // when the trip started (tracking clock)
  bool reported = false;
  bool transferClaimed = false; // buyer says the transfer is done
  int pointsEarn; // points this order gives once the payment is confirmed
  bool pointsAwarded;
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
    this.customerId = 'guest',
    this.customerName = 'Tamu',
    this.status = OrderStatus.shipping,
    this.paidAt,
    DateTime? trackStart,
    this.pointsEarn = 0,
    this.pointsAwarded = false,
  }) : trackStart = trackStart ?? placedAt;

  bool get isPaid => paidAt != null;
  PayFlow get flow => payOption(payment).flow;
  bool get waiting =>
      status == OrderStatus.pendingPayment || status == OrderStatus.pendingPrep;
  int get units => lines.fold(0, (a, l) => a + l.qty);
}

class AppState extends ChangeNotifier {
  // Choices
  Store store = stores.first;
  String address = ''; // empty until the person sets it
  String slot = 'Sekarang';
  String payment = 'E-wallet';
  bool introSeen = false;

  // Demo role, language and the person using the app (sample accounts only)
  AppRole role = AppRole.consumer;
  String lang = 'id'; // 'id' or 'en'. Used by the admin and the new screens.
  Customer customer = guestCustomer;
  final List<Customer> registered = [];
  final Map<String, MemberAccount> members = {};
  int redeem = 0; // points the person wants to use on this cart
  final Set<String> permissions = {...defaultPermissions};

  // Stock and alarms (shared with the admin)
  Map<String, StockInfo> stock = seedStock();
  List<ColdAlarm> coldAlarms = seedColdAlarms();

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
  // Every order of every customer. The consumer sees only their own; the admin
  // sees all of them. Both read this one list.
  final List<Order> allOrders = [_sampleOrder(), ..._seedOrders()];
  int _orderNo = 1;

  List<Order> get history =>
      allOrders.where((o) => o.customerId == customer.id).toList();

  bool get signedIn => customer.id != guestCustomer.id;
  List<Customer> get customers => [...demoAccounts, ...registered];

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
  Pricing get pricing => computePricing(
    lines,
    voucher,
    vip: isVip,
    freeDelivery: tier.freeDelivery,
    redeemPoints: redeem,
    flashActive: flashOn,
  );

  // ------------------------------------------------------------ Flash Sale
  DateTime flashEnd = DateTime.now().add(const Duration(minutes: flashMinutes));
  bool get flashOn => DateTime.now().isBefore(flashEnd);
  Duration get flashLeft =>
      flashOn ? flashEnd.difference(DateTime.now()) : Duration.zero;

  // ------------------------------------------------------------ Membership
  MemberAccount _acc(Customer c) =>
      members.putIfAbsent(c.id, () => _seedAccount(c));
  MemberAccount accountOf(Customer c) => _acc(c);
  bool get isMember => signedIn;
  int get balance => signedIn ? _acc(customer).balance : 0;
  int get lifetime => signedIn ? _acc(customer).lifetime : 0;
  MemberTier get tier => tierForPoints(lifetime);
  bool get isVip => tier.vipPrice;
  MemberTier tierOf(Customer c) => tierForPoints(_acc(c).lifetime);
  int get maxRedeem => maxRedeemablePoints(
    lines,
    voucher,
    vip: isVip,
    flashActive: flashOn,
    balance: balance,
  );

  void setRedeem(int pts) {
    redeem = pts.clamp(0, maxRedeem);
    notifyListeners();
  }

  void _award(Order o) {
    if (o.pointsAwarded || o.customerId == guestCustomer.id) return;
    o.pointsAwarded = true;
    final c = customers.where((c) => c.id == o.customerId);
    if (c.isEmpty || o.pointsEarn <= 0) return;
    final a = _acc(c.first);
    a.balance += o.pointsEarn;
    a.lifetime += o.pointsEarn;
    a.history.insert(
      0,
      PointEntry(DateTime.now(), PointKind.earn, o.id, o.pointsEarn),
    );
    if (c.first.id == customer.id) {
      notices.insert(
        0,
        AppNotice('p${o.id}', '+${o.pointsEarn} poin dari pesanan ${o.id}.'),
      );
    }
  }

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
    final p = Product(
      'mix-${_mixNo++}',
      'Paket Mix $size',
      'mix',
      detail,
      price,
      photo: 'paket-cone.webp',
    );
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
      final p = id == null
          ? null
          : catalog.where((x) => x.id == id).firstOrNull;
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
    final flow = payOption(payment).flow;
    final transfer = flow == PayFlow.bankTransfer;
    final cod = flow == PayFlow.cod;
    final now = DateTime.now();
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
      customerId: customer.id,
      customerName: customer.name,
      status: transfer
          ? OrderStatus.pendingPayment
          : (cod ? OrderStatus.pendingPrep : OrderStatus.shipping),
      paidAt: (transfer || cod) ? null : now,
      pointsEarn: signedIn ? pointsFor(p.total) : 0,
    );
    if (p.pointsUsed > 0 && signedIn) {
      final a = _acc(customer);
      a.balance -= p.pointsUsed;
      a.history.insert(
        0,
        PointEntry(now, PointKind.redeem, o.id, -p.pointsUsed),
      );
    }
    redeem = 0;
    if (flow == PayFlow.instant) _award(o);
    // Take the units out of stock (never below zero).
    for (final e in lines.entries) {
      final si = stock[e.key.id];
      if (si != null) si.stock = (si.stock - e.value).clamp(0, 1 << 30);
    }
    current = o;
    allOrders.insert(0, o);
    notices.insert(
      0,
      AppNotice(
        'o${o.id}',
        transfer
            ? 'Pesanan ${o.id} menunggu transfer dikonfirmasi penjual (contoh).'
            : (cod
                  ? 'Pesanan ${o.id} diterima. Bayar ke kurir saat tiba (contoh).'
                  : 'Pesanan ${o.id} diterima toko (contoh).'),
      ),
    );
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
    resetData();
    current = null;
    customer = guestCustomer;
    registered.clear();
    store = stores.first;
    address = '';
    slot = 'Sekarang';
    payment = 'E-wallet';
    makeLate = false;
    introSeen = false;
    role = AppRole.consumer;
    lang = 'id';
    appLang = 'id';
    notifyListeners();
  }

  /// Puts orders, stock, alarms and permissions back to the sample start.
  /// Used by the admin's "Reset data demo" button. Keeps the person's role,
  /// language and sign-in.
  void resetData() {
    members.clear();
    redeem = 0;
    flashEnd = DateTime.now().add(const Duration(minutes: flashMinutes));
    allOrders
      ..clear()
      ..addAll([_sampleOrder(), ..._seedOrders()]);
    stock = seedStock();
    coldAlarms = seedColdAlarms();
    permissions
      ..clear()
      ..addAll(defaultPermissions);
    current = null;
    notifyListeners();
  }

  // ------------------------------------------------------------- Accounts
  // Demo only: no password is checked and no OTP is really sent.

  void setRole(AppRole r) {
    role = r;
    notifyListeners();
  }

  void setLang(String l) {
    lang = l;
    appLang = l; // read by tr() in i18n.dart
    notifyListeners();
  }

  void signIn(Customer c) {
    customer = c;
    redeem = 0;
    _recheckVoucher();
    notifyListeners();
  }

  void signOut() {
    customer = guestCustomer;
    redeem = 0;
    _recheckVoucher();
    notifyListeners();
  }

  /// Finds a demo account by phone digits. Null when there is none.
  Customer? findByPhone(String phone) {
    final d = digitsOnly(phone);
    if (d.isEmpty) return null;
    for (final c in customers) {
      if (digitsOnly(c.phone).endsWith(d) || d.endsWith(digitsOnly(c.phone))) {
        return c;
      }
    }
    return null;
  }

  /// Makes a new sample account and signs it in. A correct invite code makes
  /// it VIP.
  Customer register(String name, String phone, String invite) {
    final c = Customer(
      'c-new-${registered.length + 1}',
      name.trim().isEmpty ? 'Pelanggan Baru' : name.trim(),
      phone.trim(),
      memberNo:
          'ICE-${(100 + registered.length + 4).toString().padLeft(4, '0')}',
      startBalance: signupBonusPoints,
      startLifetime: invite.trim().toUpperCase() == inviteCodeVip
          ? memberTiers.last.minPoints
          : signupBonusPoints,
    );
    registered.add(c);
    members[c.id] = MemberAccount(c.startBalance, c.startLifetime, [
      PointEntry(DateTime.now(), PointKind.bonus, '', signupBonusPoints),
    ]);
    signIn(c);
    return c;
  }

  // ----------------------------------------------------------- Admin side

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _isThisMonth(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month;
  }

  int get newOrdersToday =>
      allOrders.where((o) => !o.sample && _isToday(o.placedAt)).length;
  List<Order> get prepTasks =>
      allOrders.where((o) => o.status == OrderStatus.pendingPrep).toList();
  int get vipCount => customers.where((c) => tierOf(c).vipPrice).length;
  int get pointsOutstanding => customers.fold(0, (a, c) => a + _acc(c).balance);
  int tierCount(String key) =>
      customers.where((c) => tierOf(c).key == key).length;
  List<MapEntry<Product, StockInfo>> get lowStock => [
    for (final p in catalog)
      if (stock[p.id]?.low ?? false) MapEntry(p, stock[p.id]!),
  ];
  int get paymentsThisMonth =>
      baselinePayments +
      allOrders
          .where(
            (o) => !o.sample && o.paidAt != null && _isThisMonth(o.paidAt!),
          )
          .fold(0, (a, o) => a + o.pricing.total);
  int get expensesThisMonth => seedExpenses.fold(0, (a, e) => a + e.amount);
  List<Order> get unpaidOrders =>
      allOrders.where((o) => o.status == OrderStatus.pendingPayment).toList();
  int get unpaidTotal => unpaidOrders.fold(0, (a, o) => a + o.pricing.total);
  int get openColdAlarms => coldAlarms.where((a) => !a.resolved).length;
  int get alarmCount => lowStock.length + openColdAlarms;

  /// Admin confirms the bank transfer. The order moves to "pending
  /// preparation" and shows up as a delivery task.
  void confirmTransfer(Order o) {
    if (o.status != OrderStatus.pendingPayment) return;
    o.status = OrderStatus.pendingPrep;
    o.paidAt = DateTime.now();
    _award(o);
    if (o.customerId == customer.id) {
      notices.insert(
        0,
        AppNotice(
          'c${o.id}',
          'Transfer pesanan ${o.id} dikonfirmasi, pesanan disiapkan (contoh).',
        ),
      );
    }
    notifyListeners();
  }

  /// Admin sends the order out. The consumer's tracking clock starts now.
  void startDelivery(Order o) {
    if (o.status != OrderStatus.pendingPrep) return;
    o.status = OrderStatus.shipping;
    o.trackStart = DateTime.now();
    if (o.customerId == customer.id) {
      notices.insert(
        0,
        AppNotice('s${o.id}', 'Pesanan ${o.id} sedang diantar.'),
      );
    }
    notifyListeners();
  }

  /// The buyer says the bank transfer is done. Only the admin can confirm it.
  void claimTransfer(Order o) {
    if (o.flow != PayFlow.bankTransfer ||
        o.status != OrderStatus.pendingPayment) {
      return;
    }
    o.transferClaimed = true;
    notifyListeners();
  }

  void markDelivered(Order o) {
    o.status = OrderStatus.delivered;
    if (o.paidAt == null) {
      // Cash on delivery is paid now, so the points are added now.
      o.paidAt = DateTime.now();
      _award(o);
    }
    notifyListeners();
  }

  void restock(String productId, [int n = 40]) {
    final si = stock[productId];
    if (si == null) return;
    si.stock += n;
    notifyListeners();
  }

  void resolveCold(ColdAlarm a) {
    a.resolved = true;
    notifyListeners();
  }

  void simulateColdFailure() {
    coldAlarms.add(
      ColdAlarm(
        'p0-${coldAlarms.length + 1}',
        'Suhu kotak dingin kurir naik di atas -10 °C (contoh)',
      ),
    );
    notifyListeners();
  }

  void togglePermission(String key) {
    if (!permissions.remove(key)) permissions.add(key);
    notifyListeners();
  }
}

/// Sample permission switches for the admin settings tab (in memory only).
const defaultPermissions = <String>{
  'sales:confirm',
  'sales:orders',
  'warehouse:stock',
  'courier:delivery',
};

/// Orders of other sample customers so the admin has something to show.
List<Order> _seedOrders() {
  Order mk(
    String id,
    Customer c,
    Map<String, int> items,
    OrderStatus st,
    Duration ago, {
    String payment = 'Transfer bank',
  }) {
    final placed = DateTime.now().subtract(ago);
    final map = {for (final e in items.entries) productById(e.key): e.value};
    final t = tierForPoints(c.startLifetime);
    final pr = computePricing(
      map,
      null,
      vip: t.vipPrice,
      freeDelivery: t.freeDelivery,
    );
    return Order(
      id: id,
      lines: [
        for (final e in map.entries)
          OrderLine(e.key.name, e.value, e.key.price, productId: e.key.id),
      ],
      pricing: pr,
      storeName: stores.first.name,
      address: c.address,
      payment: payment,
      placedAt: placed,
      late: false,
      demoSeconds: 75,
      customerId: c.id,
      customerName: c.name,
      status: st,
      paidAt: st == OrderStatus.pendingPayment ? null : placed,
      pointsEarn: pointsFor(pr.total),
      pointsAwarded: st != OrderStatus.pendingPayment,
    );
  }

  return [
    mk(
      '#AC-2001',
      demoAccounts[0],
      {'cone-vanila': 6, 'cone-cokelat': 6},
      OrderStatus.pendingPayment,
      const Duration(minutes: 20),
    ),
    mk(
      '#AC-2002',
      demoAccounts[0],
      {'stik-cokelat': 12},
      OrderStatus.pendingPayment,
      const Duration(hours: 1),
    ),
    mk(
      '#AC-2003',
      demoAccounts[1],
      {'tub-stroberi': 4, 'cup-blueberry': 4},
      OrderStatus.pendingPrep,
      const Duration(hours: 5),
    ),
    mk(
      '#AC-2004',
      demoAccounts[2],
      {'bundle-keluarga': 2},
      OrderStatus.delivered,
      const Duration(days: 1),
    ),
    mk(
      '#AC-2005',
      demoAccounts[1],
      {'drink-cokelat': 6, 'cup-matcha': 4},
      OrderStatus.delivered,
      const Duration(days: 2),
      payment: 'QRIS',
    ),
  ];
}

Order _sampleOrder() => Order(
  id: '#AC-0987',
  lines: const [
    OrderLine('Cone Vanila Stroberi', 3, 5000, productId: 'cone-vanila'),
  ],
  pricing: computePricing({productById('cone-vanila'): 3}, null),
  storeName: stores.first.name,
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
