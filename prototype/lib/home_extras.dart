import 'dart:async';
import 'package:flutter/material.dart' hide Text;
import 'assistant.dart';
import 'data.dart';
import 'format.dart';
import 'i18n.dart';
import 'motion.dart';
import 'pricing.dart';
import 'screens_a.dart';
import 'state.dart';
import 'ui.dart';

/// Home pieces from the design preview: photo category tiles, Flash Sale with
/// a countdown, the sticky mini-cart and the floating Tanya AI button.

/// The product whose photo stands for each shelf on the home tiles.
const _tileHero = {
  'yogurt': 'cup-original',
  'frozen': 'frozen-naget',
  'icecream': 'cone-vanila',
  'sayur': 'veg-bayam',
  'sembako': 'staple-beras',
  'drink': 'drink-cokelat',
  'snack': 'snack-keripik',
};

const _tileLabel = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500);

class CategoryTiles extends StatelessWidget {
  const CategoryTiles({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('category-tiles'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: Sp.l),
          child: SectionTitle('Kategori'),
        ),
        const SizedBox(height: Sp.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, c) {
              // 7 shelves plus "Semua" make two even rows of 4.
              final w = (c.maxWidth - 3 * Sp.m) / 4;
              return Wrap(
                spacing: Sp.m,
                runSpacing: Sp.m,
                children: [
                  for (final k in categories.keys)
                    SizedBox(
                      width: w,
                      child: InkWell(
                        key: ValueKey('cat-$k'),
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => openSearch(context, category: k),
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: ProductImage(
                                productById(_tileHero[k]!),
                                radius: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              categories[k]!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: _tileLabel,
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(
                    width: w,
                    child: InkWell(
                      key: const ValueKey('cat-all'),
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => openSearch(context, query: ''),
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: C.tint,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                color: C.pri,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Semua',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: _tileLabel,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

String _hms(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}

class FlashSale extends StatefulWidget {
  const FlashSale({super.key});
  @override
  State<FlashSale> createState() => _FlashSaleState();
}

class _FlashSaleState extends State<FlashSale> {
  Timer? t;
  @override
  void initState() {
    super.initState();
    // Tests turn loopMotion off so no timer keeps the screen busy.
    if (loopMotion) {
      t = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    if (!s.flashOn) return const SizedBox.shrink();
    final items = [
      for (final id in flashDeals.keys) productById(id),
    ].where((p) => !p.soldOut).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.l),
      child: Column(
        key: const ValueKey('flash-sale'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.l),
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  const Expanded(child: Text('Flash Sale', style: tH3)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sp.s,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: C.acc,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _hms(s.flashLeft),
                      key: const ValueKey('flash-countdown'),
                      style: const TextStyle(
                        color: C.accInk,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: cardExtent(context, 140) + 10,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Sp.l, 2, Sp.l, Sp.s),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: Sp.m),
              itemBuilder: (_, i) {
                final p = items[i];
                return ProductCard(
                  p: p,
                  width: 140,
                  price: flashUnitPrice(p),
                  badge: '-${flashDeals[p.id]}%',
                  addKey: ValueKey('flash-add-${p.id}'),
                  onTap: () => openProduct(context, p),
                  onAdd: () {
                    s.add(p);
                    addedToCart(context, '${p.name} masuk keranjang');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bar at the bottom of Beranda: items, subtotal and how far the cart
/// is from free delivery.
class MiniCart extends StatelessWidget {
  const MiniCart({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.pricing;
    final free = p.toFreeDelivery == 0 || s.tier.freeDelivery;
    return Material(
      key: const ValueKey('mini-cart'),
      color: C.pri,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${s.itemCount} item · ${rp(p.subtotal)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    free
                        ? 'Gratis ongkir terpenuhi'
                        : 'Tambah ${rp(p.toFreeDelivery)} lagi untuk gratis ongkir',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  if (!free)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: p.freeProgress,
                          minHeight: 5,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              key: const ValueKey('mini-cart-open'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: C.priDark,
              ),
              onPressed: () => tabIndex.value = 1,
              child: const Text('Lihat keranjang'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating "Tanya AI" button on Beranda.
class AskAiButton extends StatelessWidget {
  const AskAiButton({super.key});
  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    key: const ValueKey('ask-ai-fab'),
    heroTag: 'ask-ai-fab',
    backgroundColor: C.acc,
    foregroundColor: C.accInk,
    onPressed: () => openAssistant(context),
    icon: const Icon(Icons.auto_awesome),
    label: const Text('Tanya AI'),
  );
}
