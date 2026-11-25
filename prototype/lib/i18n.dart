import 'package:flutter/widgets.dart' as w;
import 'accounts.dart';
import 'data.dart';
import 'l10n/en.dart';
import 'l10n/zh.dart';
import 'pricing.dart';

/// Languages in the app. Indonesian is the default and is the source text:
/// the Indonesian sentence in the code is the key. English and Chinese live in
/// one file each (lib/l10n/en.dart and lib/l10n/zh.dart).
const languages = <String, String>{
  'id': 'Bahasa Indonesia',
  'en': 'English',
  'zh': '中文',
};

/// The language showing right now. Set by [AppState.setLang].
String appLang = 'id';

/// While true, every text that has no translation is recorded in [misses].
/// Tests use this to find strings that were forgotten.
bool trackMisses = false;
final Set<String> misses = {};

final Map<String, Map<String, String>> _dicts = {'en': en, 'zh': zh};
final Map<String, String> _cache = {};
String _cacheLang = '';

class _Template {
  final RegExp re;
  final String out;
  final int fixed; // characters that are not holes
  const _Template(this.re, this.out, this.fixed);
}

final Map<String, List<_Template>> _templates = {};

List<_Template> _templatesFor(String lang) => _templates.putIfAbsent(lang, () {
  final list = <_Template>[];
  _dicts[lang]!.forEach((k, v) {
    if (!k.contains('{}')) return;
    final parts = k.split('{}').map(RegExp.escape).toList();
    list.add(
      _Template(
        RegExp('^${parts.join('(.+?)')}\$', dotAll: true),
        v,
        k.replaceAll('{}', '').length,
      ),
    );
  });
  // The key with the most fixed text wins, so '{}: {}' is the last resort.
  list.sort((a, b) => b.fixed.compareTo(a.fixed));
  return list;
});

/// Translates [s] (Indonesian source text) into the current language.
/// Text with numbers or names inside uses a template key with `{}` holes, for
/// example `'{} ditambahkan'`. Text with no translation shows as written.
String tr(String s) {
  if (appLang == 'id' || s.isEmpty) return s;
  if (_cacheLang != appLang) {
    _cache.clear();
    _cacheLang = appLang;
  }
  final hit = _cache[s];
  if (hit != null) return hit;
  final out = _translate(s);
  _cache[s] = out;
  return out;
}

String _translate(String s) {
  final d = _dicts[appLang]!;
  final exact = d[s];
  if (exact != null) return exact;
  final trimmed = s.trim();
  if (trimmed != s && d[trimmed] != null) {
    return s.replaceFirst(trimmed, d[trimmed]!);
  }
  for (final t in _templatesFor(appLang)) {
    final m = t.re.firstMatch(s);
    if (m == null) continue;
    var i = 0;
    return t.out.replaceAllMapped('{}', (_) {
      final g = m.group(++i) ?? '';
      return d[g] ?? g; // a hole may itself be a known word
    });
  }
  if (s.contains(', ') && !s.contains('\n')) {
    final parts = s.split(', ');
    if (parts.every((p) => RegExp(r' x\d+$').hasMatch(p))) {
      return parts.map(tr).join(', ');
    }
  }
  if (s.contains(' · ')) {
    // "Rp5.000 · Transfer bank": translate each part on its own.
    return s.split(' · ').map(tr).join(' · ');
  }
  if (trackMisses && _needsTranslation(s)) misses.add(s);
  return s;
}

List<String>? _keep;

/// Names that stay as they are in every language: products, sample people,
/// addresses and a few codes.
List<String> _keepList() => _keep ??= ([
  for (final p in allProducts) p.name,
  for (final c in demoAccounts) c.name,
  ...savedAddresses,
  for (final a in savedAddresses) ...a.split(', '),
  'Asia/Jakarta (UTC+7)',
  inviteCodeVip,
  for (final v in vouchers) v.code,
  sampleBankAccount,
]..sort((a, b) => b.length.compareTo(a.length)));

final _codes = RegExp(
  r'\b(ml|g|km|pcs|x|VIP|QRIS|ID|EN|OTP|WhatsApp|BPOM|UTC|P0|P1|SHOPPING|aice|Rp|AC)\b',
);

/// Numbers, prices, names and codes need no translation.
bool _needsTranslation(String s) {
  var t = s;
  for (final k in _keepList()) {
    t = t.replaceAll(k, '');
  }
  t = t.replaceAll(RegExp(r'Rp[\d.,\-]*'), '').replaceAll(_codes, '');
  return RegExp(r'[A-Za-z]{2,}').hasMatch(t);
}

/// Drop-in for Flutter's [w.Text]: shows [data] in the current language.
class Text extends w.StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textScaler,
    this.semanticsLabel,
  });
  final String data;
  final w.TextStyle? style;
  final w.TextAlign? textAlign;
  final int? maxLines;
  final w.TextOverflow? overflow;
  final bool? softWrap;
  final w.TextScaler? textScaler;
  final String? semanticsLabel;

  @override
  w.Widget build(w.BuildContext context) => w.Text(
    tr(data),
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    softWrap: softWrap,
    textScaler: textScaler,
    semanticsLabel: semanticsLabel,
  );
}
