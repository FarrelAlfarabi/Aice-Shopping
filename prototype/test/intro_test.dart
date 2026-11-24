import 'package:aice_shopping/intro.dart';
import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/logo.dart';
import 'package:aice_shopping/screens_a.dart';
import 'package:aice_shopping/screens_b.dart';
import 'package:aice_shopping/main.dart';
import 'package:aice_shopping/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('intro shows first, Mulai leads straight to Home', (tester) async {
    await tester.pumpWidget(const AiceApp());
    await tester.pump(const Duration(milliseconds: 1200)); // splash done
    await tester.pump();

    expect(find.byType(IntroScreen), findsOneWidget);
    expect(find.text('Es krim, tetap beku.'), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);
    expect(find.text('Tiba dalam 15 Menit'), findsNothing);

    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.byType(IntroScreen), findsNothing);
    expect(find.text('Tiba dalam 15 Menit'), findsOneWidget);
    expect(find.text('Atur alamat pengiriman'), findsOneWidget);

    // The address bar opens the picker; saving puts the address on Home.
    await tester.tap(find.byKey(const ValueKey('address-bar')));
    await tester.pumpAndSettle();
    expect(find.text('Alamat dan toko'), findsOneWidget);
    await tester.tap(find.text('Jl. Contoh No. 12'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Jl. Contoh No. 12, Kota Contoh'), findsOneWidget);
  });

  testWidgets('slides can be swiped', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AppScope(state: AppState(), child: const IntroScreen()),
    ));
    expect(find.text(introSlides[0].title), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text(introSlides[1].title), findsOneWidget);
  });

  test('reset demo brings the intro back', () {
    final s = AppState()
      ..finishIntro()
      ..setAddress('Jl. Contoh No. 12, Kota Contoh');
    expect(s.hasAddress, true);
    s.resetDemo();
    expect(s.introSeen, false);
    expect(s.hasAddress, false);
  });

  testWidgets('checkout asks for an address when none is set', (tester) async {
    final st = AppState()..add(productById('tub-stroberi'));
    await tester.pumpWidget(AppScope(
      state: st,
      child: const MaterialApp(home: CheckoutScreen()),
    ));
    expect(find.text('Alamat belum diatur'), findsOneWidget);
    await tester.tap(find.textContaining('Bayar'));
    await tester.pumpAndSettle();
    expect(find.byType(AddressScreen), findsOneWidget);
    expect(find.byType(ProcessingScreen), findsNothing);
  });
}
