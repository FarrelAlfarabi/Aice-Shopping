import 'dart:io';

import 'package:aice_shopping/config.dart';
import 'package:aice_shopping/data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Product promises as tests (guidebook 4.6, Aice 5.3 and 5.5).
void main() {
  test('only Aice is switched on, and all data is sample data', () {
    expect(enabledBrands, {'aice'});
    expect(sampleData, isTrue);
    expect(catalog, isNotEmpty);
    for (final p in catalog) {
      expect(p.brandId, 'aice', reason: p.id);
      expect(p.sample, isTrue, reason: p.id);
    }
    for (final s in stores) {
      expect(s.sample, isTrue, reason: s.name);
      expect(s.brandIds.every(enabledBrands.contains), isTrue, reason: s.name);
    }
  });

  test('every category has several listings', () {
    for (final c in categories.keys) {
      expect(catalog.where((p) => p.category == c).length,
          greaterThanOrEqualTo(3),
          reason: c);
    }
  });

  test('no banned claims in app copy', () {
    // The disclaimer itself is allowed; any other "resmi" is a claim.
    const allowed = 'bukan aplikasi resmi aice';
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
      final text = f.readAsStringSync().toLowerCase().replaceAll(allowed, '');
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

  test('every product photo file exists', () {
    for (final p in catalog.where((p) => p.photo != null)) {
      expect(File('assets/products/${p.photo}').existsSync(), isTrue,
          reason: p.photo);
    }
  });
}
