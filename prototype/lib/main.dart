import 'package:flutter/material.dart' hide Text;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'i18n.dart';
import 'screens_a.dart';
import 'state.dart';
import 'ui.dart';

void main() => runApp(const AiceApp());

class AiceApp extends StatefulWidget {
  /// [state] lets a test bring its own state.
  final AppState? state;
  const AiceApp({super.key, this.state});
  @override
  State<AiceApp> createState() => _AiceAppState();
}

class _AiceAppState extends State<AiceApp> {
  late final AppState state = widget.state ?? AppState();

  @override
  void initState() {
    super.initState();
    if (widget.state == null) syncTabWithAddress();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: Builder(
      builder: (context) => MaterialApp(
        title: 'Aice Shopping (demo)',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        // Indonesian for built-in text such as the back button tooltip.
        locale: Locale(AppScope.of(context).lang),
        supportedLocales: const [Locale('id'), Locale('en'), Locale('zh')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        // On a laptop the app sits in a centered phone-width frame.
        // The admin gets a wide frame; the consumer app stays phone width.
        // Re-keying on the language rebuilds every screen in the new language.
        builder: (context, child) {
          final s = AppScope.of(context);
          final admin = s.introSeen && s.role == AppRole.admin;
          return ColoredBox(
            color: const Color(0xFFDCE5F2),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: admin ? 1100 : 430),
                child: ClipRect(
                  child: KeyedSubtree(
                    key: ValueKey(s.lang),
                    child: Column(
                      children: [
                        const _DemoStrip(),
                        Expanded(child: child!),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        home: const Root(),
      ),
    ),
  );
}

/// Thin bar on every screen so nobody mistakes the demo for the real thing.
class _DemoStrip extends StatelessWidget {
  const _DemoStrip();
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('demo-strip'),
    width: double.infinity,
    color: C.warnBg,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
    child: const Text(
      'DEMO · Data contoh · Bukan aplikasi resmi Aice',
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: C.warnInk,
        decoration: TextDecoration.none,
      ),
    ),
  );
}
