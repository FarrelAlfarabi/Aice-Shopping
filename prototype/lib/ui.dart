import 'package:flutter/material.dart';
import 'data.dart';
import 'format.dart';

/// Design tokens from the picked direction "A Segar".
class C {
  static const pri = Color(0xFF0B5FD8);
  static const priDark = Color(0xFF0A3F96);
  static const ink = Color(0xFF0B1B33);
  static const muted = Color(0xFF55627A);
  static const bg = Color(0xFFF4F8FF);
  static const surface = Colors.white;
  static const line = Color(0xFFD9E3F2);
  static const tint = Color(0xFFEAF2FF);
  static const acc = Color(0xFFFFC93C);
  static const accInk = Color(0xFF3A2A00);
  static const good = Color(0xFF0C7A43);
  static const warnBg = Color(0xFFFFF4D6);
  static const warnInk = Color(0xFF5B4300);
  static const danger = Color(0xFFB3261E);
}

const double rCard = 16;

ThemeData buildTheme() {
  final base = ColorScheme.fromSeed(seedColor: C.pri, primary: C.pri);
  return ThemeData(
    useMaterial3: true,
    colorScheme: base,
    scaffoldBackgroundColor: C.bg,
    textTheme: Typography.blackMountainView.apply(
      bodyColor: C.ink,
      displayColor: C.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      foregroundColor: C.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.pri, width: 2),
      ),
    ),
  );
}

const TextStyle tH2 =
    TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.15);
const TextStyle tH3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w800);
const TextStyle tMuted = TextStyle(fontSize: 12.5, color: C.muted);
const TextStyle tBold = TextStyle(fontWeight: FontWeight.w700);

IconData iconFor(String category) {
  switch (category) {
    case 'tub':
      return Icons.icecream;
    case 'stick':
      return Icons.local_pizza_outlined;
    case 'cup':
      return Icons.breakfast_dining_outlined;
    case 'drink':
      return Icons.local_drink_outlined;
    case 'bundle':
      return Icons.card_giftcard_outlined;
    default:
      return Icons.icecream_outlined;
  }
}

/// Small rounded photo for a product category (Home tiles, banners). Uses the
/// same bundled placeholder photos as products, with an icon as the fallback.
class CategoryPhoto extends StatelessWidget {
  final String category;
  final String? file; // optional specific photo under assets/products
  final double size;
  final bool circle;
  const CategoryPhoto(this.category,
      {super.key, required this.size, this.file, this.circle = false});

  @override
  Widget build(BuildContext context) {
    final name = file ?? ProductImage._photoByCategory[category]!;
    final img = Image.asset(
      'assets/products/$name',
      width: size,
      height: size,
      fit: BoxFit.cover,
      cacheWidth: (size * 3).round(), // keep decoded size small
      errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: C.tint,
          child: Icon(iconFor(category), size: size * 0.5, color: C.pri)),
    );
    return circle
        ? ClipOval(child: img)
        : ClipRRect(borderRadius: BorderRadius.circular(size * 0.22), child: img);
  }
}

/// Shows a product photo from assets/products when the file exists, and a
/// drawn placeholder when it does not. Dropping a photo into that folder is
/// all it takes to swap one in.
class ProductImage extends StatelessWidget {
  final Product product;
  final double? size;
  final double radius;
  const ProductImage(this.product, {super.key, this.size, this.radius = 14});

  static const _photoByCategory = {
    'cone': 'cone-vanila.jpg',
    'stick': 'stik-cokelat.jpg',
    'tub': 'tub-stroberi.jpg',
    'cup': 'cup-blueberry.jpg',
    'drink': 'drink-cokelat.jpg',
    'bundle': 'bundle-keluarga.jpg',
  };

  @override
  Widget build(BuildContext context) {
    final file = product.photo ?? _photoByCategory[product.category]!;
    final fallback = Container(
      color: C.tint,
      alignment: Alignment.center,
      child: Icon(iconFor(product.category),
          size: (size ?? 80) * 0.5, color: C.pri),
    );
    Widget img = Image.asset(
      'assets/products/$file',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
      semanticLabel: product.name,
    );
    if (product.soldOut) {
      img = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: Opacity(opacity: 0.6, child: img),
      );
    }
    final box = ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
    if (size != null) return SizedBox(width: size, height: size, child: box);
    return AspectRatio(aspectRatio: 1, child: box);
  }
}

class Ribbon extends StatelessWidget {
  final String text;
  final bool sold;
  const Ribbon(this.text, {super.key, this.sold = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: sold ? C.line : C.acc,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: sold ? C.ink : C.accInk,
            )),
      );
}

class PriceRow extends StatelessWidget {
  final Product p;
  final double size;
  const PriceRow(this.p, {super.key, this.size = 14});
  @override
  Widget build(BuildContext context) => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(rp(p.price),
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: size)),
          if (p.oldPrice != null)
            Text(rp(p.oldPrice!),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: C.muted,
                  decoration: TextDecoration.lineThrough,
                )),
        ],
      );
}

class ProductCard extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final double? width;
  const ProductCard(
      {super.key,
      required this.p,
      required this.onTap,
      required this.onAdd,
      this.width});

  @override
  Widget build(BuildContext context) {
    final label = p.ribbon ?? (p.percentOff != null ? '-${p.percentOff}%' : null);
    return SizedBox(
      width: width,
      child: Material(
        color: C.surface,
        borderRadius: BorderRadius.circular(rCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(rCard),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rCard),
              border: Border.all(color: C.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(children: [
                  ProductImage(p),
                  if (label != null)
                    Positioned(
                        top: 6, left: 6, child: Ribbon(label, sold: p.soldOut)),
                ]),
                const SizedBox(height: 8),
                Text(p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12.5, height: 1.25)),
                Text(p.size, style: const TextStyle(fontSize: 11, color: C.muted)),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(child: PriceRow(p)),
                  if (p.soldOut)
                    const Text('Habis',
                        style: TextStyle(fontSize: 11, color: C.muted))
                  else
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton.filled(
                        onPressed: onAdd,
                        tooltip: 'Tambah ${p.name}',
                        style: IconButton.styleFrom(
                            backgroundColor: C.pri, foregroundColor: Colors.white),
                        icon: const Icon(Icons.add, size: 20),
                      ),
                    ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BigButton extends StatelessWidget {
  final String label;
  final String? trailing;
  final VoidCallback? onPressed;
  final bool secondary;
  const BigButton(this.label,
      {super.key, this.trailing, this.onPressed, this.secondary = false});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: secondary ? C.surface : C.pri,
            foregroundColor: secondary ? C.ink : Colors.white,
            disabledBackgroundColor: C.line,
            disabledForegroundColor: C.muted,
            side: secondary ? const BorderSide(color: C.line) : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          child: Row(
            mainAxisAlignment: trailing == null
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [Text(label), if (trailing != null) Text(trailing!)],
          ),
        ),
      );
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color? border;
  const Panel(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(14),
      this.color = C.surface,
      this.border = C.line});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(rCard),
          border: border == null ? null : Border.all(color: border!),
        ),
        child: child,
      );
}

class Notice extends StatelessWidget {
  final String text;
  final bool good;
  const Notice(this.text, {super.key, this.good = false});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: good ? const Color(0xFFDDF5E9) : C.warnBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: good ? C.good : C.warnInk)),
      );
}

class QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const QtyStepper(
      {super.key, required this.qty, required this.onMinus, required this.onPlus});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: C.line),
          borderRadius: BorderRadius.circular(99),
          color: C.surface,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              onPressed: onMinus,
              tooltip: 'Kurangi',
              icon: const Icon(Icons.remove, size: 18)),
          SizedBox(
              width: 22,
              child: Text('$qty',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          IconButton(
              onPressed: onPlus,
              tooltip: 'Tambah',
              icon: const Icon(Icons.add, size: 18)),
        ]),
      );
}

class OptionTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  const OptionTile(
      {super.key,
      required this.selected,
      required this.title,
      required this.onTap,
      this.subtitle,
      this.trailing});
  @override
  Widget build(BuildContext context) => Material(
        color: C.surface,
        borderRadius: BorderRadius.circular(rCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(rCard),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rCard),
              border: Border.all(
                  color: selected ? C.pri : C.line, width: selected ? 2 : 1),
            ),
            child: Row(children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? C.pri : C.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: tBold),
                    if (subtitle != null) Text(subtitle!, style: tMuted),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ]),
          ),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: tH3)),
        if (action != null)
          TextButton(
              onPressed: onAction,
              child: Text(action!, style: const TextStyle(color: C.muted))),
      ]);
}

class SmallChip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const SmallChip(this.label, {super.key, this.on = false, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: on ? C.ink : C.surface,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: on ? C.ink : C.line),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: on ? Colors.white : C.ink)),
            ),
          ),
        ),
      );
}

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(milliseconds: 1400),
      behavior: SnackBarBehavior.floating,
    ));
}

const footerText = 'Demo konsep. Bukan aplikasi resmi Aice.';
