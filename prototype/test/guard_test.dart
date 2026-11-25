import 'dart:io';

import 'package:aice_shopping/config.dart';
import 'package:aice_shopping/data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Product promises as tests (guidebook 4.6, Aice 5.3 and 5.5).
void main() {
  test('only Aice is switched on, and all data is sample data', () {
    // Aice plus the store's own everyday goods, nothing else.
    expect(enabledBrands, {'aice', 'toko'});
    expect(sampleData, isTrue);
    expect(catalog, isNotEmpty);
    for (final p in catalog) {
      expect(enabledBrands, contains(p.brandId), reason: p.id);
      expect(p.sample, isTrue, reason: p.id);
      // Sayur, sembako and snack are never sold as Aice products.
      if (const {'sayur', 'sembako', 'snack'}.contains(p.group)) {
        expect(p.brandId, isNot('aice'), reason: p.id);
      }
    }
    for (final s in stores) {
      expect(s.sample, isTrue, reason: s.name);
      expect(s.brandIds.every(enabledBrands.contains), isTrue, reason: s.name);
    }
  });

  test('the 7 shelves the client asked for, each with 3 or more items', () {
    expect(categories.keys.toList(), [
      'yogurt',
      'frozen',
      'icecream',
      'sayur',
      'sembako',
      'drink',
      'snack',
    ]);
    for (final p in catalog) {
      expect(categories.keys, contains(p.group), reason: p.id);
    }
    for (final c in categories.keys) {
      expect(
        catalog.where((p) => p.group == c && !p.soldOut).length,
        greaterThanOrEqualTo(3),
        reason: c,
      );
    }
  });

  test('no banned claims in app copy', () {
    // The disclaimer itself is allowed; any other "resmi" is a claim.
    // The same disclaimer in English and Chinese is allowed too.
    const allowed = [
      'bukan aplikasi resmi aice',
      'not an official aice app',
      '非 aice 官方应用',
    ];
    final banned = [
      'resmi',
      'mitra resmi',
      'dijamin',
      'official',
      'partner aice',
      // Real payment brands would imply a live integration.
      'gopay', 'ovo', 'shopeepay', 'linkaja', 'dana ', 'bca', 'mandiri',
    ];
    final files = [
      ...Directory('lib').listSync(recursive: true).whereType<File>(),
      File('web/index.html'),
    ];
    for (final f in files) {
      var text = f.readAsStringSync().toLowerCase();
      for (final a in allowed) {
        text = text.replaceAll(a, '');
      }
      for (final w in banned) {
        // "dana " also matches "kembalikan dana " (refund), which is allowed.
        final hits = RegExp(RegExp.escape(w)).allMatches(text).where((m) {
          if (w != 'dana ') return true;
          final before = text.substring(0, m.start);
          return !before.endsWith('kembalikan ') &&
              !before.endsWith('pengembalian ') &&
              !before.endsWith('tanpa ');
        });
        expect(hits, isEmpty, reason: '"$w" in ${f.path}');
      }
    }
  });

  test('cold-chain tags only on frozen and chilled goods', () {
    for (final p in catalog) {
      expect(['frozen', 'chilled', 'fresh', 'room'], contains(p.storage));
      if (const {'sembako', 'snack'}.contains(p.group)) {
        expect(p.coldChain, isFalse, reason: p.id);
      }
      if (const {'icecream', 'frozen', 'yogurt'}.contains(p.group)) {
        expect(p.coldChain, isTrue, reason: p.id);
      }
    }
  });

  test('every product photo file exists', () {
    for (final p in catalog.where((p) => p.photo != null)) {
      expect(
        File('assets/products/${p.photo}').existsSync(),
        isTrue,
        reason: p.photo,
      );
    }
  });
}
