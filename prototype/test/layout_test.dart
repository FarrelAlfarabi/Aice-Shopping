import 'package:aice_shopping/motion.dart';
import 'package:aice_shopping/screens_a.dart';
import 'package:aice_shopping/state.dart';
import 'package:aice_shopping/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'walk.dart';

/// Home and search must not overflow on a small phone (360 px) with large text.
void main() {
  setUpAll(() => loopMotion = false);

  for (final scale in [1.0, 1.3]) {
    testWidgets('home and search fit at 360 px, text x$scale', (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final st = AppState()..finishIntro();
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
            home: const Shell(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 12; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      Navigator.of(tester.element(find.byType(Shell))).push(
        MaterialPageRoute(
          builder: (_) => const SearchScreen(category: 'bundle'),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  // Design rules (docs/design-rules.md): walks every consumer screen in
  // Indonesian and fails on a bordered card inside another bordered card or
  // on an overflow. English and Chinese run the same check in lang_test.
  testWidgets('no card inside a card on any consumer screen (id)', (
    tester,
  ) async {
    final (_, problems) = await walk(tester, 'id');
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
