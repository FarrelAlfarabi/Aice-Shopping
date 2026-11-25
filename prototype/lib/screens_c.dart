import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'data.dart';
import 'format.dart';
import 'motion.dart';
import 'pricing.dart';
import 'screens_a.dart';
import 'screens_b.dart';
import 'state.dart';
import 'ui.dart';

/// Cones and sticks that can go in a mix pack.
List<Product> get mixChoices => catalog
    .where((p) => (p.category == 'cone' || p.category == 'stick') && !p.soldOut)
    .toList();

/// What the same items cost one by one (to show the saving).
int mixSeparatePrice(Map<Product, int> picks) =>
    picks.entries.fold(0, (a, e) => a + e.key.price * e.value);

// ---------------------------------------------------------------- Mix pack

/// Pick any 6, 8 or 12 flavours for one set price.
class MixPackScreen extends StatefulWidget {
  const MixPackScreen({super.key});
  @override
  State<MixPackScreen> createState() => _MixPackScreenState();
}

class _MixPackScreenState extends State<MixPackScreen> {
  int size = mixPackPrices.keys.first;
  final Map<Product, int> picks = {};

  int get count => picks.values.fold(0, (a, b) => a + b);

  void _setSize(int v) => setState(() {
        size = v;
        // Keep picks, but drop the extra ones if the pack got smaller.
        var over = count - size;
        for (final p in picks.keys.toList().reversed) {
          if (over <= 0) break;
          final cut = over < picks[p]! ? over : picks[p]!;
          picks[p] = picks[p]! - cut;
          over -= cut;
        }
        picks.removeWhere((_, v) => v <= 0);
      });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final price = mixPackPrices[size]!;
    final full = count == size;
    final saving = mixSeparatePrice(picks) - price;
    return Scaffold(
      appBar: AppBar(title: const Text('Paket Mix Sendiri')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Pilih isi paket', style: tH3),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in mixPackPrices.entries)
              SmallChip('Isi ${e.key} · ${rp(e.value)}',
                  on: size == e.key, onTap: () => _setSize(e.key)),
          ]),
          const SizedBox(height: 14),
          Panel(
            color: full ? const Color(0xFFE3F5EA) : C.tint,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  full
                      ? 'Paket penuh. Siap masuk keranjang.'
                      : 'Pilih ${size - count} lagi ($count dari $size)',
                  key: const Key('mix-status'),
                  style: tBold),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: count / size,
                  minHeight: 6,
                  backgroundColor: C.surface,
                  color: full ? C.good : C.pri,
                ),
              ),
              if (saving > 0) ...[
                const SizedBox(height: 8),
                Text('Hemat ${rp(saving)} dibanding beli satuan (contoh)',
                    style: tMuted),
              ],
            ]),
          ),
          const SizedBox(height: 14),
          for (final p in mixChoices)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Panel(
                child: Row(children: [
                  SizedBox(width: 48, child: ProductImage(p)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: tBold),
                          Text('${p.size} · ${rp(p.price)}', style: tMuted),
                        ]),
                  ),
                  QtyStepper(
                    qty: picks[p] ?? 0,
                    onMinus: () => setState(() {
                      final q = (picks[p] ?? 0) - 1;
                      if (q <= 0) {
                        picks.remove(p);
                      } else {
                        picks[p] = q;
                      }
                    }),
                    onPlus: () => setState(() {
                      if (count < size) picks[p] = (picks[p] ?? 0) + 1;
                    }),
                  ),
                ]),
              ),
            ),
          const SizedBox(height: 8),
          const Center(child: Text(footerText, style: tMuted)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: C.surface,
            border: Border(top: BorderSide(color: C.line)),
          ),
          child: BigButton(
            'Tambah ke keranjang',
            trailing: rp(price),
            onPressed: full
                ? () {
                    s.addMixPack(size, Map.of(picks));
                    Navigator.of(context).pop();
                    addedToCart(context, 'Paket Mix $size ditambahkan');
                  }
                : null,
          ),
        ),
      ),
    );
  }
}

/// Card on Home that opens the mix pack builder.
class MixPackCard extends StatelessWidget {
  const MixPackCard({super.key});
  @override
  Widget build(BuildContext context) {
    final from = mixPackPrices.entries.first;
    return Pressable(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const MixPackScreen())),
      scale: 0.98,
      semanticLabel: 'Susun paket mix sendiri',
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Color(0x140B1B33), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        child: Row(children: [
          SizedBox(
            width: 58,
            height: 58,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: const Photo('paket-cone.webp')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Susun Paket Mix sendiri',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                  'Pilih ${mixPackPrices.keys.join(', ')} rasa, harga paket mulai ${rp(from.value)} (contoh)',
                  style: tMuted),
            ]),
          ),
          const Icon(Icons.chevron_right, color: C.muted),
        ]),
      ),
    );
  }
}

// ------------------------------------------------------------ Order detail

class OrderDetailScreen extends StatelessWidget {
  final Order o;
  const OrderDetailScreen(this.o, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = o.pricing;
    return Scaffold(
      appBar: AppBar(title: Text(o.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Item', style: tH3),
              const SizedBox(height: 6),
              for (final l in o.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${l.qty} x ${l.name}'),
                                if (l.detail != null)
                                  Text(l.detail!, style: tMuted),
                              ]),
                        ),
                        Text(rp(l.qty * l.price)),
                      ]),
                ),
              const Divider(),
              _row('Subtotal', rp(p.subtotal)),
              if (p.multiBuy > 0) _row('Diskon Beli 3', '-${rp(p.multiBuy)}'),
              if (p.tier > 0) _row('Diskon jumlah', '-${rp(p.tier)}'),
              if (p.vip > 0) _row('Harga member', '-${rp(p.vip)}'),
              if (p.voucherDiscount > 0)
                _row('Voucher', '-${rp(p.voucherDiscount)}'),
              _row('Ongkir', p.delivery == 0 ? 'Gratis' : rp(p.delivery)),
              if (p.smallFee > 0) _row('Biaya belanja kecil', rp(p.smallFee)),
              const Divider(),
              Row(children: [
                const Expanded(child: Text('Total', style: tBold)),
                Text(rp(p.total), style: tBold),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pengiriman', style: tH3),
              const SizedBox(height: 6),
              Text(o.storeName, style: tBold),
              Text(o.address, style: tMuted),
              const SizedBox(height: 6),
              Text('Bayar: ${o.payment} (palsu, tidak ada uang bergerak)',
                  style: tMuted),
            ]),
          ),
          const SizedBox(height: 16),
          BigButton('Pesan lagi', onPressed: () {
            final skipped = s.reorder(o);
            Navigator.of(context).popUntil((r) => r.isFirst);
            tabIndex.value = 1;
            if (skipped > 0) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                      '$skipped item tidak bisa dipesan lagi (paket mix atau habis).')));
            }
          }),
          const SizedBox(height: 8),
          if (!o.sample)
            BigButton('Lacak pesanan',
                secondary: true,
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TrackingScreen(o)))),
          const SizedBox(height: 12),
          const Center(child: Text(footerText, style: tMuted)),
        ],
      ),
    );
  }

  Widget _row(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [Expanded(child: Text(a)), Text(b)]),
      );
}

// ----------------------------------------------------------- Notifications

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi'), actions: [
        TextButton(
            onPressed: s.unreadCount == 0 ? null : s.markAllRead,
            child: const Text('Tandai dibaca')),
      ]),
      body: s.notices.isEmpty
          ? const Center(child: Text('Belum ada notifikasi.', style: tMuted))
          : ListView(padding: const EdgeInsets.all(16), children: [
              for (final n in s.notices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Pressable(
                    onTap: () => s.markNoticeRead(n),
                    child: Panel(
                      color: n.read ? C.surface : C.tint,
                      child: Row(children: [
                        Icon(n.read ? Icons.notifications_none : Icons.notifications_active,
                            color: n.read ? C.muted : C.pri),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(n.text,
                                style: TextStyle(
                                    fontWeight:
                                        n.read ? FontWeight.w400 : FontWeight.w700))),
                      ]),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const Center(child: Text(footerText, style: tMuted)),
            ]),
    );
  }
}

// -------------------------------------------------------------- About demo

/// Plain list of what really works and what is sample.
const demoReal = <String>[
  'Hitungan keranjang: total, diskon Beli 3, voucher, ongkir.',
  'Pencarian, urutan, dan Tanya AI (jawaban tertulis, bukan AI sungguhan).',
  'Pelacakan pesanan dengan hitung mundur, termasuk garansi terlambat.',
];
const demoSample = <String>[
  'Semua produk, harga, foto, toko, dan alamat adalah contoh.',
  'Pembayaran palsu. Tidak ada uang yang bergerak.',
  'Tidak ada login. Keranjang dan pesanan hanya ada di perangkat ini.',
  'Laporan masalah tidak mengirim apa pun ke siapa pun.',
];

class AboutDemoScreen extends StatelessWidget {
  const AboutDemoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Widget block(String title, List<String> items, IconData icon, Color c) =>
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: tH3),
            const SizedBox(height: 6),
            for (final t in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(icon, size: 18, color: c),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t)),
                ]),
              ),
          ]),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang demo ini')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        block('Yang benar-benar jalan', demoReal, Icons.check_circle, C.good),
        const SizedBox(height: 12),
        block('Yang hanya contoh', demoSample, Icons.info_outline, C.muted),
        const SizedBox(height: 16),
        const Center(child: Text(footerText, style: tMuted)),
      ]),
    );
  }
}
