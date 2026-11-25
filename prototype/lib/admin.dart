import 'package:flutter/material.dart' hide Text;
import 'consumer_extras.dart';
import 'data.dart';
import 'format.dart';
import 'membership.dart';
import 'i18n.dart';
import 'pricing.dart';
import 'state.dart';
import 'stock.dart';
import 'ui.dart';

/// Admin side of the demo. It reads and writes the same [AppState] as the
/// consumer app, so a consumer order shows up here and confirming a transfer
/// here changes the consumer's order status. Everything is sample data in
/// memory (no backend).
const _tabs = [
  'Ringkasan',
  'Pesanan',
  'Antar',
  'Stok',
  'Keuangan',
  'Alarm',
  'Analisis',
  'Pengaturan & Izin',
];

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Header(s),
            const SizedBox(height: 12),
            _Kpis(s),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  SmallChip(
                    _tabs[i],
                    key: ValueKey('admin-tab-$i'),
                    on: tab == i,
                    onTap: () => setState(() => tab = i),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            switch (tab) {
              0 => _Overview(s),
              1 => _OrdersTab(s),
              2 => _DeliveryTab(s),
              3 => _StockTab(s),
              4 => _FundsTab(s),
              5 => _AlarmsTab(s),
              6 => _AnalysisTab(s),
              _ => _SettingsTab(s),
            },
            const SizedBox(height: 12),
            const Center(child: Text(footerText, style: tMuted)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppState s;
  const _Header(this.s);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(rCard + 4),
      gradient: const LinearGradient(colors: [C.priDark, C.pri]),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aice Shopping · Admin (demo)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Contoh sistem penjualan: pembayaran, antar, stok, dana, dan alarm dalam satu alur.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              key: const ValueKey('open-consumer'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              onPressed: () => s.setRole(AppRole.consumer),
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: const Text('Buka aplikasi konsumen'),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const LangChips(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              key: const ValueKey('reset-data'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: C.priDark,
              ),
              onPressed: () async {
                if (await confirmAction(
                  context,
                  title: 'Reset data demo?',
                  body:
                      'Pesanan, stok, alarm, poin dan izin kembali ke contoh awal.',
                  yes: 'Reset',
                )) {
                  s.resetData();
                }
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset data demo'),
            ),
            const Text(
              'Sebelum demo, klik sekali untuk mengembalikan data ke kondisi awal (contoh).',
              style: TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Kpis extends StatelessWidget {
  final AppState s;
  const _Kpis(this.s);
  @override
  Widget build(BuildContext context) {
    final cards = <(String, String, Color?)>[
      ('Pesanan baru hari ini', '${s.newOrdersToday} pesanan', null),
      ('Tugas antar menunggu', '${s.prepTasks.length}', null),
      ('Pelanggan VIP', '${s.vipCount}', null),
      (
        'Barang stok menipis',
        '${s.lowStock.length}',
        s.lowStock.isEmpty ? null : C.danger,
      ),
      ('Pembayaran bulan ini', rp(s.paymentsThisMonth), C.good),
      ('Pengeluaran bulan ini', rp(s.expensesThisMonth), null),
      (
        'Pesanan belum dibayar',
        '${s.unpaidOrders.length} · ${rp(s.unpaidTotal)}',
        s.unpaidOrders.isEmpty ? null : C.danger,
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 600 ? 3 : 2);
        final w = (c.maxWidth - 10 * (cols - 1)) / cols;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final k in cards)
              SizedBox(
                width: w,
                child: Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(k.$1, style: tMuted),
                      const SizedBox(height: 4),
                      Text(
                        k.$2,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: k.$3 ?? C.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Orders

String adminStatus(Order o) {
  switch (o.status) {
    case OrderStatus.pendingPayment:
      return 'Menunggu pembayaran';
    case OrderStatus.pendingPrep:
      return 'Menunggu disiapkan';
    case OrderStatus.shipping:
      return 'Dikirim';
    case OrderStatus.delivered:
      return 'Selesai';
  }
}

Color _statusBg(OrderStatus st) => switch (st) {
  OrderStatus.pendingPayment => const Color(0xFFFFE3E1),
  OrderStatus.pendingPrep => C.warnBg,
  OrderStatus.shipping => C.tint,
  OrderStatus.delivered => const Color(0xFFDFF6E7),
};

String itemsText(Order o) =>
    o.lines.map((l) => '${l.name} x${l.qty}').join(', ');

class OrderRow extends StatelessWidget {
  final AppState s;
  final Order o;
  final bool actions;
  const OrderRow(this.s, this.o, {super.key, this.actions = true});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: C.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(o.id, style: tBold)),
            const SizedBox(width: 6),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusBg(o.status),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  adminStatus(o),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        Text(o.customerName, style: tMuted),
        if (o.reported)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              key: ValueKey('reported-${o.id}'),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: C.dangerBg,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                'Ada laporan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: C.danger,
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        Text(itemsText(o)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('${rp(o.pricing.total)} · ${o.payment}', style: tMuted),
            if (actions) ..._actions(),
          ],
        ),
      ],
    ),
  );

  List<Widget> _actions() {
    switch (o.status) {
      case OrderStatus.pendingPayment:
        return [
          FilledButton(
            key: ValueKey('confirm-${o.id}'),
            onPressed: () => s.confirmTransfer(o),
            child: const Text('Konfirmasi transfer'),
          ),
        ];
      case OrderStatus.pendingPrep:
        return [
          FilledButton(
            key: ValueKey('start-${o.id}'),
            onPressed: () => s.startDelivery(o),
            child: const Text('Tandai diantar'),
          ),
        ];
      case OrderStatus.shipping:
        return [
          OutlinedButton(
            key: ValueKey('done-${o.id}'),
            onPressed: () => s.markDelivered(o),
            child: const Text('Tandai selesai'),
          ),
        ];
      case OrderStatus.delivered:
        return const [];
    }
  }
}

class _Overview extends StatelessWidget {
  final AppState s;
  const _Overview(this.s);
  @override
  Widget build(BuildContext context) {
    final latest = s.allOrders.take(6).toList();
    final orders = Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pesanan terbaru', style: tH3),
          const SizedBox(height: 2),
          const Text(
            'Pembeli memesan: status "Menunggu pembayaran". Setelah transfer dikonfirmasi, pesanan masuk "Menunggu disiapkan" dan tugas antar dibuat.',
            style: tMuted,
          ),
          const SizedBox(height: 10),
          for (final o in latest) OrderRow(s, o),
        ],
      ),
    );
    final alarms = Column(
      children: [
        _AlarmList(s),
        const SizedBox(height: 12),
        MembersAdminCard(s),
      ],
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 800
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: orders),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: alarms),
              ],
            )
          : Column(children: [orders, const SizedBox(height: 12), alarms]),
    );
  }
}

class _OrdersTab extends StatefulWidget {
  final AppState s;
  const _OrdersTab(this.s);
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  OrderStatus? filter;
  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final list = s.allOrders.where((o) => filter == null || o.status == filter);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SmallChip(
              'Semua',
              on: filter == null,
              onTap: () => setState(() => filter = null),
            ),
            for (final st in OrderStatus.values)
              SmallChip(
                adminStatus(
                  Order(
                    id: '',
                    lines: const [],
                    pricing: computePricing(const {}, null),
                    storeName: '',
                    address: '',
                    payment: '',
                    placedAt: DateTime.now(),
                    late: false,
                    demoSeconds: 1,
                    status: st,
                  ),
                ),
                on: filter == st,
                onTap: () => setState(() => filter = st),
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (final o in list) OrderRow(s, o),
      ],
    );
  }
}

class _DeliveryTab extends StatelessWidget {
  final AppState s;
  const _DeliveryTab(this.s);
  @override
  Widget build(BuildContext context) {
    final tasks = s.allOrders
        .where(
          (o) =>
              o.status == OrderStatus.pendingPrep ||
              o.status == OrderStatus.shipping,
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tugas antar', style: tH3),
        const Text(
          'Dibuat otomatis setelah transfer dikonfirmasi.',
          style: tMuted,
        ),
        const SizedBox(height: 10),
        if (tasks.isEmpty) const Panel(child: Text('Belum ada tugas antar.')),
        for (final o in tasks) OrderRow(s, o),
      ],
    );
  }
}

// ----------------------------------------------------------------- Stock

class _StockTab extends StatelessWidget {
  final AppState s;
  const _StockTab(this.s);
  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stok (contoh)', style: tH3),
        const SizedBox(height: 8),
        for (final p in catalog)
          if (s.stock[p.id] != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: tBold),
                        Text(
                          'Stok ${s.stock[p.id]!.stock} · Titik pesan ulang ${s.stock[p.id]!.reorder}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: s.stock[p.id]!.low ? C.danger : C.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    key: ValueKey('restock-${p.id}'),
                    onPressed: () => s.restock(p.id),
                    child: const Text('+40 stok'),
                  ),
                ],
              ),
            ),
      ],
    ),
  );
}

// ----------------------------------------------------------------- Funds

class _FundsTab extends StatelessWidget {
  final AppState s;
  const _FundsTab(this.s);
  @override
  Widget build(BuildContext context) {
    final paid = s.allOrders
        .where((o) => !o.sample && o.paidAt != null)
        .toList();
    return Column(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Keuangan bulan ini (contoh)', style: tH3),
              const SizedBox(height: 8),
              _line('Penjualan awal bulan (contoh)', rp(baselinePayments)),
              for (final o in paid)
                _line('${o.id} · ${o.customerName}', rp(o.pricing.total)),
              const Divider(),
              _line('Total pembayaran', rp(s.paymentsThisMonth), bold: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pengeluaran (contoh)', style: tH3),
              const SizedBox(height: 8),
              for (final e in seedExpenses) _line(e.label, rp(e.amount)),
              const Divider(),
              _line('Total pengeluaran', rp(s.expensesThisMonth), bold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _line(String a, String b, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(a, style: bold ? tBold : null)),
        Text(b, style: bold ? tBold : null),
      ],
    ),
  );
}

// ---------------------------------------------------------------- Alarms

class _AlarmList extends StatelessWidget {
  final AppState s;
  const _AlarmList(this.s);
  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stok menipis / alarm', style: tH3),
        const SizedBox(height: 2),
        const Text(
          'Alarm P1 muncul otomatis saat stok turun ke titik pesan ulang. Kegagalan rantai dingin adalah alarm P0.',
          style: tMuted,
        ),
        const SizedBox(height: 10),
        for (final a in s.coldAlarms.where((a) => !a.resolved))
          _alarmRow(
            'P0',
            a.text,
            C.danger,
            action: TextButton(
              key: ValueKey('resolve-${a.id}'),
              onPressed: () => s.resolveCold(a),
              child: const Text('Selesai'),
            ),
          ),
        for (final e in s.lowStock)
          _alarmRow(
            'P1',
            '${e.key.name} · stok ${e.value.stock} (titik ${e.value.reorder})',
            const Color(0xFF8A5A00),
          ),
        if (s.alarmCount == 0) const Text('Tidak ada alarm.'),
      ],
    ),
  );

  Widget _alarmRow(String level, String text, Color color, {Widget? action}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                level,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
            if (action != null) action,
          ],
        ),
      );
}

class _AlarmsTab extends StatelessWidget {
  final AppState s;
  const _AlarmsTab(this.s);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _AlarmList(s),
      const SizedBox(height: 10),
      OutlinedButton(
        key: const ValueKey('sim-cold'),
        onPressed: s.simulateColdFailure,
        child: const Text('Simulasikan kegagalan rantai dingin (P0)'),
      ),
    ],
  );
}

// -------------------------------------------------------------- Analysis

class _AnalysisTab extends StatelessWidget {
  final AppState s;
  const _AnalysisTab(this.s);
  @override
  Widget build(BuildContext context) {
    final byCat = <String, int>{};
    final byProduct = <String, int>{};
    for (final o in s.allOrders.where((o) => !o.sample)) {
      for (final l in o.lines) {
        final id = l.productId;
        if (id == null) continue;
        final p = catalog.where((x) => x.id == id).firstOrNull;
        if (p == null) continue;
        byCat[p.category] = (byCat[p.category] ?? 0) + l.qty * l.price;
        byProduct[p.name] = (byProduct[p.name] ?? 0) + l.qty;
      }
    }
    final maxV = byCat.values.fold(1, (a, b) => a > b ? a : b);
    final top = byProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Penjualan per kategori (contoh)', style: tH3),
              const SizedBox(height: 8),
              for (final e in byCat.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(categories[e.key] ?? e.key),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: e.value / maxV,
                            minHeight: 14,
                            backgroundColor: C.tint,
                            color: C.pri,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(rp(e.value), style: tMuted),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Produk terlaris (contoh)', style: tH3),
              const SizedBox(height: 8),
              for (final e in top.take(5))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Text('${e.value} pcs', style: tBold),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- Settings

const _permissionRows = <(String, String)>[
  ('sales:confirm', 'Penjual: konfirmasi transfer'),
  ('sales:orders', 'Penjual: lihat semua pesanan'),
  ('warehouse:stock', 'Gudang: ubah stok'),
  ('courier:delivery', 'Kurir: mulai dan selesaikan antar'),
];

class _SettingsTab extends StatelessWidget {
  final AppState s;
  const _SettingsTab(this.s);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Izin peran (contoh, hanya tampilan)', style: tH3),
            for (final r in _permissionRows)
              SwitchListTile(
                key: ValueKey('perm-${r.$1}'),
                contentPadding: EdgeInsets.zero,
                title: Text(r.$2),
                value: s.permissions.contains(r.$1),
                onChanged: (_) => s.togglePermission(r.$1),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Janji dan harga (dari satu konfigurasi)', style: tH3),
            const SizedBox(height: 6),
            _kv('Ongkir dasar', rp(Pricing.baseFee)),
            _kv('Gratis ongkir mulai', rp(Pricing.freeThreshold)),
            _kv('Minimum belanja', rp(Pricing.minOrder)),
            _kv('Harga member (VIP, tingkat Gold)', '-$vipPercent%'),
            _kv(
              'Poin',
              '1 poin tiap ${rp(pointsEarnRp)}, 100 poin = ${rp(100 * pointValueRp)}',
            ),
            _kv('Diskon 1 karton', '-$cartonPercent%'),
          ],
        ),
      ),
    ],
  );

  Widget _kv(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(a)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(b, style: tBold, textAlign: TextAlign.end),
        ),
      ],
    ),
  );
}
