import 'package:flutter/material.dart';
import 'data.dart';
import 'format.dart';
import 'pricing.dart';
import 'screens_a.dart';
import 'state.dart';
import 'ui.dart';

/// "Tanya AI": a scripted helper for the demo. There is no AI model behind
/// it. Each question is matched by keywords to a fixed answer below, so the
/// answers are predictable in a meeting. All answers are sample answers.

class Reply {
  final String text;
  final List<String> productIds;
  const Reply(this.text, [this.productIds = const []]);
}

class _Rule {
  final List<String> words;
  final Reply Function() reply;
  const _Rule(this.words, this.reply);
}

/// Questions shown as tap-to-ask chips.
const suggestedQuestions = <String>[
  'Es krim buat pesta 10 orang?',
  'Yang paling laris apa?',
  'Ada promo apa hari ini?',
  'Apakah sampai tetap beku?',
  'Kalau es krim meleleh?',
  'Rekomendasi rasa cokelat',
  'Yang segar dan tidak terlalu manis?',
  'Ongkirnya berapa?',
];

List<String> _top(Iterable<Product> ps, int n) {
  final l = ps.where((p) => !p.soldOut).toList()
    ..sort((a, b) => a.rank.compareTo(b.rank));
  return [for (final p in l.take(n)) p.id];
}

final _rules = <_Rule>[
  _Rule(
    [
      'pesta',
      'ulang tahun',
      'acara',
      'rame',
      'ramai',
      'orang',
      'keluarga',
      'banyak',
    ],
    () => Reply(
      'Untuk acara ramai, paket lebih hemat. Paket Pesta isi 12 stik cocok untuk sekitar 10 orang, '
      'ditambah satu tub untuk yang mau tambah (contoh).',
      _top(
        catalog.where((p) => p.category == 'bundle' || p.category == 'tub'),
        3,
      ),
    ),
  ),
  _Rule(
    ['laris', 'populer', 'favorit', 'best', 'terlaris', 'rekomendasi'],
    () => Reply(
      'Ini yang paling sering dibeli minggu ini (data contoh).',
      _top(catalog, 3),
    ),
  ),
  _Rule(
    ['promo', 'diskon', 'voucher', 'hemat', 'murah', 'kode'],
    () => Reply(
      'Promo contoh hari ini:\n'
      '• Beli 3 cone apa saja, diskon ${Pricing.multiBuyPercent}%.\n'
      '• ${vouchers.map((v) => '${v.code}: ${v.description}').join('\n• ')}',
      _top(catalog.where((p) => p.oldPrice != null), 3),
    ),
  ),
  _Rule(
    ['beku', 'cair', 'dingin', 'pendingin', 'suhu', 'aman sampai'],
    () => const Reply(
      'Pesanan dikirim dalam tas pendingin -18°C dan diantar dari toko terdekat, '
      'jadi perjalanannya singkat (contoh).',
    ),
  ),
  _Rule(
    ['meleleh', 'rusak', 'salah', 'komplain', 'lapor', 'refund', 'ganti'],
    () => const Reply(
      'Kalau es krim meleleh saat tiba, buka pesanan lalu tekan "Laporkan masalah" dalam 24 jam. '
      'Pilih ganti baru atau pengembalian dana (aturan contoh).',
    ),
  ),
  _Rule(
    ['cokelat', 'coklat', 'choco', 'mocha'],
    () => Reply(
      'Pilihan rasa cokelat (contoh):',
      _top(
        catalog.where(
          (p) =>
              p.name.toLowerCase().contains('cokelat') ||
              p.name.toLowerCase().contains('mocha'),
        ),
        3,
      ),
    ),
  ),
  _Rule(
    [
      'segar',
      'tidak terlalu manis',
      'ringan',
      'asam',
      'buah',
      'yoghurt',
      'yogurt',
    ],
    () => Reply(
      'Yang segar dan ringan: yoghurt dan rasa buah (contoh).',
      _top(
        catalog.where(
          (p) =>
              p.category == 'cup' ||
              p.name.contains('Mangga') ||
              p.name.contains('Mint'),
        ),
        3,
      ),
    ),
  ),
  _Rule(
    ['ongkir', 'ongkos', 'kirim', 'biaya', 'gratis'],
    () => Reply(
      'Ongkir contoh ${rp(Pricing.baseFee)}. Gratis ongkir kalau belanja minimal ${rp(Pricing.freeThreshold)}. '
      'Minimal belanja ${rp(Pricing.minOrder)}.',
    ),
  ),
  _Rule(
    ['matcha', 'teh', 'green tea'],
    () => Reply(
      'Pilihan matcha (contoh):',
      _top(catalog.where((p) => p.name.contains('Matcha')), 3),
    ),
  ),
  _Rule(
    ['anak', 'kecil', 'bocah'],
    () => Reply(
      'Ukuran kecil dan rasa lembut biasanya pas untuk anak (contoh).',
      _top(
        catalog.where((p) => p.category == 'cone' || p.category == 'stick'),
        3,
      ),
    ),
  ),
  _Rule(
    ['berapa lama', 'lama', 'kapan sampai', 'cepat', 'menit'],
    () => const Reply(
      'Di demo ini perkiraan tiba 15 menit dari toko terdekat. Waktu ini contoh, bukan janji Aice.',
    ),
  ),
];

Reply answer(String question) {
  final q = question.toLowerCase();
  for (final r in _rules) {
    if (r.words.any(q.contains)) return r.reply();
  }
  return Reply(
    'Maaf, untuk demo ini aku baru bisa menjawab soal produk, promo, ongkir, dan pengiriman. '
    'Coba salah satu pertanyaan di bawah, atau cari "$question" di pencarian.',
    const [],
  );
}

void openAssistant(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute(builder: (_) => const AssistantScreen()));

class _Msg {
  final bool me;
  final Reply reply;
  const _Msg(this.me, this.reply);
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final msgs = <_Msg>[
    const _Msg(
      false,
      Reply(
        'Hai! Aku Tanya AI (contoh). Mau cari es krim untuk apa hari ini? '
        'Pilih pertanyaan di bawah atau ketik sendiri.',
      ),
    ),
  ];
  bool typing = false;

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> ask(String q) async {
    q = q.trim();
    if (q.isEmpty || typing) return;
    input.clear();
    setState(() {
      msgs.add(_Msg(true, Reply(q)));
      typing = true;
    });
    _toEnd();
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      msgs.add(_Msg(false, answer(q)));
      typing = false;
    });
    _toEnd();
  }

  void _toEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (scroll.hasClients) {
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: C.pri, size: 20),
            SizedBox(width: 6),
            Text('Tanya AI'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFFFF4D6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: const Text(
              'Jawaban contoh untuk demo, bukan jawaban dari Aice.',
              style: TextStyle(fontSize: 12, color: C.accInk),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              children: [
                for (final m in msgs) _Bubble(m),
                if (typing)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text('Mengetik...', style: tMuted),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: suggestedQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Center(
                child: SmallChip(
                  suggestedQuestions[i],
                  on: false,
                  onTap: () => ask(suggestedQuestions[i]),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('assistant-input'),
                      controller: input,
                      textInputAction: TextInputAction.send,
                      onSubmitted: ask,
                      decoration: const InputDecoration(
                        hintText: 'Tulis pertanyaan...',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kirim',
                    onPressed: () => ask(input.text),
                    icon: const Icon(Icons.send_rounded, color: C.pri),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Msg m;
  const _Bubble(this.m);
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final products = [for (final id in m.reply.productIds) productById(id)];
    return Align(
      alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width.clamp(0, 430) * 0.82,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: m.me ? C.pri : C.surface,
            borderRadius: BorderRadius.circular(16),
            border: m.me ? null : Border.all(color: C.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.reply.text,
                style: TextStyle(
                  color: m.me ? Colors.white : C.ink,
                  height: 1.35,
                ),
              ),
              for (final p in products) ...[
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => openProduct(context, p),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: C.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: ProductImage(p, radius: 10),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tBold,
                              ),
                              Text(rp(p.price), style: tMuted),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tambah ${p.name}',
                          onPressed: () {
                            s.add(p);
                            addedToCart(context, '${p.name} masuk keranjang');
                          },
                          icon: const Icon(Icons.add_circle, color: C.pri),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
