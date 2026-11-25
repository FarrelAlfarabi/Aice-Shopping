import 'package:aice_shopping/accounts.dart';
import 'package:aice_shopping/admin.dart';
import 'package:aice_shopping/assistant.dart';
import 'package:aice_shopping/consumer_extras.dart';
import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/i18n.dart';
import 'package:aice_shopping/screens_a.dart';
import 'package:aice_shopping/screens_b.dart';
import 'package:aice_shopping/screens_c.dart';
import 'package:aice_shopping/state.dart';
import 'package:aice_shopping/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Texts that are data, not interface words: they stay as they are in every
/// language (product names, sample people, addresses).
Set<String> dataStrings() => {
      for (final p in allProducts) p.name,
      for (final p in allProducts) p.size,
      for (final c in demoAccounts) c.name,
      for (final c in demoAccounts) c.phone,
      ...savedAddresses,
      'Aice Shopping',
    };

/// Opens every screen of the app (consumer and admin) in [lang] at [width] and
/// returns the texts that had no translation. Also fails on layout overflow.
Future<(Set<String>, List<String>)> walk(WidgetTester tester, String lang,
    {double width = 360, double scale = 1.0}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final st = AppState();
  st.setLang(lang);
  trackMisses = true;
  misses.clear();
  await tester.pumpWidget(MediaQuery(
    data: MediaQueryData(
        size: Size(width, 800), textScaler: TextScaler.linear(scale)),
    child: AiceApp(state: st),
  ));
  final problems = <String>[];
  var where = 'start';
  final oldHandler = FlutterError.onError;
  FlutterError.onError = (d) {
    final where2 = RegExp(r'lib/[a-z_]+\.dart:\d+').firstMatch(d.toString());
    problems.add(
        '$where: ${d.exceptionAsString().split('\n').first} @ ${where2?.group(0)}');
  };
  void check() {}

  Future<void> settle() async {
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    check();
  }

  BuildContext ctx() => tester.element(find.byType(Navigator).first);
  Future<void> push(Widget w) async {
    Navigator.of(ctx()).push(MaterialPageRoute(builder: (_) => w));
    await settle();
  }

  Future<void> back() async {
    Navigator.of(ctx()).pop();
    await settle();
  }

  await settle(); // intro
  st.finishIntro();
  await settle();
  where = 'home';
  for (var i = 0; i < 14; i++) {
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await settle();
  // Product pages: ice cream, chilled yogurt, frozen food, bundle.
  for (final id in ['cone-vanila', 'cup-original', 'frozen-naget', 'bundle-keluarga', 'cone-stroberi']) {
    where = 'ProductScreen(productById(id)))';
  await push(ProductScreen(productById(id)));
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await settle();
    await back();
  }
  where = 'const SearchScreen())';
  await push(const SearchScreen());
  await back();
  where = 'const SearchScreen(category: frozen))';
  await push(const SearchScreen(category: 'frozen'));
  await back();
  where = 'const MixPackScreen())';
  await push(const MixPackScreen());
  await back();
  where = 'const AssistantScreen())';
  await push(const AssistantScreen());
  await back();
  where = 'const AddressScreen())';
  await push(const AddressScreen());
  await back();
  // Sign in sheet, all three tabs.
  showSignIn(ctx());
  await settle();
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.byKey(ValueKey('signin-tab-$i')));
    await settle();
  }
  await tester.tap(find.byKey(const ValueKey('demo-c-jaya')));
  await settle();
  await tester.tap(find.byKey(const ValueKey('signin-tab-0')));
  await settle();
  await tester.tap(find.byKey(const ValueKey('sheet-phone')));
  // Empty form errors.
  await tester.tapAt(const Offset(10, 10)); // dismiss the sheet
  await settle();
  // Cart, checkout, order, waiting view, order detail.
  st.signIn(demoAccounts[0]);
  st.add(productById('cone-vanila'), 4);
  st.add(productById('stik-cokelat'), 6);
  st.add(productById('cup-original'), 4);
  st.addMixPack(6, {productById('cone-vanila'): 6});
  for (final i in [1, 2, 3, 0]) {
    tabIndex.value = i;
    await settle();
  }
  tabIndex.value = 1;
  await settle();
  where = 'const CheckoutScreen())';
  await push(const CheckoutScreen());
  st.setPayment('Transfer bank');
  await settle();
  final o = st.placeOrder();
  await back();
  where = 'OrderPlacedScreen(o))';
  await push(OrderPlacedScreen(o));
  await back();
  where = 'TrackingScreen(o))';
  await push(TrackingScreen(o));
  await back();
  where = 'OrderDetailScreen(o))';
  await push(OrderDetailScreen(o));
  await back();
  st.confirmTransfer(o);
  where = 'TrackingScreen(o))';
  await push(TrackingScreen(o));
  await back();
  st.startDelivery(o);
  where = 'TrackingScreen(o))';
  await push(TrackingScreen(o));
  await tester.pump(const Duration(seconds: 20));
  await back();
  where = 'ReportScreen(o))';
  await push(ReportScreen(o));
  await back();
  where = 'OrderDetailScreen(st.allOrders.firstWhere((x)  x.s';
  await push(OrderDetailScreen(st.allOrders.firstWhere((x) => x.sample)));
  await back();
  where = 'const NoticesScreen())';
  await push(const NoticesScreen());
  await back();
  where = 'const AboutDemoScreen())';
  await push(const AboutDemoScreen());
  await back();
  tabIndex.value = 0;
  await settle();
  where = 'admin';
  st.setRole(AppRole.admin);
  await settle();
  for (var i = 0; i < 8; i++) {
    where = 'admin tab $i';
    final sc = tester.state<ScrollableState>(find
        .descendant(of: find.byType(AdminShell), matching: find.byType(Scrollable))
        .first);
    sc.position.jumpTo(0);
    await tester.pump();
    for (var k = 0;
        k < 20 && find.byKey(ValueKey('admin-tab-$i')).evaluate().isEmpty;
        k++) {
      sc.position.jumpTo(sc.position.pixels + 100);
      await tester.pump();
    }
    expect(find.byKey(ValueKey('admin-tab-$i')), findsOneWidget);
    await tester.ensureVisible(find.byKey(ValueKey('admin-tab-$i')));
    await tester.tap(find.byKey(ValueKey('admin-tab-$i')));
    await settle();
  }
  final out = {...misses}..removeAll(dataStrings());
  trackMisses = false;
  st.setLang('id');
  st.setRole(AppRole.consumer);
  tabIndex.value = 0;
  FlutterError.onError = oldHandler;
  return (out, problems);
}
