import 'dart:io';
import 'dart:typed_data';

import 'package:aice_shopping/l10n/en.dart';
import 'package:aice_shopping/l10n/zh.dart';
import 'package:aice_shopping/motion.dart';
import 'package:flutter_test/flutter_test.dart';

import 'walk.dart';

/// English, Indonesian (default) and Chinese. The Indonesian sentence in the
/// code is the key; en.dart and zh.dart hold the other two languages.
void main() {
  setUpAll(() => loopMotion = false);

  test('every key exists in English and Chinese', () {
    expect(en.keys.toSet().difference(zh.keys.toSet()), isEmpty,
        reason: 'in English but not Chinese');
    expect(zh.keys.toSet().difference(en.keys.toSet()), isEmpty,
        reason: 'in Chinese but not English');
  });

  test('no empty translations, and holes {} match the key', () {
    int holes(String s) => '{}'.allMatches(s).length;
    for (final d in [en, zh]) {
      d.forEach((k, v) {
        expect(v.trim(), isNotEmpty, reason: k);
        expect(holes(v), holes(k), reason: 'holes differ for: $k');
      });
    }
  });

  test('Chinese values contain Chinese, English values do not', () {
    final cjk = RegExp(r'[一-鿿]');
    zh.forEach((k, v) {
      // Short codes and numbers may stay as they are.
      if (RegExp(r'[A-Za-z]{3,}').hasMatch(k)) {
        expect(cjk.hasMatch(v), isTrue, reason: k);
      }
    });
    en.forEach((k, v) => expect(cjk.hasMatch(v), isFalse, reason: k));
  });

  test('every tr(...) in the code has a translation', () {
    final re = RegExp(r"""\btr\(\s*'((?:[^'\\]|\\.)*)'\s*\)""");
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.contains('l10n')) continue;
      for (final m in re.allMatches(f.readAsStringSync())) {
        final key = m.group(1)!;
        if (key.contains(r'$')) continue; // built at run time
        expect(en.containsKey(key), isTrue, reason: '"$key" in ${f.path}');
      }
    }
  });

  for (final lang in ['en', 'zh']) {
    testWidgets('every screen is translated: $lang', (tester) async {
      final (missing, problems) = await walk(tester, lang);
      expect(problems, isEmpty, reason: problems.join('\n'));
      expect(missing, isEmpty,
          reason: 'No $lang text for:\n${(missing.toList()..sort()).join('\n')}');
    });
  }

  for (final lang in ['en', 'zh']) {
    testWidgets('360 px with large text (1.3x) has no overflow: $lang',
        (tester) async {
      final (_, problems) = await walk(tester, lang, scale: 1.3);
      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  }

  test('the bundled Chinese font has every character in zh.dart', () {
    // Run tool/make_zh_font.py again when this fails.
    final used = {
      for (final v in zh.values) ...v.runes.where((r) => r > 0x2E80),
    };
    final cmap = _fontChars(File('assets/fonts/ZhSubset.ttf').readAsBytesSync());
    final missing = used.where((r) => !cmap.contains(r)).map(String.fromCharCode);
    expect(missing, isEmpty);
  });
}

/// Reads the characters a TrueType font has (format 4 and 12 cmap tables).
Set<int> _fontChars(List<int> b) {
  final d = ByteData.sublistView(Uint8List.fromList(b));
  int u16(int o) => d.getUint16(o);
  int u32(int o) => d.getUint32(o);
  final n = u16(4);
  var cmap = 0;
  for (var i = 0; i < n; i++) {
    final o = 12 + i * 16;
    if (String.fromCharCodes(b.sublist(o, o + 4)) == 'cmap') cmap = u32(o + 8);
  }
  final out = <int>{};
  final tables = u16(cmap + 2);
  for (var i = 0; i < tables; i++) {
    final off = cmap + u32(cmap + 4 + i * 8 + 4);
    final fmt = u16(off);
    if (fmt == 4) {
      final seg = u16(off + 6) ~/ 2;
      for (var s = 0; s < seg; s++) {
        final end = u16(off + 14 + s * 2);
        final start = u16(off + 16 + seg * 2 + s * 2);
        for (var c = start; c <= end && c != 0xFFFF; c++) {
          out.add(c);
        }
      }
    } else if (fmt == 12) {
      final groups = u32(off + 12);
      for (var g = 0; g < groups; g++) {
        final s = u32(off + 16 + g * 12);
        final e = u32(off + 20 + g * 12);
        for (var c = s; c <= e; c++) {
          out.add(c);
        }
      }
    }
  }
  return out;
}
