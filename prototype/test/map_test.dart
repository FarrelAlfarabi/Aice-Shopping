import 'package:aice_shopping/data.dart';
import 'package:aice_shopping/i18n.dart' as i18n;
import 'package:aice_shopping/map_picker.dart';
import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/places.dart';
import 'package:aice_shopping/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The DEMO map address picker: search, drag, zoom, "Lokasi saya" and save.
void main() {
  setUpAll(() => loopMotion = false);

  Future<AppState> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final st = AppState();
    await tester.pumpWidget(
      AppScope(
        state: st,
        child: MaterialApp(
          home: Builder(
            builder: (c) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => openMapPicker(c),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return st;
  }

  String street(WidgetTester tester) =>
      tester.widget<i18n.Text>(find.byKey(const ValueKey('map-street'))).data;

  test('search finds places by name or area, and nothing for nonsense', () {
    expect(searchPlaces('sejahtera').first.name, 'Es Krim Sejahtera');
    expect(
      searchPlaces('palmerah').map((p) => p.name),
      contains('Stasiun Palmerah'),
    );
    expect(searchPlaces('jl kedoya').first.name, 'Jl. Kedoya Raya');
    expect(searchPlaces('zzz'), isEmpty);
    expect(searchPlaces('  '), isEmpty);
  });

  test('reverse geocode gives a street, kecamatan and postal code', () {
    final a = reverseGeocode(myLocation);
    expect(a.street, startsWith('Jl. Kemanggisan Utama No. '));
    expect(a.area, 'Palmerah, Jakarta Barat 11480');
    final far = reverseGeocode(const Offset(3.6, 6.0));
    expect(far.street, startsWith('Dekat '));
  });

  test('nearest store and delivery time follow the pin', () {
    final (s1, km1) = nearestStore(storePos['Toko Beku Makmur']!);
    expect(s1.name, 'Toko Beku Makmur');
    expect(km1, lessThan(0.1));
    final (s2, km2) = nearestStore(const Offset(3.5, 2.0));
    expect(s2.name, 'Es Krim Sejahtera');
    expect(km2, greaterThan(0));
    expect(etaMinutes(0), 10);
    expect(etaMinutes(2.4), 20);
    expect(kmText(1.25), '1,3 km');
  });

  testWidgets('suggestion moves the map, then saving fills address and store', (
    tester,
  ) async {
    final st = await open(tester);
    final before = street(tester);

    await tester.enterText(find.byKey(const ValueKey('map-search')), 'arjuna');
    await tester.pump();
    expect(find.byKey(const ValueKey('map-hit-0')), findsOneWidget);
    expect(find.text('Kantor Arjuna Selatan No. 9'), findsOneWidget);

    await tester.tap(find.text('Kantor Arjuna Selatan No. 9'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('map-hit-0')), findsNothing);
    expect(street(tester), isNot(before));
    expect(street(tester), startsWith('Jl. Arjuna Selatan No. '));
    expect(find.textContaining('Es Krim Sejahtera'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('map-use')));
    await tester.pumpAndSettle();
    expect(st.address, startsWith('Jl. Arjuna Selatan No. '));
    expect(st.address, endsWith('Kebon Jeruk, Jakarta Barat 11530'));
    expect(st.saved, contains(st.address));
    expect(st.store.name, 'Es Krim Sejahtera');
    expect(st.distanceKm, isNotNull);
    expect(st.storeDistance, endsWith(' km'));
  });

  testWidgets('dragging the map changes the address; Lokasi saya returns', (
    tester,
  ) async {
    await open(tester);
    final home = street(tester);
    await tester.drag(
      find.byKey(const ValueKey('map-canvas')),
      const Offset(-200, 120),
    );
    await tester.pumpAndSettle();
    expect(street(tester), isNot(home));

    await tester.tap(find.byKey(const ValueKey('map-my-location')));
    await tester.pumpAndSettle();
    expect(street(tester), home);
  });

  testWidgets('zoom buttons work and far away pins cannot be saved', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byKey(const ValueKey('map-zoom-in')));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const ValueKey('map-zoom-out')));
      await tester.pumpAndSettle();
    }
    // Drag to the far bottom-left corner, outside every store's area.
    await tester.drag(
      find.byKey(const ValueKey('map-canvas')),
      const Offset(600, -600),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Di luar area antar. Geser pin lebih dekat ke toko.'),
      findsOneWidget,
    );
    final btn = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey('map-use')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(btn.onPressed, isNull);
  });

  test('stores on the map match the store list', () {
    for (final s in stores) {
      expect(storePos.containsKey(s.name), isTrue, reason: s.name);
    }
  });
}
