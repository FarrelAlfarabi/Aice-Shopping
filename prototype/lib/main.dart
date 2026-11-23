import 'package:flutter/material.dart';
import 'screens_a.dart';
import 'state.dart';
import 'ui.dart';

void main() => runApp(const AiceApp());

class AiceApp extends StatefulWidget {
  const AiceApp({super.key});
  @override
  State<AiceApp> createState() => _AiceAppState();
}

class _AiceAppState extends State<AiceApp> {
  final state = AppState();

  @override
  Widget build(BuildContext context) => AppScope(
        state: state,
        child: MaterialApp(
          title: 'Aice Shopping (demo)',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          // On a laptop the app sits in a centered phone-width frame.
          builder: (context, child) => ColoredBox(
            color: const Color(0xFFDCE5F2),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: ClipRect(child: child),
              ),
            ),
          ),
          home: const Root(),
        ),
      );
}
