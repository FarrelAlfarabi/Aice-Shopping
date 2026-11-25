import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'data.dart';
import 'theme.dart';
import 'format.dart';
import 'motion.dart';
import 'state.dart';

export 'theme.dart';

const double rCard = 16;

/// Height a [ProductCard] needs at [width], growing with the phone's text size.
double cardExtent(BuildContext context, double width) =>
    width + MediaQuery.textScalerOf(context).scale(80) + 12;

ThemeData buildTheme() {
  final base = ColorScheme.fromSeed(seedColor: C.pri, primary: C.pri);
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    fontFamilyFallback: const ['ZhSubset'],
    colorScheme: base,
    scaffoldBackgroundColor: C.bg,
    textTheme: Typography.blackMountainView.apply(
      bodyColor: C.ink,
      displayColor: C.ink,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: C.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: C.surface,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(color: C.line, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: C.tint,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (st) => TextStyle(
          fontSize: 12,
          fontWeight: st.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: st.contains(WidgetState.selected) ? C.pri : C.muted,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontFamilyFallback: ['ZhSubset'],
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: C.ink,
      ),
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

// ---------------------------------------------------------------- Design rules
// One set of rules for every consumer screen (see docs/design-rules.md):
// - Spacing comes from [Sp] only: 4, 8, 12, 16, 24.
// - Type: [tH2] page title, [tH3] section title, [tBody] rows and body text,
//   [tMuted] helper text. Bold only for titles and prices ([tPrice], [tBold]).
// - One card style: [Panel] (white, 16 radius, 1 px light border, no shadow).
//   Never put a bordered card inside another card.
// - Lists: a section title, then one [ListGroup] whose rows ([ListRow],
//   [OptionTile]) have no border of their own. Dividers only between rows of
//   one group, never next to a border.
// - Selected state: a check mark or a filled chip, never an extra box.
// - Tap targets at least 44 px high.

/// Spacing scale. Use these instead of loose numbers.
class Sp {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}

const TextStyle tH2 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  height: 1.2,
);
const TextStyle tH3 = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);
const TextStyle tBody = TextStyle(fontSize: 15, height: 1.3);
const TextStyle tMuted = TextStyle(fontSize: 13, color: C.muted, height: 1.3);
const TextStyle tBold = TextStyle(fontWeight: FontWeight.w600);
const TextStyle tPrice = TextStyle(fontWeight: FontWeight.w700);

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
    case 'frozen':
      return Icons.set_meal_outlined;
    default:
      return Icons.icecream_outlined;
  }
}

/// Photo file for each category, used when a product has no photo of its own.
const photoByCategory = {
  'cone': 'cone-vanila.webp',
  'stick': 'stik-cokelat.webp',
  'tub': 'tub-stroberi.webp',
  'cup': 'cup-blueberry.webp',
  'drink': 'drink-cokelat.webp',
  'bundle': 'bundle-keluarga.webp',
  'frozen': 'frozen-naget.webp',
};

/// Soft pastel behind each photo. The photos have a pure white background, so
/// multiplying them onto this colour makes the background melt into the tile
/// and only the product shows (the Astro look, without cut-out files).
const _tileByPhoto = {
  'cone-vanila.webp': Color(0xFFFFE5EC),
  'cone-cokelat.webp': Color(0xFFF5E7D9),
  'cone-matcha.webp': Color(0xFFE2F4E0),
  'stik-cokelat.webp': Color(0xFFF7EADB),
  'tub-stroberi.webp': Color(0xFFFFE3EA),
  'cup-blueberry.webp': Color(0xFFE9E5FF),
  'drink-cokelat.webp': Color(0xFFF2E8DE),
  'bundle-keluarga.webp': Color(0xFFFFF0D4),
  'cone-taro.webp': Color(0xFFEFE4FF),
  'cone-mangga.webp': Color(0xFFFFF3CF),
  'cone-mint.webp': Color(0xFFDDF6F1),
  'cone-mocha.webp': Color(0xFFF1E6DC),
  'stik-dark.webp': Color(0xFFF0E6DE),
  'stik-stroberi.webp': Color(0xFFFFE3E6),
  'tub-mangga.webp': Color(0xFFFFF3CF),
  'tub-taro.webp': Color(0xFFEFE4FF),
  'tub-mint.webp': Color(0xFFDDF6F1),
  'cup-stroberi.webp': Color(0xFFF6E6F4),
  'cup-matcha.webp': Color(0xFFE5F3E0),
  'drink-stroberi.webp': Color(0xFFFFE3EA),
  'drink-matcha.webp': Color(0xFFE5F3E0),
  'drink-taro.webp': Color(0xFFEFE4FF),
  'paket-cone.webp': Color(0xFFFFF0D4),
  'paket-stik.webp': Color(0xFFF7EADB),
  'paket-tub.webp': Color(0xFFFFEFD9),
  'paket-yoghurt.webp': Color(0xFFEDE8FF),
  'cup-original.webp': Color(0xFFE9F1FF),
  'frozen-naget.webp': Color(0xFFFFF0D9),
  'frozen-tahu.webp': Color(0xFFDFF3F5),
  'frozen-sosis.webp': Color(0xFFFFE6E1),
};

Color tileColor(String file) => _tileByPhoto[file] ?? C.tint;

String photoFor(Product p) => p.photo ?? photoByCategory[p.category]!;

/// Every product photo, so the app can load them all once at start.
List<String> get allPhotos => _tileByPhoto.keys.toList();

/// A product photo sitting on its pastel tile. Fades in the first time it
/// loads; after [precachePhotos] it shows at once.
class Photo extends StatelessWidget {
  final String file;
  final Color? bg;
  final bool grey;
  final double padding;
  final String? label;
  const Photo(
    this.file, {
    super.key,
    this.bg,
    this.grey = false,
    this.padding = 0,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final tile = grey ? const Color(0xFFEDEFF3) : (bg ?? tileColor(file));
    Widget img = Image.asset(
      'assets/products/$file',
      fit: BoxFit.contain,
      color: tile,
      colorBlendMode: BlendMode.multiply,
      semanticLabel: label,
      excludeFromSemantics: label == null,
      gaplessPlayback: true,
      frameBuilder: (_, child, frame, sync) => sync
          ? child
          : AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              child: child,
            ),
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.icecream_outlined, color: C.pri, size: 36),
      ),
    );
    if (grey) {
      img = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: Opacity(opacity: 0.55, child: img),
      );
    }
    return ColoredBox(
      color: tile,
      child: Padding(padding: EdgeInsets.all(padding), child: img),
    );
  }
}

/// Loads all product photos into memory so tiles never pop in.
Future<void> precachePhotos(BuildContext context) => Future.wait([
  for (final f in allPhotos)
    precacheImage(AssetImage('assets/products/$f'), context).catchError((_) {}),
]);

/// Square product photo with rounded corners. Pass [heroTag] to fly the
/// photo into the product page.
class ProductImage extends StatelessWidget {
  final Product product;
  final double? size;
  final double radius;
  final Object? heroTag;
  const ProductImage(
    this.product, {
    super.key,
    this.size,
    this.radius = 14,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget box = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Photo(
        photoFor(product),
        grey: product.soldOut,
        label: product.name,
      ),
    );
    if (heroTag != null) box = Hero(tag: heroTag!, child: box);
    if (size != null) return SizedBox(width: size, height: size, child: box);
    return AspectRatio(aspectRatio: 1, child: box);
  }
}

class Ribbon extends StatelessWidget {
  final String text;
  final bool sold;
  final Color? color;
  final Color? ink;
  const Ribbon(this.text, {super.key, this.sold = false, this.color, this.ink});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: sold ? C.line : (color ?? C.acc),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: sold ? C.ink : (ink ?? C.accInk),
      ),
    ),
  );
}

class PriceRow extends StatelessWidget {
  final Product p;
  final double size;
  final bool oneLine;

  /// Shown instead of the product's own price (for example a flash price).
  final int? price;
  const PriceRow(
    this.p, {
    super.key,
    this.size = 14,
    this.oneLine = false,
    this.price,
  });
  @override
  Widget build(BuildContext context) {
    final now = price ?? p.price;
    final was = price != null ? p.price : p.oldPrice;
    final parts = <Widget>[
      Text(
        rp(now),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: size,
          color: was != null ? C.danger : C.ink,
        ),
      ),
      if (was != null)
        Text(
          rp(was),
          style: const TextStyle(
            fontSize: 11.5,
            color: C.muted,
            decoration: TextDecoration.lineThrough,
          ),
        ),
    ];
    if (oneLine) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            parts[i],
          ],
        ],
      );
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: parts,
    );
  }
}

/// Product card: photo tile with a quick-add button on the photo. After the
/// first add the button grows into a  − 1 +  stepper, like Astro.
class ProductCard extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final double? width;
  final Object? heroTag;

  /// Flash price, shown with the normal price crossed out.
  final int? price;

  /// Overrides the ribbon on the photo (for example "-20%").
  final String? badge;

  /// Key for the first quick-add button, for tests.
  final Key? addKey;
  const ProductCard({
    super.key,
    required this.p,
    required this.onTap,
    required this.onAdd,
    this.width,
    this.heroTag,
    this.price,
    this.badge,
    this.addKey,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final qty = s.qtyOf(p.id);
    final label =
        badge ??
        p.ribbon ??
        (p.percentOff != null ? '-${p.percentOff}%' : null);
    return SizedBox(
      width: width,
      child: Pressable(
        onTap: onTap,
        scale: 0.97,
        semanticLabel: p.name,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(rCard + 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140B1B33),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ProductImage(p, heroTag: heroTag, radius: rCard - 2),
                  if (label != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Ribbon(label, sold: p.soldOut),
                    ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: p.soldOut
                        ? const SizedBox.shrink()
                        : _AddControl(
                            addKey: addKey,
                            qty: qty,
                            name: p.name,
                            onAdd: onAdd,
                            onMore: () => s.add(p),
                            onRemove: () => s.remove(p),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.size,
                      style: const TextStyle(fontSize: 11.5, color: C.muted),
                    ),
                    const SizedBox(height: 4),
                    // One line always: shrinks instead of wrapping on small
                    // phones or large text, so the card height stays known.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: PriceRow(p, oneLine: true, price: price),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddControl extends StatelessWidget {
  final Key? addKey;
  final int qty;
  final String name;
  final VoidCallback onAdd; // first add: shows the snackbar
  final VoidCallback onMore; // later adds: quiet, the stepper shows the count
  final VoidCallback onRemove;
  const _AddControl({
    this.addKey,
    required this.qty,
    required this.name,
    required this.onAdd,
    required this.onMore,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData i, VoidCallback f, String tip, {Key? key}) => Semantics(
      button: true,
      label: tip,
      child: InkResponse(
        key: key,
        onTap: f,
        radius: 22,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(i, size: 22, color: Colors.white),
        ),
      ),
    );
    return Material(
      color: C.pri,
      elevation: 3,
      shadowColor: const Color(0x550B5FD8),
      shape: const StadiumBorder(),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: qty == 0
            ? Tooltip(
                message: 'Tambah $name',
                child: btn(Icons.add, onAdd, 'Tambah $name', key: addKey),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  btn(Icons.remove, onRemove, 'Kurangi $name'),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (c, a) =>
                        ScaleTransition(scale: a, child: c),
                    child: SizedBox(
                      key: ValueKey(qty),
                      width: 20,
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  btn(Icons.add, onMore, 'Tambah $name'),
                ],
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
  const BigButton(
    this.label, {
    super.key,
    this.trailing,
    this.onPressed,
    this.secondary = false,
  });
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
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      child: Row(
        mainAxisAlignment: trailing == null
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                trailing!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color? border;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = C.surface,
    this.border = C.line,
  });
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

/// A short message on a soft colour fill (no border): yellow for a nudge,
/// green when something worked.
class Notice extends StatelessWidget {
  final String text;
  final bool good;
  const Notice(this.text, {super.key, this.good = false});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: Sp.m, vertical: 10),
    decoration: BoxDecoration(
      color: good ? C.goodBg : C.warnBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13.5,
        color: good ? C.good : C.warnInk,
      ),
    ),
  );
}

/// Minus, count, plus on a soft fill. 44 px buttons.
class QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const QtyStepper({
    super.key,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(99),
      color: C.tint,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onMinus,
          tooltip: tr('Kurangi'),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: const Icon(Icons.remove, size: 18, color: C.pri),
        ),
        SizedBox(
          width: 22,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: onPlus,
          tooltip: tr('Tambah'),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: const Icon(Icons.add, size: 18, color: C.pri),
        ),
      ],
    ),
  );
}

/// One card that holds a list of rows, with an optional section title above
/// it. Rows are separated by a thin inset line; the rows themselves have no
/// border. This is the only place dividers are drawn.
class ListGroup extends StatelessWidget {
  final String? title;
  final Widget? action;
  final List<Widget> children;

  /// Left inset of the lines between rows (lines up with the row text when
  /// the rows have an icon).
  final double indent;
  const ListGroup({
    super.key,
    this.title,
    this.action,
    required this.children,
    this.indent = 52,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title != null)
        Padding(
          padding: const EdgeInsets.only(left: Sp.xs, bottom: Sp.s),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Row(
              children: [
                Expanded(child: Text(title!, style: tH3)),
                if (action != null) action!,
              ],
            ),
          ),
        ),
      Panel(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(rCard),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: indent,
                    color: C.line.withValues(alpha: 0.7),
                  ),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}

/// A row inside a [ListGroup]: icon, title (normal weight), optional
/// subtitle, value and trailing widget. Shows a chevron when it opens
/// something. At least 56 px high.
class ListRow extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;
  final bool external;
  final int badge;
  final Color? titleColor;
  const ListRow({
    super.key,
    required this.title,
    this.icon,
    this.leading,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.chevron = true,
    this.external = false,
    this.badge = 0,
    this.titleColor,
  });
  @override
  Widget build(BuildContext context) {
    final lead =
        leading ??
        (icon == null
            ? null
            : Badge(
                isLabelVisible: badge > 0,
                smallSize: 8,
                child: Icon(icon, color: C.pri, size: 22),
              ));
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: Sp.l, vertical: 10),
        child: Row(
          children: [
            if (lead != null) ...[
              leading ?? SizedBox(width: 22, child: Center(child: lead)),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: tBody.copyWith(color: titleColor)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!, style: tMuted),
                    ),
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: Sp.s),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  value!,
                  textAlign: TextAlign.end,
                  style: tMuted.copyWith(fontSize: 14),
                ),
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: Sp.s),
              trailing!,
            ] else if (onTap != null && chevron) ...[
              const SizedBox(width: Sp.xs),
              Icon(
                external ? Icons.open_in_new : Icons.chevron_right,
                size: external ? 18 : 22,
                color: C.muted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A choice inside a [ListGroup]. The chosen row shows a blue check mark;
/// there is no extra box or border.
class OptionTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final IconData? icon;
  const OptionTile({
    super.key,
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.icon,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    inMutuallyExclusiveGroup: true,
    child: ListRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      titleColor: selected ? C.pri : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          SizedBox(
            width: 32,
            child: Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? C.pri : C.line,
              size: 22,
            ),
          ),
        ],
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final String? sub;
  const SectionTitle(
    this.title, {
    super.key,
    this.action,
    this.onAction,
    this.sub,
  });
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 44),
    child: Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: tH3),
              if (sub != null) Text(sub!, style: tMuted),
            ],
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(color: C.pri, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    ),
  );
}

/// A pill. Chosen: blue fill, white text. Not chosen: soft fill, no border.
class SmallChip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const SmallChip(
    this.label, {
    super.key,
    this.on = false,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    selected: on,
    button: true,
    child: Material(
      color: on ? C.pri : C.tint,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: on ? Colors.white : C.ink,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

const footerText = 'Demo konsep. Bukan aplikasi resmi Aice.';

/// Asks "are you sure?" before a step that is hard to undo. True when the
/// person says yes.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String yes,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          key: const ValueKey('confirm-no'),
          onPressed: () => Navigator.of(c).pop(false),
          child: Text(tr('Batal')),
        ),
        FilledButton(
          key: const ValueKey('confirm-yes'),
          onPressed: () => Navigator.of(c).pop(true),
          child: Text(tr(yes)),
        ),
      ],
    ),
  );
  return r ?? false;
}
