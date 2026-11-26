// Screenshots of every consumer screen at 360 px, for design reviews.
// Skipped in a normal test run. To make them:
//   SHOTS=1 flutter test test/shots_test.dart --update-goldens
// PNGs land in test/shots/<lang>/ (git-ignored).
import 'dart:io';

import 'package:aice_shopping/accounts.dart';
import 'package:aice_shopping/assistant.dart';
import 'package:aice_shopping/consumer_extras.dart';
import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/main.dart';
import 'package:aice_shopping/membership.dart';
import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/payment_ui.dart';
import 'package:aice_shopping/screens_a.dart';
import 'package:aice_shopping/screens_b.dart';
import 'package:aice_shopping/screens_c.dart';
import 'package:aice_shopping/state.dart';
import 'package:aice_shopping/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _on = Platform.environment['SHOTS'] == '1';

Future<void> _font(String family, List<String> files) async {
  final l = FontLoader(family);
  for (final f in files) {
    l.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await l.load();
}

Future<void> _fonts() async {
  const r = 'assets/fonts';
  await _font('Roboto', [
    '$r/Roboto-Regular.ttf',
    '$r/Roboto-Medium.ttf',
    '$r/Roboto-Bold.ttf',
    '$r/Roboto-Black.ttf',
  ]);
  await _font('ZhSubset', ['$r/ZhSubset.ttf']);
  final sdk = File(Platform.resolvedExecutable).parent.parent.parent.parent;
  await _font('MaterialIcons', [
    '${sdk.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

void main() {
  setUpAll(() async {
    loopMotion = false;
    await _fonts();
  });

  for (final lang in ['id', 'en', 'zh']) {
    testWidgets('shots $lang', skip: !_on, (tester) async {
      const size = Size(360, 1400);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final st = AppState()..setLang(lang);
      await tester.pumpWidget(AiceApp(state: st));
      await tester.runAsync(() async {
        final ctx = tester.element(find.byType(Navigator).first);
        await precachePhotos(ctx);
      });
      Future<void> settle() async {
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
      }

      Future<void> shot(String name) async {
        await settle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('shots/$lang/$name.png'),
        );
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

      await shot('00-intro');
      st.finishIntro();
      await shot('01-home');
      await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
      await shot('02-home-scrolled');
      await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
      await shot('03-home-bottom');
      tabIndex.value = 3;
      await shot('10-profil-guest');
      await push(ProductScreen(productById('cone-vanila')));
      await shot('20-product');
      await back();
      await push(ProductScreen(productById('cup-original')));
      await shot('21-product-yogurt');
      await back();
      await push(const SearchScreen(category: 'frozen'));
      await shot('22-search');
      await back();
      await push(const AddressScreen());
      await shot('23-address-store');
      await back();
      await push(const MixPackScreen());
      await shot('24-mixpack');
      await back();
      await push(const AssistantScreen());
      await shot('25-assistant');
      await back();
      await push(const NoticesScreen());
      await shot('26-notices');
      await back();
      await push(const AboutDemoScreen());
      await shot('27-about');
      await back();
      showSignIn(ctx());
      await shot('28-signin');
      await tester.tapAt(const Offset(10, 300));
      await settle();
      showPaymentPicker(ctx());
      await shot('29-payment');
      await tester.tapAt(const Offset(10, 300));
      await settle();
      st.signIn(demoAccounts[0]);
      st.add(productById('cone-vanila'), 2);
      st.add(productById('stik-cokelat'), 3);
      st.add(productById('cup-original'), 1);
      await shot('11-profil-member');
      await push(const MemberScreen());
      await shot('12-member');
      await back();
      tabIndex.value = 1;
      await shot('30-cart');
      await push(const CheckoutScreen());
      await shot('31-checkout');
      st.setPayment('Transfer bank');
      final o = st.placeOrder();
      await back();
      await push(OrderPlacedScreen(o));
      await shot('32-order-placed');
      await back();
      await push(TrackingScreen(o));
      await shot('33-tracking');
      await back();
      await push(OrderDetailScreen(o));
      await shot('34-order-detail');
      await back();
      tabIndex.value = 2;
      await shot('35-orders');
      tabIndex.value = 0;
      await settle();
      await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
      await shot('04-home-member');
    });
  }
}
