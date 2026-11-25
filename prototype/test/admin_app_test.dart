import 'package:aice_shopping/admin.dart';
import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppState> open(WidgetTester t, Size size) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final st = AppState()..finishIntro();
  st.setRole(AppRole.admin);
  await t.pumpWidget(
    AppScope(
      state: st,
      child: const MaterialApp(home: AdminShell()),
    ),
  );
  await t.pump();
  return st;
}

void main() {
  setUpAll(() => loopMotion = false);

  test('admin tabs have their own addresses', () {
    expect(adminPaths.length, 8);
    expect(adminTabFromAddress('/admin'), 0);
    expect(adminTabFromAddress('/admin/stok'), 3);
    expect(adminTabFromAddress('/nope'), 0);
  });

  testWidgets('laptop width: side menu, no tab chips', (t) async {
    await open(t, const Size(1100, 900));
    expect(find.byKey(const ValueKey('admin-side-menu')), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('admin-tab-3')));
    await t.pump();
    expect(find.text('Masa simpan 28 hari (contoh)'), findsWidgets);
    await t.tap(find.byKey(const ValueKey('admin-tab-4')));
    await t.pump();
    expect(find.byKey(const ValueKey('unpaid-panel')), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('admin-tab-6')));
    await t.pump();
    expect(find.byKey(const ValueKey('members-by-tier')), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('phone width: tab chips, order detail opens', (t) async {
    final st = await open(t, const Size(360, 2600));
    expect(find.byKey(const ValueKey('admin-side-menu')), findsNothing);
    await t.tap(find.byKey(const ValueKey('admin-tab-1')));
    await t.pump();
    final o = st.allOrders.first;
    await t.tap(find.byKey(ValueKey('detail-${o.id}')));
    await t.pumpAndSettle();
    expect(find.text('Total'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
