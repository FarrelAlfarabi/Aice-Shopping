import 'package:aice_shopping/admin.dart';
import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => loopMotion = false);

  testWidgets('admin Ringkasan shows the 7 day sales panel (sample)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final st = AppState()..finishIntro();
    st.setRole(AppRole.admin);
    await tester.pumpWidget(
      AppScope(
        state: st,
        child: const MaterialApp(home: AdminShell()),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('sales-7')), findsOneWidget);
    expect(find.textContaining('7 hari'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
