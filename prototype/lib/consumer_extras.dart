import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'accounts.dart';
import 'data.dart';
import 'format.dart';
import 'i18n.dart';
import 'pricing.dart';
import 'screens_a.dart';
import 'state.dart';
import 'ui.dart';

/// Extra product facts shown on the product page: stock, cold chain, carton
/// price, quantity tiers, near expiry and the member price hint. All numbers
/// come from lib/pricing.dart and lib/stock.dart (sample data).
class ProductInfo extends StatelessWidget {
  final Product p;
  const ProductInfo(this.p, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final si = s.stock[p.id];
    final tier = tierText(p);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 6, children: [
        if (si != null)
          _Tag(si.stock == 0 ? 'Stok habis' : 'Stok ${si.stock}',
              color: si.low ? C.warnBg : C.tint,
              ink: si.low ? C.warnInk : C.pri),
        _Tag(p.chilled ? 'Rantai dingin 2-6°C' : 'Rantai beku -18°C',
            color: C.tint, ink: C.pri),
        if (si?.nearExpiry ?? false)
          const _Tag('Segera kedaluwarsa', color: C.warnBg, ink: C.warnInk),
        if (p.shelfLifeDays != null)
          _Tag('Tahan ${p.shelfLifeDays} hari (contoh)',
              color: C.tint, ink: C.pri),
      ]),
      const SizedBox(height: 8),
      Text(
          'Harga 1 karton ${cartonUnits[p.category] ?? 1} pcs: ${rp(cartonPrice(p))}',
          style: tMuted),
      if (tier != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Diskon jumlah: $tier',
              style: const TextStyle(color: Color(0xFF8A5A00), fontSize: 13)),
        ),
      const SizedBox(height: 8),
      if (s.customer.vip)
        const _Tag('Harga member aktif: -$vipPercent%',
            color: Color(0xFFDFF6E7), ink: C.good)
      else
        InkWell(
          key: const ValueKey('member-hint'),
          onTap: () => showSignIn(context),
          child: const _Tag('Masuk untuk harga member (lebih murah!)',
              color: C.tint, ink: C.pri),
        ),
    ]);
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final Color ink;
  const _Tag(this.text, {required this.color, required this.ink});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
        child: Text(text,
            style: TextStyle(
                color: ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
      );
}

/// Guest banner at the top of Home: look around first, sign in later.
class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});
  @override
  Widget build(BuildContext context) => Panel(
        color: C.tint,
        border: const Color(0xFFB9D3F7),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              'Selamat datang! Lihat-lihat produk dulu, tanpa masuk. Saat checkout kamu bisa masuk cepat, daftar, atau pakai kode undangan (semua contoh).',
              style: TextStyle(color: C.priDark, height: 1.35)),
          const SizedBox(height: 6),
          TextButton(
            key: const ValueKey('welcome-signin'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => showSignIn(context),
            child: const Text('Masuk / Daftar (contoh)'),
          ),
        ]),
      );
}

/// Products to suggest: what this person ordered before first, then the most
/// popular ones. Sold-out products are left out.
List<Product> recommendedFor(AppState s) {
  final seen = <String>{};
  final out = <Product>[];
  for (final o in s.history) {
    for (final l in o.lines) {
      final id = l.productId;
      if (id == null || !seen.add(id)) continue;
      final p = catalog.where((x) => x.id == id).firstOrNull;
      if (p != null && !p.soldOut) out.add(p);
    }
  }
  final pop = [...catalog]..sort((a, b) => a.rank.compareTo(b.rank));
  for (final p in pop) {
    if (out.length >= 6) break;
    if (!p.soldOut && seen.add(p.id)) out.add(p);
  }
  return out.take(6).toList();
}

/// Promo bundles as a list: percent off, crossed-out price, "Hemat Rp".
class PromoDeals extends StatelessWidget {
  final List<Product> bundles;
  const PromoDeals(this.bundles, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Promo & Paket Hemat', style: tH3),
      const SizedBox(height: 8),
      for (final p in bundles.where((b) => b.oldPrice != null && !b.soldOut))
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(rCard),
              border: Border.all(color: const Color(0xFFF2DD8C))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(p.name, style: tBold),
              Ribbon('-${p.percentOff}%'),
            ]),
            Text(p.size, style: tMuted),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(rp(p.price),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: C.priDark)),
              Text(rp(p.oldPrice!),
                  style: const TextStyle(
                      color: C.muted, decoration: TextDecoration.lineThrough)),
              Text('Hemat ${rp(p.oldPrice! - p.price)}',
                  style: const TextStyle(
                      color: Color(0xFF8A5A00), fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                s.add(p);
                addedToCart(context, '${p.name} ditambahkan');
              },
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Tambah Paket'),
            ),
          ]),
        ),
    ]);
  }
}

// ------------------------------------------------------------- Language

/// Three small chips to pick the language (ID, EN, 中文).
class LangChips extends StatelessWidget {
  const LangChips({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Wrap(spacing: 6, children: [
      for (final e in const {'id': 'ID', 'en': 'EN', 'zh': '中文'}.entries)
        SmallChip(e.value,
            key: ValueKey('lang-${e.key}'),
            on: s.lang == e.key,
            onTap: () => s.setLang(e.key)),
    ]);
  }
}

// -------------------------------------------------------------- Sign in

/// Opens the demo sign-in sheet. Returns true when someone signed in.
Future<bool> showSignIn(BuildContext context, {int tab = 0}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SignInSheet(initialTab: tab),
  );
  return ok ?? false;
}

class SignInSheet extends StatefulWidget {
  final int initialTab;
  const SignInSheet({super.key, this.initialTab = 0});
  @override
  State<SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends State<SignInSheet> {
  late int tab = widget.initialTab; // 0 sign in, 1 OTP, 2 register
  final phone = TextEditingController();
  final password = TextEditingController();
  final otp = TextEditingController();
  final name = TextEditingController();
  final address = TextEditingController();
  final invite = TextEditingController();
  bool otpSent = false;
  String? error;

  @override
  void dispose() {
    for (final c in [phone, password, otp, name, address, invite]) {
      c.dispose();
    }
    super.dispose();
  }

  void fill(Customer c) => setState(() {
        phone.text = c.phone;
        error = null;
      });

  void done(AppState s, Customer c) {
    s.signIn(c);
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Masuk sebagai ${c.name} (contoh)')));
  }

  void submitSignIn(AppState s) {
    final c = s.findByPhone(phone.text);
    if (c == null) {
      setState(() => error = 'Nomor tidak ditemukan. Pilih akun contoh di bawah atau daftar.');
      return;
    }
    done(s, c); // the password is never checked (demo)
  }

  void sendOtp() {
    if (digitsOnly(phone.text).length < 6) {
      setState(() => error = 'Isi nomor WhatsApp dulu.');
      return;
    }
    setState(() {
      otpSent = true;
      error = null;
    });
  }

  void submitOtp(AppState s) {
    if (digitsOnly(otp.text).length < demoOtpLength) {
      setState(() => error = 'Isi kode $demoOtpLength angka (kode apa saja bisa).');
      return;
    }
    done(s, s.findByPhone(phone.text) ?? s.register('', phone.text, ''));
  }

  void submitRegister(AppState s) {
    if (name.text.trim().isEmpty || digitsOnly(phone.text).length < 6) {
      setState(() => error = 'Isi nama dan nomor WhatsApp.');
      return;
    }
    final c = s.register(name.text, phone.text, invite.text);
    if (address.text.trim().isNotEmpty) s.addAddress(address.text);
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(c.vip
            ? 'Akun contoh dibuat. Kode undangan benar: harga member aktif.'
            : 'Akun contoh dibuat.')));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Masuk / Daftar', style: tH2),
          const SizedBox(height: 6),
          const Notice(
              'Hanya demo: tidak ada kata sandi atau kode asli yang dicek. Semua akun adalah contoh.'),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            for (final e in const ['Masuk', 'OTP WhatsApp', 'Daftar'].asMap().entries)
              SmallChip(e.value,
                  key: ValueKey('signin-tab-${e.key}'),
                  on: tab == e.key,
                  onTap: () => setState(() {
                        tab = e.key;
                        error = null;
                      })),
          ]),
          const SizedBox(height: 12),
          if (tab == 0) ...[
            const Text('Pelanggan lama', style: tMuted),
            _field('Nomor telepon / WhatsApp', phone, 'sheet-phone',
                keyboard: TextInputType.phone),
            _field('Kata sandi (opsional)', password, 'sheet-password',
                obscure: true),
            const SizedBox(height: 10),
            BigButton('Masuk', onPressed: () => submitSignIn(s)),
          ],
          if (tab == 1) ...[
            const Text('Masuk dengan kode OTP WhatsApp (contoh)', style: tMuted),
            _field('Nomor telepon / WhatsApp', phone, 'sheet-phone',
                keyboard: TextInputType.phone),
            if (otpSent) ...[
              const Notice('Kode contoh terkirim. Tidak ada pesan asli. Isi kode apa saja.',
                  good: true),
              _field('Kode OTP', otp, 'sheet-otp', keyboard: TextInputType.number),
            ],
            const SizedBox(height: 10),
            BigButton(otpSent ? 'Masuk' : 'Kirim kode',
                onPressed: otpSent ? () => submitOtp(s) : sendOtp),
          ],
          if (tab == 2) ...[
            const Text('Daftar sendiri', style: tMuted),
            _field('Nama / nama toko', name, 'sheet-name'),
            _field('Nomor telepon / WhatsApp', phone, 'sheet-phone',
                keyboard: TextInputType.phone),
            _field('Alamat (opsional)', address, 'sheet-address'),
            _field('Kode undangan (opsional)', invite, 'sheet-invite'),
            Text('Contoh: $inviteCodeVip', style: tMuted),
            const SizedBox(height: 10),
            BigButton('Daftar sekarang', onPressed: () => submitRegister(s)),
          ],
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error!, style: const TextStyle(color: C.danger)),
            ),
          const SizedBox(height: 14),
          const Text('Akun contoh (ketuk untuk mengisi):', style: tMuted),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in demoAccounts)
              ActionChip(
                key: ValueKey('demo-${c.id}'),
                label: Text('${c.name} · ${c.phone}${c.vip ? ' · VIP' : ''}'),
                onPressed: () => fill(c),
              ),
          ]),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const ValueKey('contact-sales'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => contactSalesperson(context),
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: const Text('Hubungi penjual (WhatsApp)'),
          ),
          OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tutup')),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String key,
          {TextInputType? keyboard, bool obscure = false}) =>
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: TextField(
          key: ValueKey(key),
          controller: c,
          keyboardType: keyboard,
          obscureText: obscure,
          decoration: InputDecoration(labelText: tr(label)),
        ),
      );
}

/// Opens the salesperson chat link. Only a link: the app sends nothing. If the
/// link cannot open, it is copied instead.
Future<void> contactSalesperson(BuildContext context) async {
  final msg = ScaffoldMessenger.of(context);
  var opened = false;
  try {
    opened = await launchUrl(Uri.parse(salespersonWhatsApp),
        mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!opened) {
    await Clipboard.setData(const ClipboardData(text: salespersonWhatsApp));
    msg.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Tautan penjual disalin (contoh).')));
  }
}

String statusLabel(Order o) {
  if (o.sample) return 'Selesai';
  switch (o.status) {
    case OrderStatus.pendingPayment:
      return 'Menunggu pembayaran';
    case OrderStatus.pendingPrep:
      return 'Menunggu disiapkan';
    case OrderStatus.shipping:
      return 'Lacak';
    case OrderStatus.delivered:
      return 'Selesai';
  }
}

/// Shown instead of live tracking while the order waits for the admin:
/// first the transfer confirmation, then the preparation.
class OrderWaitingView extends StatelessWidget {
  final Order o;
  const OrderWaitingView(this.o, {super.key});
  @override
  Widget build(BuildContext context) {
    final payWait = o.status == OrderStatus.pendingPayment;
    Widget step(String text, bool done, bool now) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? C.good : (now ? C.pri : C.line)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(text,
                    style: now ? tBold : const TextStyle(color: C.muted))),
          ]),
        );
    return Scaffold(
      appBar: AppBar(title: Text(o.id)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(payWait ? 'Menunggu pembayaran' : 'Menunggu disiapkan',
                style: tH3),
            const SizedBox(height: 6),
            step('Pesanan diterima', true, false),
            step('Transfer dikonfirmasi penjual', !payWait, payWait),
            step('Pesanan disiapkan', false, !payWait),
            step('Dalam perjalanan', false, false),
          ]),
        ),
        const SizedBox(height: 12),
        if (payWait)
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Transfer ${rp(o.pricing.total)} ke:', style: tMuted),
              const Text(sampleBankAccount, style: tBold),
              const SizedBox(height: 4),
              const Text(
                  'Status berubah setelah penjual mengonfirmasi transfer. Di demo ini penjual mengonfirmasi lewat tampilan Admin.',
                  style: tMuted),
            ]),
          ),
        const SizedBox(height: 12),
        BigButton('Hubungi penjual (WhatsApp)',
            secondary: true, onPressed: () => contactSalesperson(context)),
        const SizedBox(height: 12),
        const Center(child: Text(footerText, style: tMuted)),
      ]),
    );
  }
}
