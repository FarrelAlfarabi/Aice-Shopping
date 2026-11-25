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

const _tileCategories = ['cone', 'tub', 'stick', 'cup', 'frozen', 'drink'];

class CategoryTiles extends StatelessWidget {
  const CategoryTiles({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('category-tiles'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SectionTitle('Kategori'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = (c.maxWidth - 20) / 3;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final k in _tileCategories)
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
                                catalog.firstWhere(
                                  (p) => p.category == k && !p.soldOut,
                                ),
                                radius: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              categories[k]!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tBold,
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
    return Column(
      key: const ValueKey('flash-sale'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('⚡ Flash Sale (contoh)', style: tH3),
              Text(
                'Berakhir dalam ${_hms(s.flashLeft)}',
                key: const ValueKey('flash-countdown'),
                style: const TextStyle(
                  color: C.acc,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 240 + 220 * (MediaQuery.textScalerOf(context).scale(1) - 1),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final p in items)
                Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: C.surface,
                    border: Border.all(color: C.line),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => openProduct(context, p),
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 92,
                              width: double.infinity,
                              child: ProductImage(p, radius: 10),
                            ),
                            Positioned(
                              left: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: C.acc,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  '-${flashDeals[p.id]}%',
                                  style: const TextStyle(
                                    color: C.accInk,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tBold,
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          Text(
                            rp(flashUnitPrice(p)),
                            style: const TextStyle(
                              color: C.acc,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            rp(p.price),
                            style: const TextStyle(
                              color: C.muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: ValueKey('flash-add-${p.id}'),
                          onPressed: () {
                            s.add(p);
                            addedToCart(context, '${p.name} masuk keranjang');
                          },
                          child: const Text('Tambah'),
                        ),
                      ),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    free
                        ? 'Gratis ongkir tercapai'
                        : 'Belanja ${rp(p.toFreeDelivery)} lagi untuk gratis ongkir',
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
