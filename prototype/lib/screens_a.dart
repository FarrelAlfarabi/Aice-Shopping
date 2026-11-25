import 'dart:async';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'home_extras.dart';
import 'i18n.dart';
import 'data.dart';
import 'format.dart';
import 'membership.dart';
import 'intro.dart';
import 'assistant.dart';
import 'motion.dart';
import 'screens_b.dart';
import 'screens_c.dart';
import 'consumer_extras.dart';
import 'admin.dart';
import 'state.dart';
import 'ui.dart';

/// Which bottom tab is showing: 0 Beranda, 1 Keranjang, 2 Pesanan, 3 Profil.
final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

/// One address per tab, so the browser's address bar and Back button work.
const tabPaths = ['/beranda', '/keranjang', '/pesanan', '/profil'];

/// Starts the tab from the address (for example #/pesanan) and keeps the
/// address in step with the tab. Call once when the app starts.
void syncTabWithAddress() {
  final i = tabPaths.indexOf(Uri.base.fragment);
  if (i > 0) tabIndex.value = i;
  tabIndex.addListener(() {
    SystemNavigator.routeInformationUpdated(
      uri: Uri(path: tabPaths[tabIndex.value]),
    );
  });
}

/// Snackbar after an add-to-cart, with a button that opens the cart tab.
void addedToCart(BuildContext context, String msg) {
  final nav = Navigator.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: tr('Lihat keranjang'),
          textColor: C.acc,
          onPressed: () {
            nav.popUntil((r) => r.isFirst);
            tabIndex.value = 1;
          },
        ),
      ),
    );
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool warmed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load every product photo once, right away, so Home tiles never pop in.
    if (!warmed) {
      warmed = true;
      precachePhotos(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    // No fake splash: the HTML page shows the splash while Flutter loads.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: !s.introSeen
          ? const IntroScreen()
          : (s.role == AppRole.admin ? const AdminShell() : const Shell()),
    );
  }
}

/// Picker for delivery address and store. Opened from Home or at checkout.
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late final TextEditingController ctl;
  @override
  void initState() {
    super.initState();
    final st = context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
    ctl = TextEditingController(text: st.address);
  }

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Alamat dan toko')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Alamat pengiriman', style: tH3),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctl,
                    onChanged: s.setAddress,
                    decoration: InputDecoration(
                      hintText: tr('Tulis alamat'),
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final a in s.saved)
                        SmallChip(
                          a.split(',').first,
                          onTap: () {
                            ctl.text = a;
                            s.setAddress(a);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Toko terdekat (contoh)', style: tH3),
                  const SizedBox(height: 8),
                  for (final st in stores)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OptionTile(
                        selected: s.store == st,
                        title: st.name,
                        subtitle: '${st.distance} · ${st.hours}',
                        onTap: () => s.chooseStore(st),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Center(child: Text(footerText, style: tMuted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BigButton(
                'Simpan',
                onPressed: s.hasAddress
                    ? () => Navigator.of(context).pop(true)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the address and store picker. Returns true when the person saved.
Future<bool> openAddress(BuildContext context) async {
  final ok = await Navigator.of(
    context,
  ).push<bool>(MaterialPageRoute(builder: (_) => const AddressScreen()));
  return ok ?? false;
}

class Shell extends StatelessWidget {
  const Shell({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, i, _) => PopScope(
        // Back from another tab goes to Beranda first.
        canPop: i == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) tabIndex.value = 0;
        },
        child: Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: i,
                children: const [
                  HomeTab(),
                  CartTab(),
                  OrdersTab(),
                  ProfileTab(),
                ],
              ),
              if (i == 0)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const AskAiButton(),
                      if (s.itemCount > 0) ...[
                        const SizedBox(height: 8),
                        const MiniCart(),
                      ],
                    ],
                  ),
                ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: i,
            backgroundColor: C.surface,
            indicatorColor: C.tint,
            onDestinationSelected: (v) => tabIndex.value = v,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: tr('Beranda'),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: s.itemCount > 0,
                  label: Bump(
                    trigger: s.itemCount,
                    child: Text('${s.itemCount}'),
                  ),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: const Icon(Icons.shopping_cart),
                label: tr('Keranjang'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: tr('Pesanan'),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: s.unreadCount > 0,
                  label: Text('${s.unreadCount}'),
                  child: const Icon(Icons.person_outline),
                ),
                selectedIcon: const Icon(Icons.person),
                label: tr('Profil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openProduct(BuildContext context, Product p, {Object? heroTag}) =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductScreen(p, heroTag: heroTag)),
    );

void openSearch(BuildContext context, {String query = '', String? category}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(query: query, category: category),
      ),
    );

/// Photo shown in each popular search chip.
const _chipPhoto = {
  'cone': 'cone-vanila.webp',
  'stik cokelat': 'stik-cokelat.webp',
  'paket pesta': 'bundle-keluarga.webp',
  'yoghurt': 'cup-blueberry.webp',
  'tub 700 ml': 'tub-stroberi.webp',
};

class _Slide {
  final String title;
  final String sub;
  final String photo;
  final List<Color> colors;
  final String category;
  const _Slide(this.title, this.sub, this.photo, this.colors, this.category);
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final page = PageController(viewportFraction: 0.9);
  int cur = 0;
  int hint = 0;
  Timer? auto;
  Timer? hintTimer;

  static const slides = <_Slide>[
    _Slide(
      'Beli 3 Diskon 10%',
      'Cone apa saja, campur rasa',
      'cone-vanila.webp',
      [Color(0xFF0B5FD8), Color(0xFF4A93FF)],
      'cone',
    ),
    _Slide(
      'Paket Pesta hemat',
      'Hemat sampai Rp15.000 (contoh)',
      'bundle-keluarga.webp',
      [Color(0xFF0A3F96), Color(0xFF2F6BE0)],
      'bundle',
    ),
    _Slide('Gratis ongkir', 'Belanja di atas Rp50.000', 'tub-stroberi.webp', [
      Color(0xFF0E7C86),
      Color(0xFF22B3A8),
    ], 'tub'),
  ];

  static final hints = ['es krim favoritmu', ...popularSearches];

  @override
  void initState() {
    super.initState();
    auto = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !page.hasClients) return;
      page.animateToPage(
        (cur + 1) % slides.length,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
    hintTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) setState(() => hint = (hint + 1) % hints.length);
    });
  }

  @override
  void dispose() {
    auto?.cancel();
    hintTimer?.cancel();
    page.dispose();
    super.dispose();
  }

  void _add(BuildContext context, Product p) {
    AppScope.of(context).add(p);
    addedToCart(context, '${p.name} ditambahkan');
  }

  Widget shelf(BuildContext context, String key, List<Product> items) =>
      SizedBox(
        height: cardExtent(context, 156) + 10,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final p = items[i];
            final tag = '$key-${p.id}';
            return ProductCard(
              p: p,
              width: 156,
              heroTag: tag,
              onTap: () => openProduct(context, p, heroTag: tag),
              onAdd: () => _add(context, p),
            );
          },
        ),
      );

  Widget _header(BuildContext context) {
    final s = AppScope.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: C.surface,
        border: Border(bottom: BorderSide(color: C.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Long press the wordmark to open the hidden demo controls.
              Expanded(
                child: GestureDetector(
                  onLongPress: () => showDemoControls(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'es krim shop (contoh)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: C.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: C.acc,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront, size: 13, color: C.accInk),
                    const SizedBox(width: 4),
                    Text(
                      s.store.name,
                      style: const TextStyle(
                        color: C.accInk,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          InkWell(
            key: const ValueKey('address-bar'),
            onTap: () => openAddress(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.place, color: C.muted, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      s.hasAddress ? s.address : 'Atur alamat pengiriman',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: C.ink,
                        fontWeight: s.hasAddress
                            ? FontWeight.w400
                            : FontWeight.w800,
                        decoration: s.hasAddress
                            ? null
                            : TextDecoration.underline,
                        decorationColor: C.ink,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: C.muted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: C.pri,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tiba dalam 15 Menit',
                  style: TextStyle(
                    color: C.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 38),
            child: Text(
              'Waktu contoh, bukan janji Aice',
              style: TextStyle(color: C.muted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Pressable(
                  onTap: () => openSearch(context),
                  scale: 0.98,
                  semanticLabel: 'Cari es krim',
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: C.tint,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: C.line),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: C.muted),
                        const SizedBox(width: 8),
                        const Text('Cari ', style: TextStyle(color: C.muted)),
                        Expanded(
                          child: ClipRect(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (c, a) => SlideTransition(
                                position:
                                    Tween(
                                      begin: const Offset(0, 0.8),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: a,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: FadeTransition(opacity: a, child: c),
                              ),
                              layoutBuilder: (cur, prev) => Stack(
                                alignment: Alignment.centerLeft,
                                children: [...prev, if (cur != null) cur],
                              ),
                              child: Text(
                                hint == 0 ? hints[0] : '"${hints[hint]}"',
                                key: ValueKey(hint),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: C.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Pressable(
                onTap: () => openAssistant(context),
                semanticLabel: 'Tanya AI',
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: C.acc,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome, color: C.accInk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popularSearches.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Pressable(
                    onTap: () => openAssistant(context),
                    semanticLabel: 'Tanya AI',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: const ShapeDecoration(
                        color: C.acc,
                        shape: StadiumBorder(),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: C.accInk),
                          SizedBox(width: 6),
                          Text(
                            'Tanya AI',
                            style: TextStyle(
                              color: C.accInk,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final q = popularSearches[i - 1];
                final f = _chipPhoto[q];
                return Pressable(
                  onTap: () => openSearch(context, query: q),
                  semanticLabel: 'Cari $q',
                  child: Container(
                    padding: EdgeInsets.fromLTRB(f == null ? 14 : 4, 4, 14, 4),
                    decoration: ShapeDecoration(
                      color: C.tint,
                      shape: const StadiumBorder(
                        side: BorderSide(color: C.line),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (f != null) ...[
                          ClipOval(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Photo(f, bg: C.ink, padding: 1),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          q,
                          style: const TextStyle(
                            color: C.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner(BuildContext context, int i) {
    final sl = slides[i];
    return AnimatedBuilder(
      animation: page,
      builder: (_, child) {
        var d = (i - cur).abs().toDouble();
        if (page.hasClients && page.position.haveDimensions) {
          d = ((page.page ?? 0) - i).abs();
        }
        return Transform.scale(
          scale: 1 - 0.06 * d.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: Pressable(
        onTap: () => openSearch(context, category: sl.category),
        scale: 0.98,
        semanticLabel: sl.title,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: sl.colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                right: -8,
                bottom: -12,
                width: 140,
                height: 140,
                child: Float(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Photo(sl.photo, bg: Colors.white, padding: 8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 132, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Ribbon('Contoh'),
                    const SizedBox(height: 6),
                    Text(
                      sl.title,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sl.sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Lihat promo',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: sl.colors.first,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: sl.colors.first,
                          ),
                        ],
                      ),
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

  /// Image button for a collection: photo bleeds into the pastel tile.
  Widget _collection(
    BuildContext context, {
    required String title,
    required String sub,
    required String photo,
    required String category,
    bool big = false,
  }) {
    final bg = tileColor(photo);
    final ps = big ? 132.0 : 64.0;
    return Pressable(
      onTap: () => openSearch(context, category: category),
      semanticLabel: title,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: big ? -10 : -6,
              bottom: big ? -10 : -8,
              width: ps,
              height: ps,
              child: big ? Float(dy: 4, child: Photo(photo)) : Photo(photo),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 10, big ? 12 : ps - 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: big ? 17 : 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: C.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (big) ...[
                    const Spacer(),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: C.ink,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _multiBuy(BuildContext context) {
    final s = AppScope.of(context);
    final n = catalog
        .where((p) => p.multiBuy)
        .fold<int>(0, (a, p) => a + s.qtyOf(p.id));
    final done = n >= 3;
    return Pressable(
      onTap: () => openSearch(context, category: 'cone'),
      scale: 0.98,
      semanticLabel: 'Promo beli 3 cone',
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140B1B33),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: const Photo('cone-cokelat.webp'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      done
                          ? 'Diskon 10% cone aktif'
                          : 'Beli 3 cone, diskon 10%',
                      key: ValueKey(done),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    done
                        ? 'Potongan dihitung otomatis di keranjang (contoh)'
                        : 'Tambah ${3 - n} cone lagi, boleh campur rasa',
                    style: tMuted,
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: (n.clamp(0, 3)) / 3),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 6,
                        backgroundColor: C.tint,
                        color: done ? C.good : C.pri,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: C.muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final best = [...catalog]..sort((a, b) => a.rank.compareTo(b.rank));
    final cones = catalog.where((p) => p.multiBuy).toList();
    final bundles = catalog.where((p) => p.category == 'bundle').toList();
    const pad = EdgeInsets.symmetric(horizontal: 16);
    var k = 0;
    Widget sec(Widget w) => FadeSlideIn(index: k++, child: w);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(context),
          const SizedBox(height: 12),
          sec(
            Column(
              children: [
                SizedBox(
                  height: 60 + MediaQuery.textScalerOf(context).scale(108),
                  child: PageView.builder(
                    controller: page,
                    itemCount: slides.length,
                    onPageChanged: (i) => setState(() => cur = i),
                    itemBuilder: (_, i) => _banner(context, i),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == cur ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == cur ? C.pri : C.line,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(padding: pad, child: PointsChip()),
          const SizedBox(height: 12),
          if (!AppScope.of(context).signedIn)
            const Padding(padding: pad, child: WelcomeBanner()),
          const SizedBox(height: 12),
          const CategoryTiles(),
          const SizedBox(height: 14),
          const FlashSale(),
          const SizedBox(height: 12),
          const ReorderRow(),
          const SizedBox(height: 6),
          sec(
            Padding(
              padding: pad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Kategori'),
                  const SizedBox(height: 6),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                    children: [
                      for (final e in categories.entries)
                        Pressable(
                          onTap: () => openSearch(context, category: e.key),
                          semanticLabel: e.value,
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Photo(
                                    photoByCategory[e.key]!,
                                    padding: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                e.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          sec(
            Padding(
              padding: pad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Koleksi pilihan'),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: MediaQuery.textScalerOf(context).scale(176),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: _collection(
                            context,
                            title: 'Paket Pesta',
                            sub: 'Mulai Rp28.500 (contoh)',
                            photo: 'bundle-keluarga.webp',
                            category: 'bundle',
                            big: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              Expanded(
                                child: _collection(
                                  context,
                                  title: 'Cemilan Anak',
                                  sub: 'Stik',
                                  photo: 'stik-cokelat.webp',
                                  category: 'stick',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: _collection(
                                  context,
                                  title: 'Hemat Berdua',
                                  sub: 'Yoghurt',
                                  photo: 'cup-blueberry.webp',
                                  category: 'cup',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          sec(Padding(padding: pad, child: _multiBuy(context))),
          const SizedBox(height: 10),
          sec(const Padding(padding: pad, child: MixPackCard())),
          const SizedBox(height: 12),
          sec(
            Column(
              children: [
                const Padding(
                  padding: pad,
                  child: SectionTitle(
                    'Rekomendasi untukmu',
                    sub: 'Berdasarkan popularitas dan riwayat belanjamu',
                  ),
                ),
                shelf(context, 'rec', recommendedFor(AppScope.of(context))),
              ],
            ),
          ),
          const SizedBox(height: 6),
          sec(
            Column(
              children: [
                Padding(
                  padding: pad,
                  child: SectionTitle(
                    'Terlaris',
                    action: 'Lihat semua',
                    onAction: () => openSearch(context),
                  ),
                ),
                shelf(context, 'best', best.take(6).toList()),
              ],
            ),
          ),
          const SizedBox(height: 6),
          sec(
            Column(
              children: [
                const Padding(padding: pad, child: SectionTitle('Rasa baru')),
                shelf(
                  context,
                  'new',
                  catalog.where((p) => p.ribbon == 'New').toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          sec(
            Column(
              children: [
                const Padding(
                  padding: pad,
                  child: SectionTitle('Minuman dingin'),
                ),
                shelf(
                  context,
                  'drink',
                  catalog.where((p) => p.category == 'drink').toList(),
                ),
              ],
            ),
          ),
          sec(
            Column(
              children: [
                const Padding(
                  padding: pad,
                  child: SectionTitle('Beli 3 Diskon 10% (cone)'),
                ),
                shelf(context, 'cone', cones),
              ],
            ),
          ),
          const SizedBox(height: 6),
          sec(
            Column(
              children: [
                const Padding(padding: pad, child: SectionTitle('Paket hemat')),
                shelf(context, 'bundle', bundles),
                const SizedBox(height: 8),
                Padding(padding: pad, child: PromoDeals(bundles)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Center(child: Text(footerText, style: tMuted)),
          const SizedBox(height: 150),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final String query;
  final String? category;
  const SearchScreen({super.key, this.query = '', this.category});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController ctl;
  String q = '';
  String? cat;
  String sort = 'Terlaris';
  @override
  void initState() {
    super.initState();
    q = widget.query;
    cat = widget.category;
    ctl = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  List<Product> results() {
    final words = q.toLowerCase().split(' ').where((w) => w.isNotEmpty);
    final list = catalog.where((p) {
      if (cat != null && p.category != cat) return false;
      final hay = '${p.name} ${categories[p.category]} ${p.size}'.toLowerCase();
      return words.every(hay.contains);
    }).toList();
    switch (sort) {
      case 'Termurah':
        list.sort((a, b) => a.price.compareTo(b.price));
      case 'Termahal':
        list.sort((a, b) => b.price.compareTo(a.price));
      default:
        list.sort((a, b) => a.rank.compareTo(b.rank));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final empty = q.trim().isEmpty && cat == null;
    final res = results();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: ctl,
          autofocus: widget.query.isEmpty && widget.category == null,
          onChanged: (v) => setState(() => q = v),
          decoration: InputDecoration(
            hintText: tr('Cari es krim favoritmu'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: q.isEmpty
                ? null
                : IconButton(
                    tooltip: tr('Hapus'),
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      ctl.clear();
                      q = '';
                    }),
                  ),
          ),
        ),
        actions: const [SizedBox(width: 12)],
      ),
      body: empty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Pencarian populer', style: tH3),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in [...popularSearches, 'es krim anak'])
                      SmallChip(
                        p,
                        onTap: () {
                          ctl.text = p;
                          setState(() => q = p);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Kategori', style: tH3),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in categories.entries)
                      SmallChip(
                        e.value,
                        onTap: () => setState(() => cat = e.key),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Ketik untuk melihat hasil langsung.',
                  style: tMuted,
                ),
              ],
            )
          : Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final o in ['Terlaris', 'Termurah', 'Termahal'])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SmallChip(
                            o,
                            on: sort == o,
                            onTap: () => setState(() => sort = o),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SmallChip(
                          'Semua tipe',
                          on: cat == null,
                          onTap: () => setState(() => cat = null),
                        ),
                      ),
                      for (final e in categories.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SmallChip(
                            e.value,
                            on: cat == e.key,
                            onTap: () => setState(() => cat = e.key),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${res.length} hasil (contoh)', style: tMuted),
                  ),
                ),
                Expanded(
                  child: res.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 48,
                              color: C.muted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tidak ada hasil untuk "$q"',
                              textAlign: TextAlign.center,
                              style: tH3,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Coba kata lain atau pilih pencarian populer.',
                              textAlign: TextAlign.center,
                              style: tMuted,
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final p in popularSearches)
                                  SmallChip(
                                    p,
                                    onTap: () {
                                      ctl.text = p;
                                      setState(() {
                                        q = p;
                                        cat = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, box) {
                            final w = (box.maxWidth - 32 - 12) / 2;
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    mainAxisExtent: cardExtent(context, w),
                                  ),
                              itemCount: res.length,
                              itemBuilder: (_, i) {
                                final p = res[i];
                                final tag = 'search-${p.id}';
                                return FadeSlideIn(
                                  key: ValueKey(p.id),
                                  index: i.clamp(0, 6),
                                  child: ProductCard(
                                    p: p,
                                    heroTag: tag,
                                    onTap: () =>
                                        openProduct(context, p, heroTag: tag),
                                    onAdd: () {
                                      s.add(p);
                                      addedToCart(
                                        context,
                                        '${p.name} ditambahkan',
                                      );
                                    },
                                  ),
                                );
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

class ProductScreen extends StatefulWidget {
  final Product p;
  final Object? heroTag;
  const ProductScreen(this.p, {super.key, this.heroTag});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int pack = 1; // units per add: 1, 6, 12
  int n = 1;
  int shot = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = widget.p;
    final hasPacks = p.category != 'bundle' && p.category != 'tub';
    final inCart = s.qtyOf(p.id);
    final units = pack * n;
    final similar = catalog
        .where((x) => x.category == p.category && x.id != p.id)
        .followedBy(catalog.where((x) => x.category != p.category))
        .take(5)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(p.name, style: const TextStyle(fontSize: 16))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: 3,
                  onPageChanged: (i) => setState(() => shot = i),
                  itemBuilder: (_, i) => ProductImage(
                    p,
                    radius: 24,
                    heroTag: i == 0 ? widget.heroTag : null,
                  ),
                ),
                if (p.ribbon != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Ribbon(p.ribbon!, sold: p.soldOut),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == shot ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == shot ? C.pri : C.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(p.name, style: tH2),
          Text('${p.size} · Contoh produk', style: tMuted),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PriceRow(p, size: 22),
              if (p.percentOff != null) Ribbon('-${p.percentOff}%'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const _Badge('Halal [no. contoh]'),
              const _Badge('BPOM [no. contoh]'),
              _Badge(p.chilled ? 'Simpan dingin 2-6°C' : 'Simpan -18°C'),
            ],
          ),
          const SizedBox(height: 12),
          ProductInfo(p),
          if (hasPacks && !p.soldOut) ...[
            const SizedBox(height: 14),
            const Text('Pilih isi', style: tH3),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in [1, 6, 12])
                  SmallChip(
                    k == 1 ? 'Satuan' : 'Isi $k',
                    on: pack == k,
                    onTap: () => setState(() => pack = k),
                  ),
              ],
            ),
          ],
          if (p.multiBuy) ...[
            const SizedBox(height: 14),
            Notice(
              inCart + units >= 3
                  ? 'Beli 3 Diskon 10% aktif untuk cone di keranjang.'
                  : 'Beli 3 Diskon 10%. Tambah ${3 - inCart - units} lagi untuk dapat diskon.',
            ),
          ],
          const SizedBox(height: 14),
          Panel(
            color: C.tint,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Garansi Tidak Meleleh', style: tBold),
                SizedBox(height: 2),
                Text(
                  'Meleleh saat tiba? Lapor dalam 24 jam, kami ganti atau kembalikan dana (contoh).',
                  style: tMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Deskripsi', style: tH3),
          const SizedBox(height: 4),
          Text(
            p.chilled
                ? '${p.name}, ${p.size}. Contoh deskripsi untuk demo. Simpan di kulkas 2-6°C dan habiskan sebelum tanggal kedaluwarsa.'
                : '${p.name}, ${p.size}. Contoh deskripsi untuk demo. Simpan di freezer -18°C dan jangan dibekukan ulang setelah meleleh.',
            style: const TextStyle(color: C.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          const Text('Produk Serupa', style: tH3),
          const SizedBox(height: 8),
          SizedBox(
            height: cardExtent(context, 156) + 8,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: similar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => ProductCard(
                p: similar[i],
                width: 156,
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ProductScreen(similar[i])),
                ),
                onAdd: () {
                  s.add(similar[i]);
                  addedToCart(context, '${similar[i].name} ditambahkan');
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
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
          child: p.soldOut
              ? const BigButton('Habis', onPressed: null)
              : Row(
                  children: [
                    QtyStepper(
                      qty: n,
                      onMinus: () => setState(() => n = n > 1 ? n - 1 : 1),
                      onPlus: () => setState(() => n++),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BigButton(
                        'Tambah',
                        trailing: rp(p.price * units),
                        onPressed: () {
                          s.add(p, units);
                          addedToCart(context, '$units ${p.name} ditambahkan');
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String t;
  const _Badge(this.t);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: C.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: C.line),
    ),
    child: Text(
      t,
      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
    ),
  );
}
