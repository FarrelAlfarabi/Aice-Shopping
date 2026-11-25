import 'package:flutter/material.dart' hide Text;
import 'accounts.dart';
import 'format.dart';
import 'i18n.dart';
import 'pricing.dart';
import 'state.dart';
import 'ui.dart';

/// "Cara bayar": the options come from paymentOptions in lib/pricing.dart.
/// The choice made here is also the default saved in Profil.

IconData payIcon(String id) => switch (payOption(id).flow) {
  PayFlow.bankTransfer => Icons.account_balance_outlined,
  PayFlow.cod => Icons.payments_outlined,
  PayFlow.instant =>
    id == 'QRIS' ? Icons.qr_code_2 : Icons.account_balance_wallet_outlined,
};

Future<void> showPaymentPicker(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => const _PaymentSheet(),
    );

class _PaymentSheet extends StatelessWidget {
  const _PaymentSheet();
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cara bayar', style: tH3),
            const SizedBox(height: 4),
            const Text(
              'Contoh saja. Tidak ada uang yang berpindah. Pilihan ini juga jadi cara bayar utama di Profil.',
              style: tMuted,
            ),
            const SizedBox(height: 10),
            for (final o in paymentOptions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OptionTile(
                  key: ValueKey('pay-${o.flow.name}-${o.id}'),
                  selected: s.payment == o.id,
                  title: o.id,
                  subtitle: o.note,
                  trailing: Icon(payIcon(o.id), color: C.muted),
                  onTap: () {
                    s.setPayment(o.id);
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A row that shows the chosen option and opens the picker.
class PaymentRow extends StatelessWidget {
  final bool boxed;
  const PaymentRow({super.key, this.boxed = true});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final row = InkWell(
      key: const ValueKey('payment-row'),
      borderRadius: BorderRadius.circular(14),
      onTap: () => showPaymentPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(payIcon(s.payment), color: C.pri),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cara bayar', style: tMuted),
                  Text(s.payment, style: tBold),
                ],
              ),
            ),
            const Text(
              'Ubah',
              style: TextStyle(color: C.pri, fontWeight: FontWeight.w800),
            ),
            const Icon(Icons.chevron_right, color: C.muted),
          ],
        ),
      ),
    );
    return boxed ? Panel(child: row) : row;
  }
}

/// What to do next for the chosen option, shown on the order screens.
class PayInstructions extends StatelessWidget {
  final Order o;
  const PayInstructions(this.o, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    switch (o.flow) {
      case PayFlow.bankTransfer:
        if (o.status != OrderStatus.pendingPayment) {
          return const SizedBox.shrink();
        }
        return Panel(
          key: const ValueKey('pay-instructions'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transfer ${rp(o.pricing.total)} ke:', style: tMuted),
              const Text(sampleBankAccount, style: tBold),
              const SizedBox(height: 4),
              const Text(
                'Di demo ini penjual mengonfirmasi lewat tampilan Admin. Tidak ada uang yang berpindah.',
                style: tMuted,
              ),
              const SizedBox(height: 10),
              if (o.transferClaimed)
                const Text(
                  'Terima kasih. Menunggu penjual mengonfirmasi.',
                  key: ValueKey('transfer-claimed'),
                  style: TextStyle(color: C.good, fontWeight: FontWeight.w800),
                )
              else
                BigButton(
                  'Saya sudah transfer',
                  secondary: true,
                  onPressed: () => s.claimTransfer(o),
                ),
            ],
          ),
        );
      case PayFlow.cod:
        return Panel(
          key: const ValueKey('pay-instructions'),
          child: Text(
            o.isPaid
                ? 'Sudah dibayar ke kurir (contoh).'
                : 'Bayar ${rp(o.pricing.total)} ke kurir saat pesanan tiba. Poin ditambahkan setelah pesanan selesai (contoh).',
            style: tBold,
          ),
        );
      case PayFlow.instant:
        if (o.payment != 'QRIS' || o.status == OrderStatus.delivered) {
          return const SizedBox.shrink();
        }
        return const Panel(
          key: ValueKey('qris-sample'),
          child: Column(
            children: [
              SampleQr(),
              SizedBox(height: 6),
              Text(
                'Kode QR contoh, bukan kode asli. Tidak ada uang yang berpindah.',
                style: tMuted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }
}

/// A made-up pattern that looks like a QR code. It cannot be scanned.
class SampleQr extends StatelessWidget {
  const SampleQr({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 140,
    height: 140,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: C.line),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const CustomPaint(painter: _QrPainter()),
  );
}

class _QrPainter extends CustomPainter {
  const _QrPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const n = 21;
    final cell = size.width / n;
    final p = Paint()..color = const Color(0xFF222222);
    bool finder(int x, int y) =>
        (x < 7 && y < 7) || (x >= n - 7 && y < 7) || (x < 7 && y >= n - 7);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        if ((x * 7 + y * 13 + x * y) % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
        }
      }
    }
    void eye(int ox, int oy) {
      final w = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell),
        p,
      );
      canvas.drawRect(
        Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell),
        w,
      );
      canvas.drawRect(
        Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell),
        p,
      );
    }

    eye(0, 0);
    eye(n - 7, 0);
    eye(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
