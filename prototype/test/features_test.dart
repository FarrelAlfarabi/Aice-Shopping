import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/pricing.dart';
import 'package:aice_shopping/screens_a.dart';
import 'package:aice_shopping/screens_b.dart';
import 'package:aice_shopping/screens_c.dart';
import 'package:aice_shopping/state.dart';
import 'package:aice_shopping/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Features added without a database: mix pack, order detail and reorder,
/// notifications, saved addresses, about screen. All state is on the device.
void main() {
  setUpAll(() => loopMotion = false);

  Future<AppState> open(
    WidgetTester tester,
    Widget home, {
    AppState? state,
    double scale = 1.0,
  }) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final st = state ?? (AppState()..finishIntro());
    await tester.pumpWidget(
      AppScope(
        state: st,
        child: MaterialApp(
          theme: buildTheme(),
          builder: (c, child) => MediaQuery(
            data: MediaQuery.of(
              c,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return st;
  }

  group('mix pack logic', () {
    test('sizes and set prices live in Pricing config', () {
      expect(mixPackPrices.keys, [6, 8, 12]);
      for (final e in mixPackPrices.entries) {
        expect(e.value, greaterThan(0));
      }
    });

    test('choices are cones and sticks that are not sold out', () {
      expect(mixChoices, isNotEmpty);
      for (final p in mixChoices) {
        expect(['cone', 'stick'], contains(p.category));
        expect(p.soldOut, isFalse);
      }
    });

    test('a full mix pack goes in the cart at the set price', () {
      final s = AppState();
      final p = s.addMixPack(6, {
        productById('cone-vanila'): 4,
        productById('stik-cokelat'): 2,
      });
      expect(p.price, mixPackPrices[6]);
      expect(s.itemCount, 1);
      expect(s.pricing.subtotal, mixPackPrices[6]);
      // The mix pack is not a cone, so the Beli 3 discount does not apply.
      expect(s.pricing.multiBuy, 0);
      expect(p.size, contains('4 Cone Vanila Stroberi'));
    });

    test('a pack that is not full is refused', () {
      final s = AppState();
      expect(
        () => s.addMixPack(6, {productById('cone-vanila'): 5}),
        throwsArgumentError,
      );
      expect(
        () => s.addMixPack(7, {productById('cone-vanila'): 7}),
        throwsArgumentError,
      );
      expect(s.cartEmpty, isTrue);
    });

    test('two mix packs stay separate and the order keeps the flavours', () {
      final s = AppState();
      s.addMixPack(6, {productById('cone-vanila'): 6});
      s.addMixPack(6, {productById('cone-taro'): 6});
      expect(s.lines.length, 2);
      final o = s.placeOrder();
      expect(o.lines.length, 2);
      expect(
        o.lines.every((l) => l.productId == null && l.detail != null),
        isTrue,
      );
      expect(s.cartEmpty, isTrue);
    });
  });

  testWidgets('mix pack screen: button stays off until the pack is full', (
    tester,
  ) async {
    final st = await open(tester, const MixPackScreen());
    expect(find.text('Pilih 6 lagi (0 dari 6)'), findsOneWidget);
    final btn = find.widgetWithText(FilledButton, 'Tambah ke keranjang');
    expect(tester.widget<FilledButton>(btn).onPressed, isNull);
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byTooltip('Tambah').first);
      await tester.pump();
    }
    expect(find.text('Paket penuh. Siap masuk keranjang.'), findsOneWidget);
    // Cannot go over the size.
    await tester.tap(find.byTooltip('Tambah').first);
    await tester.pump();
    expect(find.text('Paket penuh. Siap masuk keranjang.'), findsOneWidget);
    expect(tester.widget<FilledButton>(btn).onPressed, isNotNull);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(st.itemCount, 1);
    expect(st.lines.keys.single.name, 'Paket Mix 6');
  });

  testWidgets('mix pack screen fits 360 px at large text', (tester) async {
    await open(tester, const MixPackScreen(), scale: 1.3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home shows the mix pack card and it opens the builder', (
    tester,
  ) async {
    await open(tester, const Scaffold(body: HomeTab()));
    await tester.scrollUntilVisible(
      find.byType(MixPackCard),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byType(MixPackCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MixPackCard));
    await tester.pumpAndSettle();
    expect(find.byType(MixPackScreen), findsOneWidget);
  });

  group('reorder', () {
    test('puts past items back in the cart', () {
      final s = AppState();
      final sample = s.history.single;
      expect(sample.lines.single.productId, 'cone-vanila');
      final skipped = s.reorder(sample);
      expect(skipped, 0);
      expect(s.qtyOf('cone-vanila'), 3);
    });

    test('mix packs are skipped and counted', () {
      final s = AppState();
      s.addMixPack(6, {productById('cone-vanila'): 6});
      final o = s.placeOrder();
      expect(s.reorder(o), 1);
      expect(s.cartEmpty, isTrue);
    });
  });

  testWidgets('order detail shows lines and Pesan lagi fills the cart', (
    tester,
  ) async {
    final st = AppState()..finishIntro();
    await open(tester, const Shell(), state: st);
    tabIndex.value = 2;
    await tester.pumpAndSettle();
    await tester.tap(find.text('#AC-0987'));
    await tester.pumpAndSettle();
    expect(find.byType(OrderDetailScreen), findsOneWidget);
    expect(find.text('3 x Cone Vanila Stroberi'), findsOneWidget);
    expect(find.text('Lacak pesanan'), findsNothing); // old order
    await tester.tap(find.text('Pesan lagi'));
    await tester.pumpAndSettle();
    expect(st.qtyOf('cone-vanila'), 3);
    expect(tabIndex.value, 1);
    tabIndex.value = 0;
  });

  group('notifications and addresses', () {
    test('unread count, mark one, mark all, new order adds one', () {
      final s = AppState();
      expect(s.unreadCount, 2);
      s.markNoticeRead(s.notices.first);
      expect(s.unreadCount, 1);
      s.markAllRead();
      expect(s.unreadCount, 0);
      s.add(productById('cone-vanila'), 4);
      s.placeOrder();
      expect(s.unreadCount, 1);
      expect(s.notices.first.text, contains('#AC-1001'));
    });

    test('add and remove saved address, no blanks or duplicates', () {
      final s = AppState();
      final n = s.saved.length;
      s.addAddress('  ');
      s.addAddress(s.saved.first);
      expect(s.saved.length, n);
      s.addAddress('Jl. Baru Contoh No. 1');
      expect(s.saved.length, n + 1);
      s.removeAddress('Jl. Baru Contoh No. 1');
      expect(s.saved.length, n);
      // The fixed sample list is never changed.
      expect(savedAddresses.length, n);
    });

    test('reset demo restores addresses, notices and mix packs', () {
      final s = AppState();
      s.addAddress('Jl. Baru Contoh No. 1');
      s.markAllRead();
      s.addMixPack(6, {productById('cone-vanila'): 6});
      s.resetDemo();
      expect(s.saved, savedAddresses);
      expect(s.unreadCount, 2);
      expect(s.cartEmpty, isTrue);
    });
  });

  testWidgets('profile: add an address, open notifications and about', (
    tester,
  ) async {
    final st = AppState()..finishIntro();
    await open(tester, const Scaffold(body: ProfileTab()), state: st);
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Jl. Tes Contoh 9');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(st.saved, contains('Jl. Tes Contoh 9'));
    await tester.scrollUntilVisible(
      find.text('Jl. Tes Contoh 9'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Jl. Tes Contoh 9'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Hapus alamat').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hapus alamat').last);
    await tester.pumpAndSettle();
    expect(st.saved, isNot(contains('Jl. Tes Contoh 9')));

    await tester.scrollUntilVisible(
      find.widgetWithText(InkWell, 'Notifikasi'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(InkWell, 'Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.byType(NoticesScreen), findsOneWidget);
    await tester.tap(find.text('Tandai semua dibaca'));
    await tester.pumpAndSettle();
    expect(st.unreadCount, 0);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(InkWell, 'Tentang demo ini'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Tentang demo ini'));
    await tester.pumpAndSettle();
    expect(find.text('Yang benar-benar jalan'), findsOneWidget);
    expect(find.text('Yang hanya contoh'), findsOneWidget);
  });
}
