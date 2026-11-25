import 'dart:async';
import 'package:flutter/material.dart' hide Text;
import 'assistant.dart';
import 'i18n.dart';
import 'format.dart';
import 'membership.dart';
import 'payment_ui.dart';
import 'pricing.dart';
import 'screens_a.dart';
import 'screens_c.dart';
import 'consumer_extras.dart';
import 'state.dart';
import 'tracking.dart';
import 'ui.dart';

String _hm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

/// Delivery slots are counted from "now" (the demo clock), never fixed times.
List<String> deliverySlots() {
  final n = DateTime.now();
  var start = DateTime(n.year, n.month, n.day, n.hour, n.minute < 30 ? 30 : 0)
      .add(Duration(hours: n.minute < 30 ? 0 : 1))
      .add(const Duration(minutes: 30));
  return [
    'Sekarang (15 menit)',
    for (var i = 0; i < 2; i++)
      '${_hm(start.add(Duration(minutes: 30 * i)))}-${_hm(start.add(Duration(minutes: 30 * (i + 1))))}',
  ];
}

class CartTab extends StatefulWidget {
  const CartTab({super.key});
  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final ctl = TextEditingController();
  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  void _addMore() => tabIndex.value = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    if (s.cartEmpty) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: C.muted,
                ),
                const SizedBox(height: 12),
                const Text('Keranjang masih kosong', style: tH2),
                const SizedBox(height: 6),
                const Text(
                  'Pilih es krim favoritmu dulu.',
                  style: tMuted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                BigButton(
                  'Belanja sekarang',
                  onPressed: () => tabIndex.value = 0,
                ),
              ],
            ),
          ),
        ),
      );
    }
    final p = s.pricing;
    final lines = s.lines;
    final coneQty = lines.entries
        .where((e) => e.key.multiBuy)
        .fold(0, (a, e) => a + e.value);
    final slots = deliverySlots();
    if (!slots.contains(s.slot)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => s.setSlot(slots.first),
      );
    }
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Keranjang', style: tH2),
                const SizedBox(height: 12),
                Panel(
                  child: Column(
                    children: [
                      for (final e in lines.entries) ...[
                        Row(
                          children: [
                            SizedBox(width: 56, child: ProductImage(e.key)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.key.name, style: tBold),
                                  if (e.key.category == 'mix')
                                    Text(e.key.size, style: tMuted),
                                  Text(
                                    rp(e.key.price * e.value),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            QtyStepper(
                              qty: e.value,
                              onMinus: () => s.remove(e.key),
                              onPlus: () => s.add(e.key),
                            ),
                          ],
                        ),
                        if (e.key != lines.keys.last) const Divider(height: 20),
                      ],
                    ],
                  ),
                ),
                if (p.belowMinOrder) ...[
                  const SizedBox(height: 10),
                  Panel(
                    color: C.warnBg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Belanja kurang dari ${rp(Pricing.minOrder)} kena biaya kecil ${rp(Pricing.smallOrderFee)}. Tambah ${rp(p.toMinOrder)} lagi, biaya ini hilang.',
                          key: const Key('min-order-note'),
                          style: const TextStyle(
                            color: C.warnInk,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SmallChip('Tambah item', onTap: _addMore),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                if (p.multiBuy > 0)
                  Notice(
                    'Diskon Beli 3 terpasang: hemat ${rp(p.multiBuy)}.',
                    good: true,
                  )
                else if (coneQty > 0)
                  Notice(
                    'Beli 3 cone, diskon 10%: tambah ${3 - coneQty} lagi.',
                  ),
                const SizedBox(height: 10),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Gratis ongkir (belanja ${rp(Pricing.freeThreshold)})',
                              style: tBold,
                            ),
                          ),
                          Text(
                            p.toFreeDelivery == 0
                                ? 'Tercapai'
                                : '${rp(p.toFreeDelivery)} lagi',
                            style: tMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: p.freeProgress,
                          minHeight: 10,
                          color: C.acc,
                          backgroundColor: C.line,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Voucher', style: tH3),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: tr('Masukkan kode'),
                        ),
                        onSubmitted: s.applyVoucher,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () => s.applyVoucher(ctl.text),
                        child: const Text('Pakai'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in vouchers)
                      SmallChip(
                        v.code,
                        onTap: () {
                          ctl.text = v.code;
                          s.applyVoucher(v.code);
                        },
                      ),
                  ],
                ),
                if (s.voucherStatus == VoucherStatus.wrong)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Kode voucher tidak dikenal. Periksa lagi kodenya.',
                      style: TextStyle(
                        color: C.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (s.voucherStatus == VoucherStatus.notMet)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Belanja ${rp(s.voucherShortBy)} lagi untuk memakai voucher ini.',
                      style: const TextStyle(
                        color: C.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (s.voucherStatus == VoucherStatus.ok)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Voucher ${s.voucher!.code} terpasang.',
                            style: const TextStyle(
                              color: C.good,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ctl.clear();
                            s.clearVoucher();
                          },
                          child: const Text('Lepas'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                const Text('Waktu kirim', style: tH3),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final sl in slots)
                      SmallChip(
                        sl,
                        on: s.slot == sl,
                        onTap: () => s.setSlot(sl),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const PaymentRow(),
                const SizedBox(height: 8),
                const RedeemPanel(),
                const SizedBox(height: 8),
                Panel(child: _Summary(p)),
                const SizedBox(height: 8),
                const Center(child: Text(footerText, style: tMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: const BoxDecoration(
              color: C.surface,
              border: Border(top: BorderSide(color: C.line)),
            ),
            child: BigButton(
              'Lanjut bayar',
              trailing: rp(p.total),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CheckoutScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final Pricing p;
  const _Summary(this.p);
  Widget row(String l, String v, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            l,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
              fontSize: bold ? 15 : 14,
            ),
          ),
        ),
        Text(
          v,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            fontSize: bold ? 15 : 14,
            color: color,
          ),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Column(
    children: [
      row('Subtotal', rp(p.subtotal)),
      if (p.multiBuy > 0)
        row('Diskon Beli 3', '-${rp(p.multiBuy)}', color: C.good),
      if (p.tier > 0) row('Diskon jumlah', '-${rp(p.tier)}', color: C.good),
      if (p.flash > 0) row('Flash Sale', '-${rp(p.flash)}', color: C.good),
      if (p.vip > 0) row('Harga member', '-${rp(p.vip)}', color: C.good),
      if (p.voucherDiscount > 0)
        row('Voucher', '-${rp(p.voucherDiscount)}', color: C.good),
      if (p.pointsOff > 0)
        row(
          'Tukar poin (${pts(p.pointsUsed)})',
          '-${rp(p.pointsOff)}',
          color: C.good,
        ),
      row('Ongkir', p.delivery == 0 ? 'Gratis' : rp(p.delivery)),
      if (p.smallFee > 0) row('Biaya belanja kecil', rp(p.smallFee)),
      const Divider(),
      row('Total', rp(p.total), bold: true),
    ],
  );
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.pricing;
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dikirim ke', style: tMuted),
                Text(
                  s.hasAddress ? s.address : 'Alamat belum diatur',
                  key: const ValueKey('checkout-address'),
                  style: s.hasAddress ? tBold : tBold.copyWith(color: C.danger),
                ),
                const SizedBox(height: 6),
                Text('${s.store.name} · ${s.slot}', style: tMuted),
                const SizedBox(height: 6),
                TextButton(
                  key: const ValueKey('checkout-set-address'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => openAddress(context),
                  child: Text(
                    s.hasAddress ? 'Ubah alamat atau toko' : 'Atur alamat',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Metode pembayaran', style: tH3),
          const SizedBox(height: 8),
          for (final m in paymentOptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OptionTile(
                selected: s.payment == m.id,
                title: m.id,
                subtitle: m.note,
                trailing: Icon(payIcon(m.id), color: C.muted),
                onTap: () => s.setPayment(m.id),
              ),
            ),
          const SizedBox(height: 6),
          Panel(child: _Summary(p)),
          const SizedBox(height: 12),
          const Notice(
            'Pesanan dikirim dalam tas pendingin supaya tetap beku.',
          ),
          const SizedBox(height: 10),
          const Text(
            'Demo konsep. Bukan aplikasi resmi Aice. Tidak ada uang yang berpindah.',
            style: tMuted,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: BigButton(
            'Bayar',
            trailing: rp(p.total),
            onPressed: s.cartEmpty
                ? null
                : () async {
                    // No address yet: ask for it first, then go on.
                    if (!s.hasAddress && !await openAddress(context)) return;
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const ProcessingScreen(),
                      ),
                    );
                  },
          ),
        ),
      ),
    );
  }
}

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});
  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final o = AppScope.of(context).placeOrder();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OrderPlacedScreen(o)),
      );
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const PopScope(
    canPop: false,
    child: Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text('Memproses pembayaran (contoh)', style: tH3),
            SizedBox(height: 4),
            Text('Mohon tunggu sebentar.', style: tMuted),
          ],
        ),
      ),
    ),
  );
}

class OrderPlacedScreen extends StatelessWidget {
  final Order o;
  const OrderPlacedScreen(this.o, {super.key});
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 48),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: C.good,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Pesanan diterima', style: tH2),
                    const SizedBox(height: 6),
                    Text('${o.id} · ${o.storeName}', style: tMuted),
                    const SizedBox(height: 4),
                    if (o.status == OrderStatus.pendingPayment)
                      const Text(
                        'Menunggu transfer dikonfirmasi penjual',
                        style: tBold,
                      )
                    else
                      Text(
                        'Perkiraan tiba $sampleEtaMinutes menit (contoh)',
                        style: tBold,
                      ),
                    const SizedBox(height: 8),
                    PayInstructions(o),
                    const SizedBox(height: 4),
                    Text(
                      'Total ${rp(o.pricing.total)} · ${o.payment}',
                      style: tMuted,
                    ),
                    if (o.pointsEarn > 0)
                      Text(
                        o.pointsAwarded
                            ? '+${pts(o.pointsEarn)} poin sudah ditambahkan'
                            : (o.flow == PayFlow.cod
                                  ? '+${pts(o.pointsEarn)} poin, ditambahkan setelah pesanan selesai'
                                  : '+${pts(o.pointsEarn)} poin, ditambahkan setelah transfer dikonfirmasi'),
                        style: const TextStyle(
                          color: C.good,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const Spacer(),
                    BigButton(
                      o.waiting ? 'Lihat status pesanan' : 'Lacak pesanan',
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => TrackingScreen(o)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BigButton(
                      'Kembali ke beranda',
                      secondary: true,
                      onPressed: () {
                        tabIndex.value = 0;
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(footerText, style: tMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class TrackingScreen extends StatefulWidget {
  final Order o;
  const TrackingScreen(this.o, {super.key});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  TrackState state() {
    final o = widget.o;
    final elapsed =
        DateTime.now().difference(o.trackStart).inMilliseconds / 1000.0;
    return trackAt(elapsed, o.demoSeconds, forceLate: o.late);
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.o;
    AppScope.of(context); // rebuild when the admin changes the status
    if (o.waiting) return OrderWaitingView(o);
    final st = state();
    const names = [
      'Pesanan diterima',
      'Sedang disiapkan',
      'Dalam perjalanan',
      'Tiba di tujuan',
    ];
    final idx = st.phase.index;
    final head = st.delivered
        ? 'Pesanan tiba'
        : st.isLate
        ? 'Terlambat'
        : 'Tiba dalam';
    final big = st.delivered
        ? 'Selamat menikmati'
        : st.isLate
        ? '${st.minutesLate.floor()} mnt'
        : clock(st.minutesLeft);
    return Scaffold(
      appBar: AppBar(title: Text('Lacak ${o.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: st.isLate && !st.delivered ? C.danger : C.pri,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(head, style: const TextStyle(color: Colors.white70)),
                Text(
                  big,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: st.delivered ? 26 : 46,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  '${o.storeName} · ${o.address}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!st.delivered)
            Panel(
              color: C.tint,
              child: const Row(
                children: [
                  Icon(Icons.ac_unit, color: C.pri),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tetap beku: dikirim dalam tas pendingin, -18°C (contoh).',
                      style: tBold,
                    ),
                  ),
                ],
              ),
            ),
          if (st.guarantee) ...[
            const SizedBox(height: 12),
            Panel(
              color: C.warnBg,
              border: null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Garansi tepat waktu', style: tBold),
                  const SizedBox(height: 2),
                  Text(
                    'Pesanan terlambat lebih dari $lateGraceMinutes menit. Ongkir ${rp(o.pricing.delivery == 0 ? Pricing.baseFee : o.pricing.delivery)} dapat dikembalikan (aturan contoh).',
                    style: const TextStyle(color: C.warnInk),
                  ),
                  const SizedBox(height: 10),
                  BigButton(
                    o.reported ? 'Klaim sudah dikirim' : 'Klaim garansi',
                    onPressed: o.reported
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReportScreen(o, preset: 'Pesanan terlambat'),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Panel(
            child: Column(
              children: [
                for (var i = 0; i < names.length; i++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < idx || (i == idx && st.delivered)
                                  ? C.pri
                                  : C.surface,
                              border: Border.all(
                                color: i <= idx ? C.pri : C.line,
                                width: 2,
                              ),
                            ),
                            child: i < idx || (i == idx && st.delivered)
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (i < names.length - 1)
                            Container(
                              width: 2,
                              height: 30,
                              color: i < idx ? C.pri : C.line,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(names[i], style: tBold),
                              Text(
                                i < idx || (i == idx && st.delivered)
                                    ? 'Selesai'
                                    : i == idx
                                    ? 'Sedang berlangsung'
                                    : 'Menunggu',
                                style: tMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ringkasan', style: tH3),
                const SizedBox(height: 6),
                for (final l in o.lines)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text('${l.qty} x ${l.name}')),
                        Text(rp(l.qty * l.price)),
                      ],
                    ),
                  ),
                const Divider(),
                Row(
                  children: [
                    const Expanded(child: Text('Total', style: tBold)),
                    Text(rp(o.pricing.total), style: tBold),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: Text(footerText, style: tMuted)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: st.delivered
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BigButton(
                      o.reported ? 'Laporan sudah dikirim' : 'Laporkan masalah',
                      secondary: true,
                      onPressed: o.reported
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReportScreen(o),
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    BigButton(
                      'Selesai',
                      onPressed: () {
                        tabIndex.value = 0;
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                    ),
                  ],
                )
              : const Text(
                  'Tombol "Laporkan masalah" muncul setelah pesanan tiba.',
                  textAlign: TextAlign.center,
                  style: tMuted,
                ),
        ),
      ),
    );
  }
}

class ReportScreen extends StatefulWidget {
  final Order o;
  final String? preset;
  const ReportScreen(this.o, {super.key, this.preset});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const issues = [
    'Es krim meleleh',
    'Barang salah',
    'Kemasan rusak',
    'Pesanan terlambat',
  ];
  late String issue = widget.preset ?? issues.first;
  bool photo = false;
  String want = 'Ganti baru';
  final note = TextEditingController();
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Laporkan masalah')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pesanan ${widget.o.id} (contoh). Lapor dalam 24 jam.',
            style: tMuted,
          ),
          const SizedBox(height: 12),
          for (final i in issues)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OptionTile(
                selected: issue == i,
                title: i,
                onTap: () => setState(() => issue = i),
              ),
            ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: () => setState(() => photo = !photo),
            icon: Icon(photo ? Icons.check_circle : Icons.add_a_photo_outlined),
            label: Text(
              photo ? 'Foto ditambahkan (contoh)' : 'Tambah foto (contoh)',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: photo ? C.good : C.ink,
            ),
          ),
          const SizedBox(height: 14),
          const Text('Yang kamu mau', style: tH3),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final w in ['Ganti baru', 'Kembalikan dana'])
                SmallChip(
                  w,
                  on: want == w,
                  onTap: () => setState(() => want = w),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: note,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: tr('Ceritakan singkat (opsional)'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Demo: tidak ada pengembalian dana sungguhan.',
            style: tMuted,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: BigButton(
            'Kirim laporan',
            onPressed: () {
              s.markReported(widget.o);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ReportDone(issue: issue, want: want),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ReportDone extends StatelessWidget {
  final String issue;
  final String want;
  const ReportDone({super.key, required this.issue, required this.want});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: C.good,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 52, color: Colors.white),
            ),
            const SizedBox(height: 18),
            const Text('Laporan terkirim', style: tH2),
            const SizedBox(height: 8),
            Text('$issue. Permintaan: $want.', textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text(
              'Ini demo. Tidak ada penggantian atau pengembalian dana sungguhan.',
              textAlign: TextAlign.center,
              style: tMuted,
            ),
            const Spacer(),
            BigButton(
              'Kembali ke beranda',
              onPressed: () {
                tabIndex.value = 0;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Pesanan', style: tH2),
          const Text(
            'Status diperbarui setelah penjual mengonfirmasi transfer.',
            style: tMuted,
          ),
          const SizedBox(height: 12),
          for (final o in s.history)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: C.surface,
                borderRadius: BorderRadius.circular(rCard),
                child: InkWell(
                  borderRadius: BorderRadius.circular(rCard),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => OrderDetailScreen(o)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(rCard),
                      border: Border.all(color: C.line),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.id, style: tBold),
                              Text(
                                '${o.lines.fold(0, (a, l) => a + l.qty)} item · ${o.storeName}',
                                style: tMuted,
                              ),
                              Text(
                                o.sample
                                    ? '20 Nov 2026, ${_hm(o.placedAt)} (contoh)'
                                    : 'Baru saja',
                                style: tMuted,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              rp(o.pricing.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Ribbon(
                              statusLabel(o),
                              color: o.waiting ? C.warnBg : null,
                              ink: o.waiting ? C.warnInk : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Center(child: Text(footerText, style: tMuted)),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Profil', style: tH2),
          const SizedBox(height: 12),
          _ProfileHeader(s),
          if (s.signedIn) ...[
            const SizedBox(height: 12),
            const MemberCardTile(),
          ],
          const SizedBox(height: 16),
          _Group('Akun', [
            if (s.signedIn)
              _NavRow(
                key: const ValueKey('row-member'),
                icon: Icons.workspace_premium_outlined,
                title: 'Kartu Member',
                value: '${pts(s.balance)} Poin',
                onTap: () => openMember(context),
              ),
            _NavRow(
              icon: Icons.receipt_long_outlined,
              title: 'Pesanan',
              onTap: () => tabIndex.value = 2,
            ),
          ]),
          _Group(
            'Alamat tersimpan',
            [
              for (final a in s.saved)
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: OptionTile(
                          selected: s.address == a,
                          title: a,
                          onTap: () => s.setAddress(a),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: tr('Hapus alamat'),
                      onPressed: () => s.removeAddress(a),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
            ],
            action: TextButton(
              onPressed: () => _addAddress(context, s),
              child: const Text('Tambah'),
            ),
          ),
          _Group('Cara bayar', [const PaymentRow(boxed: false)]),
          _Group('Bahasa', [
            _kv('Bahasa', const LangChips()),
            _kv('Zona waktu', const Text('Asia/Jakarta (UTC+7)', style: tBold)),
          ]),
          _Group('Notifikasi', [
            _NavRow(
              icon: Icons.notifications_none,
              title: 'Notifikasi',
              badge: s.unreadCount,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const NoticesScreen())),
            ),
          ]),
          _Group('Bantuan', [
            _NavRow(
              key: const ValueKey('contact-sales-tile'),
              icon: Icons.chat_outlined,
              title: 'Hubungi penjual (WhatsApp)',
              external: true,
              onTap: () => contactSalesperson(context),
            ),
            _NavRow(
              icon: Icons.auto_awesome,
              title: 'Tanya AI',
              onTap: () => openAssistant(context),
            ),
          ]),
          _Group('Tentang demo ini', [
            _NavRow(
              icon: Icons.info_outline,
              title: 'Tentang demo ini',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutDemoScreen()),
              ),
            ),
            _NavRow(
              key: const ValueKey('switch-admin'),
              icon: Icons.admin_panel_settings_outlined,
              title: 'Demo: buka tampilan Admin',
              onTap: () => s.setRole(AppRole.admin),
            ),
          ]),
          if (s.signedIn)
            BigButton(
              'Keluar',
              secondary: true,
              onPressed: () async {
                if (await confirmAction(
                  context,
                  title: 'Keluar dari akun?',
                  body:
                      'Keranjangmu tetap ada. Kamu bisa masuk lagi kapan saja (contoh).',
                  yes: 'Keluar',
                )) {
                  s.signOut();
                }
              },
            ),
          const SizedBox(height: 12),
          const Center(child: Text(footerText, style: tMuted)),
        ],
      ),
    );
  }
}

/// Avatar, name, tier badge and points. Tap opens the Member card.
class _ProfileHeader extends StatelessWidget {
  final AppState s;
  const _ProfileHeader(this.s);
  @override
  Widget build(BuildContext context) {
    final name = s.signedIn ? s.customer.name : 'Tamu (contoh)';
    final t = s.tier;
    return Container(
      key: const ValueKey('profile-header'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [C.pri, C.priDark]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: s.signedIn
                    ? Text(
                        name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: C.pri,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : const Icon(Icons.person, color: C.pri),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      s.signedIn
                          ? s.customer.phone
                          : 'Masuk untuk melihat harga spesial & pesananmu.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (s.signedIn)
            InkWell(
              key: const ValueKey('profile-points'),
              borderRadius: BorderRadius.circular(12),
              onTap: () => openMember(context),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      tierName(t),
                      style: TextStyle(
                        color: tierColor(t),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${pts(s.balance)} Poin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            )
          else
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: C.priDark,
              ),
              onPressed: () => showSignIn(context),
              child: const Text('Masuk / Daftar'),
            ),
        ],
      ),
    );
  }
}

/// A titled card with rows inside.
class _Group extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? action;
  const _Group(this.title, this.children, {this.action});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Expanded(child: Text(title, style: tH3)),
              if (action != null) action!,
            ],
          ),
        ),
        Panel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final int badge;
  final bool external;
  final VoidCallback onTap;
  const _NavRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.badge = 0,
    this.external = false,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Badge(
            isLabelVisible: badge > 0,
            smallSize: 9,
            child: Icon(icon, color: C.pri),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: tBold)),
          if (value != null) ...[
            Flexible(child: Text(value!, style: tMuted)),
            const SizedBox(width: 4),
          ],
          Icon(
            external ? Icons.open_in_new : Icons.chevron_right,
            size: external ? 18 : 24,
            color: C.muted,
          ),
        ],
      ),
    ),
  );
}

Widget _kv(String k, Widget v) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    children: [
      Expanded(child: Text(k, style: tMuted)),
      Flexible(child: v),
    ],
  ),
);

/// Hidden panel for the person running the demo. Opened by a long press on the
/// wordmark on Home.
void showDemoControls(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return Builder(
        builder: (ctx) {
          final s = AppScope.of(ctx);
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kontrol demo', style: tH2),
                const SizedBox(height: 14),
                const Text('Kecepatan pelacakan', style: tBold),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final v in [45, 75, 120])
                      SmallChip(
                        '$v detik',
                        on: s.demoSeconds == v,
                        onTap: () => s.setSpeed(v),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Buat pesanan ini terlambat'),
                  subtitle: const Text('Untuk menunjukkan garansi tepat waktu'),
                  value: s.makeLate,
                  onChanged: s.setMakeLate,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sumber data'),
                  trailing: Text(
                    s.dataLocal ? 'Lokal' : 'Supabase',
                    style: tBold,
                  ),
                ),
                const SizedBox(height: 8),
                BigButton(
                  'Reset demo',
                  secondary: true,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    tabIndex.value = 0;
                    s.resetDemo();
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _addAddress(BuildContext context, AppState s) async {
  final text = await showDialog<String>(
    context: context,
    builder: (_) => const _AddAddressDialog(),
  );
  if (text != null) s.addAddress(text);
}

class _AddAddressDialog extends StatefulWidget {
  const _AddAddressDialog();
  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final ctl = TextEditingController();
  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Tambah alamat'),
    content: TextField(
      controller: ctl,
      autofocus: true,
      decoration: InputDecoration(hintText: tr('Tulis alamat')),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Batal'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(ctl.text),
        child: const Text('Simpan'),
      ),
    ],
  );
}
