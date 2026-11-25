import 'dart:async';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'home_extras.dart';
import 'i18n.dart';
import 'data.dart';
import 'format.dart';
import 'membership.dart';
import 'intro.dart';
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
                  const SizedBox(height: Sp.xl),
                  ListGroup(
                    title: 'Toko terdekat',
                    children: [
                      for (final st in stores)
                        OptionTile(
                          icon: Icons.storefront_outlined,
                          selected: s.store == st,
                          title: st.name,
                          subtitle: '${st.area} · ${st.distance} · ${st.hours}',
                          onTap: () => s.chooseStore(st),
                        ),
                    ],
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
      'Hemat sampai Rp15.000',
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

  /// Address and store on the left, delivery time chip on the right, then
  /// search. Long press the address to open the hidden demo controls.
  Widget _header(BuildContext context) {
    final s = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.l, Sp.s, Sp.l, Sp.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onLongPress: () => showDemoControls(context),
                  child: InkWell(
                    key: const ValueKey('address-bar'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => openAddress(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Sp.xs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place, color: C.pri, size: 18),
                              const SizedBox(width: Sp.xs),
                              Flexible(
                                child: Text(
                                  s.hasAddress
                                      ? s.address
                                      : 'Atur alamat pengiriman',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: C.ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: C.ink,
                                size: 20,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: Text(
                              '${s.store.name} · ${s.store.distance}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Sp.s),
              Container(
                key: const ValueKey('eta-chip'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: C.tint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 16, color: C.pri),
                    SizedBox(width: 2),
                    Text(
                      '15 menit',
                      style: TextStyle(
                        color: C.pri,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const ValueKey('home-bell'),
                tooltip: tr('Notifikasi'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NoticesScreen()),
                ),
                icon: Badge(
                  isLabelVisible: s.unreadCount > 0,
                  label: Text('${s.unreadCount}'),
                  child: const Icon(Icons.notifications_none, color: C.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.m),
          Pressable(
            onTap: () => openSearch(context),
            scale: 0.98,
            semanticLabel: 'Cari es krim',
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: C.tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: C.muted),
                  const SizedBox(width: Sp.s),
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
                          style: const TextStyle(color: C.muted),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                    Text(
                      sl.title,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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
                                fontWeight: FontWeight.w700,
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

  /// Beranda, photo first: header, promo carousel, one points line, photo
  /// categories, Flash Sale, Beli lagi, two product shelves and the mix pack.
  /// Section titles are at most three words; no helper paragraphs.
  @override
  Widget build(BuildContext context) {
    final best = [...catalog]..sort((a, b) => a.rank.compareTo(b.rank));
    final bundles = catalog.where((p) => p.category == 'bundle').toList();
    const pad = EdgeInsets.symmetric(horizontal: Sp.l);
    const gap = SizedBox(height: Sp.xl);
    var k = 0;
    Widget sec(Widget w) => FadeSlideIn(index: k++, child: w);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(context),
          sec(
            Column(
              children: [
                SizedBox(
                  height: 60 + MediaQuery.textScalerOf(context).scale(100),
                  child: PageView.builder(
                    controller: page,
                    itemCount: slides.length,
                    onPageChanged: (i) => setState(() => cur = i),
                    itemBuilder: (_, i) => _banner(context, i),
                  ),
                ),
                const SizedBox(height: Sp.s),
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
          const SizedBox(height: Sp.l),
          const Padding(padding: pad, child: PointsChip()),
          gap,
          const CategoryTiles(),
          gap,
          const FlashSale(),
          const ReorderRow(),
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
                shelf(context, 'best', best.take(8).toList()),
              ],
            ),
          ),
          const SizedBox(height: Sp.s),
          sec(
            Column(
              children: [
                const Padding(padding: pad, child: SectionTitle('Paket hemat')),
                shelf(context, 'bundle', bundles),
              ],
            ),
          ),
          const SizedBox(height: Sp.s),
          sec(const Padding(padding: pad, child: MixPackCard())),
          gap,
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
                    child: Text('${res.length} hasil', style: tMuted),
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
          Text(p.size, style: tMuted),
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
          const SizedBox(height: Sp.m),
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
          const SizedBox(height: Sp.l),
          const ListGroup(
            children: [
              ListRow(
                icon: Icons.verified_user_outlined,
                title: 'Garansi Tidak Meleleh',
                subtitle:
                    'Meleleh saat tiba? Lapor dalam 24 jam, kami ganti atau kembalikan dana (contoh).',
              ),
            ],
          ),
          const SizedBox(height: Sp.xl),
          const Text('Deskripsi', style: tH3),
          const SizedBox(height: 4),
          Text(
            p.chilled
                ? '${p.name}, ${p.size}. Simpan di kulkas 2-6°C dan habiskan sebelum tanggal kedaluwarsa.'
                : '${p.name}, ${p.size}. Simpan di freezer -18°C dan jangan dibekukan ulang setelah meleleh.',
            style: const TextStyle(color: C.muted, height: 1.4),
          ),
          const SizedBox(height: Sp.xl),
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
