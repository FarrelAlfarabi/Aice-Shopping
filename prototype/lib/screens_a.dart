import 'dart:async';
import 'package:flutter/material.dart';
import 'data.dart';
import 'format.dart';
import 'intro.dart';
import 'screens_b.dart';
import 'state.dart';
import 'ui.dart';

/// Which bottom tab is showing: 0 Beranda, 1 Keranjang, 2 Pesanan, 3 Profil.
final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

/// Snackbar after an add-to-cart, with a button that opens the cart tab.
void addedToCart(BuildContext context, String msg) {
  final nav = Navigator.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Lihat keranjang',
        textColor: C.acc,
        onPressed: () {
          nav.popUntil((r) => r.isFirst);
          tabIndex.value = 1;
        },
      ),
    ));
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool loaded = false;
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => loaded = true);
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    if (!loaded) return const Splash();
    if (!s.introSeen) return const IntroScreen();
    return const Shell();
  }
}

class Splash extends StatelessWidget {
  const Splash({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.pri,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.icecream, size: 72, color: Colors.white),
            const SizedBox(height: 12),
            const Text('Es krim, tetap beku.',
                style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: Colors.white)),
            const SizedBox(height: 24),
            Text(footerText,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
          ]),
        ),
      );
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
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Alamat pengiriman', style: tH3),
              const SizedBox(height: 8),
              TextField(
                controller: ctl,
                onChanged: s.setAddress,
                decoration: const InputDecoration(
                    hintText: 'Tulis alamat', prefixIcon: Icon(Icons.place_outlined)),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final a in savedAddresses)
                  SmallChip(a.split(',').first, onTap: () {
                    ctl.text = a;
                    s.setAddress(a);
                  }),
              ]),
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
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: BigButton('Simpan',
                onPressed: s.hasAddress ? () => Navigator.of(context).pop(true) : null),
          ),
        ]),
      ),
    );
  }
}

/// Opens the address and store picker. Returns true when the person saved.
Future<bool> openAddress(BuildContext context) async {
  final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddressScreen()));
  return ok ?? false;
}

class Shell extends StatelessWidget {
  const Shell({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, i, _) => Scaffold(
        body: IndexedStack(index: i, children: const [
          HomeTab(),
          CartTab(),
          OrdersTab(),
          ProfileTab(),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          backgroundColor: C.surface,
          indicatorColor: C.tint,
          onDestinationSelected: (v) => tabIndex.value = v,
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Beranda'),
            NavigationDestination(
                icon: Badge(
                    isLabelVisible: s.itemCount > 0,
                    label: Text('${s.itemCount}'),
                    child: const Icon(Icons.shopping_cart_outlined)),
                selectedIcon: const Icon(Icons.shopping_cart),
                label: 'Keranjang'),
            const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Pesanan'),
            const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

void openProduct(BuildContext context, Product p) => Navigator.of(context)
    .push(MaterialPageRoute(builder: (_) => ProductScreen(p)));

void openSearch(BuildContext context, {String query = '', String? category}) =>
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SearchScreen(query: query, category: category)));

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final page = PageController(viewportFraction: 0.88);
  int cur = 0;
  Timer? auto;

  static const slides = <(String, String, Color)>[
    ('Beli 3 Diskon 10% untuk semua cone', 'cone', C.pri),
    ('Paket Pesta: hemat sampai Rp15.000 (contoh)', 'bundle', C.priDark),
    ('Gratis ongkir di atas Rp50.000', 'tub', Color(0xFF0E7C86)),
  ];

  @override
  void initState() {
    super.initState();
    auto = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !page.hasClients) return;
      page.animateToPage((cur + 1) % slides.length,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    auto?.cancel();
    page.dispose();
    super.dispose();
  }

  Widget shelf(BuildContext context, List<Product> items) {
    final s = AppScope.of(context);
    return SizedBox(
      height: 262,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ProductCard(
          p: items[i],
          width: 150,
          onTap: () => openProduct(context, items[i]),
          onAdd: () {
            s.add(items[i]);
            addedToCart(context, '${items[i].name} ditambahkan');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final best = [...catalog]..sort((a, b) => a.rank.compareTo(b.rank));
    final cones = catalog.where((p) => p.multiBuy).toList();
    final bundles = catalog.where((p) => p.category == 'bundle').toList();
    return SafeArea(
      bottom: false,
      child: ListView(padding: EdgeInsets.zero, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(
            color: C.pri,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // Long press the wordmark to open the hidden demo controls.
              Flexible(
                child: GestureDetector(
                onLongPress: () => showDemoControls(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('es krim shop (contoh)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                ),
              ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: C.acc, borderRadius: BorderRadius.circular(99)),
                child: Text(s.store.name,
                    style: const TextStyle(
                        color: C.accInk, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ]),
            InkWell(
              key: const ValueKey('address-bar'),
              onTap: () => openAddress(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  const Icon(Icons.place, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(s.hasAddress ? s.address : 'Atur alamat pengiriman',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                s.hasAddress ? FontWeight.w400 : FontWeight.w800,
                            decoration: s.hasAddress
                                ? null
                                : TextDecoration.underline,
                            decorationColor: Colors.white)),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white70, size: 20),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Tiba dalam 15 Menit',
                style: TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            const Text('Waktu contoh, bukan janji Aice',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => openSearch(context),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Row(children: [
                  Icon(Icons.search, color: C.muted),
                  SizedBox(width: 8),
                  Text('Cari es krim favoritmu',
                      style: TextStyle(color: C.muted)),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final q in popularSearches)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: const StadiumBorder(
                          side: BorderSide(color: Colors.white54)),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: () => openSearch(context, query: q),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(q,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 118,
          child: PageView.builder(
            controller: page,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => cur = i),
            itemBuilder: (_, i) {
              final sl = slides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: sl.$3, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Ribbon('Contoh'),
                            const SizedBox(height: 6),
                            Text(sl.$1,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    height: 1.2)),
                          ]),
                    ),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 3))),
                      child: CategoryPhoto(sl.$2, size: 72, circle: true),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < slides.length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == cur ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                  color: i == cur ? C.pri : C.line,
                  borderRadius: BorderRadius.circular(99)),
            ),
        ]),
        const SizedBox(height: 14),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle('Koleksi pilihan')),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: SizedBox(
            height: 164,
            child: Row(children: [
              Expanded(
                  flex: 6,
                  child: _tile('Paket Pesta', 'bundle', const Color(0xFFFFE6A8),
                      () => openSearch(context, category: 'bundle'),
                      big: true, file: 'bundle-keluarga.jpg')),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: Column(children: [
                  Expanded(
                      child: _tile('Cemilan Anak', 'stick', const Color(0xFFD8ECFF),
                          () => openSearch(context, category: 'stick'),
                          file: 'cone-cokelat.jpg')),
                  const SizedBox(height: 10),
                  Expanded(
                      child: _tile('Hemat Berdua', 'cup', const Color(0xFFDDF5E9),
                          () => openSearch(context, category: 'cup'),
                          file: 'cone-matcha.jpg')),
                ]),
              ),
            ]),
          ),
        ),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle('Kategori')),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: [
              for (final e in categories.entries)
                Material(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => openSearch(context, category: e.key),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: C.line)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CategoryPhoto(e.key, size: 52),
                            const SizedBox(height: 6),
                            Text(e.value,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12)),
                          ]),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle('Terlaris',
                action: 'Lihat semua', onAction: () => openSearch(context))),
        shelf(context, best.take(6).toList()),
        const SizedBox(height: 14),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle('Beli 3 Diskon 10% (cone)')),
        shelf(context, cones),
        const SizedBox(height: 14),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle('Paket hemat')),
        shelf(context, bundles),
        const SizedBox(height: 18),
        const Center(child: Text(footerText, style: tMuted)),
        const SizedBox(height: 18),
      ]),
    );
  }

  Widget _tile(String t, String cat, Color bg, VoidCallback onTap,
          {bool big = false, String? file}) =>
      Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(children: [
              Padding(
                padding: EdgeInsets.only(right: big ? 0 : 52),
                child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: CategoryPhoto(cat, size: big ? 84 : 48, file: file)),
            ]),
          ),
        ),
      );
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
      final hay =
          '${p.name} ${categories[p.category]} ${p.size}'.toLowerCase();
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
            hintText: 'Cari es krim favoritmu',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: q.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Hapus',
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                          ctl.clear();
                          q = '';
                        })),
          ),
        ),
        actions: const [SizedBox(width: 12)],
      ),
      body: empty
          ? ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Pencarian populer', style: tH3),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in [...popularSearches, 'es krim anak'])
                  SmallChip(p, onTap: () {
                    ctl.text = p;
                    setState(() => q = p);
                  }),
              ]),
              const SizedBox(height: 18),
              const Text('Kategori', style: tH3),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final e in categories.entries)
                  SmallChip(e.value, onTap: () => setState(() => cat = e.key)),
              ]),
              const SizedBox(height: 18),
              const Text('Ketik untuk melihat hasil langsung.', style: tMuted),
            ])
          : Column(children: [
              SizedBox(
                height: 48,
                child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final o in ['Terlaris', 'Termurah', 'Termahal'])
                        Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SmallChip(o,
                                on: sort == o,
                                onTap: () => setState(() => sort = o))),
                      Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SmallChip('Semua tipe',
                              on: cat == null,
                              onTap: () => setState(() => cat = null))),
                      for (final e in categories.entries)
                        Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SmallChip(e.value,
                                on: cat == e.key,
                                onTap: () => setState(() => cat = e.key))),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${res.length} hasil (contoh)', style: tMuted)),
              ),
              Expanded(
                child: res.isEmpty
                    ? ListView(padding: const EdgeInsets.all(24), children: [
                        const Icon(Icons.search_off, size: 48, color: C.muted),
                        const SizedBox(height: 8),
                        Text('Tidak ada hasil untuk "$q"',
                            textAlign: TextAlign.center, style: tH3),
                        const SizedBox(height: 4),
                        const Text('Coba kata lain atau pilih pencarian populer.',
                            textAlign: TextAlign.center, style: tMuted),
                        const SizedBox(height: 14),
                        Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final p in popularSearches)
                                SmallChip(p, onTap: () {
                                  ctl.text = p;
                                  setState(() {
                                    q = p;
                                    cat = null;
                                  });
                                }),
                            ]),
                      ])
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 262),
                        itemCount: res.length,
                        itemBuilder: (_, i) => ProductCard(
                          p: res[i],
                          onTap: () => openProduct(context, res[i]),
                          onAdd: () {
                            s.add(res[i]);
                            addedToCart(context, '${res[i].name} ditambahkan');
                          },
                        ),
                      ),
              ),
            ]),
    );
  }
}

class ProductScreen extends StatefulWidget {
  final Product p;
  const ProductScreen(this.p, {super.key});
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
      body: ListView(padding: const EdgeInsets.all(16), children: [
        AspectRatio(
          aspectRatio: 1.15,
          child: Stack(children: [
            PageView.builder(
              itemCount: 3,
              onPageChanged: (i) => setState(() => shot = i),
              itemBuilder: (_, i) => ProductImage(p, radius: 20),
            ),
            if (p.ribbon != null)
              Positioned(
                  top: 12, left: 12, child: Ribbon(p.ribbon!, sold: p.soldOut)),
          ]),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < 3; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == shot ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                  color: i == shot ? C.pri : C.line,
                  borderRadius: BorderRadius.circular(99)),
            ),
        ]),
        const SizedBox(height: 12),
        Text(p.name, style: tH2),
        Text('${p.size} · Contoh produk', style: tMuted),
        const SizedBox(height: 8),
        Row(children: [
          PriceRow(p, size: 22),
          const SizedBox(width: 8),
          if (p.percentOff != null) Ribbon('-${p.percentOff}%'),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: const [
          _Badge('Halal [no. contoh]'),
          _Badge('BPOM [no. contoh]'),
          _Badge('Simpan -18°C'),
        ]),
        if (hasPacks && !p.soldOut) ...[
          const SizedBox(height: 14),
          const Text('Pilih isi', style: tH3),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final k in [1, 6, 12])
              SmallChip(k == 1 ? 'Satuan' : 'Isi $k',
                  on: pack == k, onTap: () => setState(() => pack = k)),
          ]),
        ],
        if (p.multiBuy) ...[
          const SizedBox(height: 14),
          Notice(inCart + units >= 3
              ? 'Beli 3 Diskon 10% aktif untuk cone di keranjang.'
              : 'Beli 3 Diskon 10%. Tambah ${3 - inCart - units} lagi untuk dapat diskon.'),
        ],
        const SizedBox(height: 14),
        Panel(
          color: C.tint,
          child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Garansi Tidak Meleleh', style: tBold),
                SizedBox(height: 2),
                Text('Meleleh saat tiba? Lapor dalam 24 jam, kami ganti atau kembalikan dana (contoh).',
                    style: tMuted),
              ]),
        ),
        const SizedBox(height: 14),
        const Text('Deskripsi', style: tH3),
        const SizedBox(height: 4),
        Text(
            '${p.name}, ${p.size}. Contoh deskripsi untuk demo. Simpan di freezer -18°C dan jangan dibekukan ulang setelah meleleh.',
            style: const TextStyle(color: C.muted, height: 1.4)),
        const SizedBox(height: 18),
        const Text('Produk Serupa', style: tH3),
        const SizedBox(height: 8),
        SizedBox(
          height: 262,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: similar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => ProductCard(
              p: similar[i],
              width: 150,
              onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ProductScreen(similar[i]))),
              onAdd: () {
                s.add(similar[i]);
                addedToCart(context, '${similar[i].name} ditambahkan');
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: Text(footerText, style: tMuted)),
      ]),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
              color: C.surface, border: Border(top: BorderSide(color: C.line))),
          child: p.soldOut
              ? const BigButton('Habis', onPressed: null)
              : Row(children: [
                  QtyStepper(
                      qty: n,
                      onMinus: () => setState(() => n = n > 1 ? n - 1 : 1),
                      onPlus: () => setState(() => n++)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BigButton('Tambah',
                        trailing: rp(p.price * units),
                        onPressed: () {
                      s.add(p, units);
                      addedToCart(context, '$units ${p.name} ditambahkan');
                    }),
                  ),
                ]),
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
            border: Border.all(color: C.line)),
        child: Text(t,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
      );
}
